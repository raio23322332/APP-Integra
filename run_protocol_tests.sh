#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# run_protocol_tests.sh
#
# Script UNIFICADO para executar toda a suíte de testes de integração do
# módulo de PROTOCOLO do APP-Integra. Roda TODOS os fluxos em UM único
# comando, numa ordem segura e com logs coloridos.
#
# USO:
#   ./run_protocol_tests.sh                       # roda tudo (suite única)
#   ./run_protocol_tests.sh --isolated            # roda cada teste isolado
#   ./run_protocol_tests.sh --device <id>         # em device/emulator específico
#   ./run_protocol_tests.sh --driver              # usa flutter drive (device)
#   ./run_protocol_tests.sh --skip-deps           # pula flutter pub get
#   ./run_protocol_tests.sh --help                # ajuda
#
# O que faz:
#   1. Verifica se flutter está instalado
#   2. (opcional) flutter pub get
#   3. Lista dispositivos (flutter devices)
#   4. Roda a suite consolidada (protocol_actions_suite_test.dart) OU
#      cada teste isolado em sequência (com --isolated)
#   5. Reporta resultado final
#
# Modo default: roda a SUITE UNIFICADA (mais rápido, mesma sessão).
# Modo --isolated: roda cada fluxo em sessões separadas (mais lento,
#                  útil para debug — cada falha é atribuída a um teste).
# ─────────────────────────────────────────────────────────────────────────────

set -u

# ─── Cores ───────────────────────────────────────────────────────────────────
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ─── Argumentos ──────────────────────────────────────────────────────────────
MODE="suite"           # suite | isolated
DEVICE_ID=""
USE_DRIVER=false
SKIP_DEPS=false

print_help() {
  cat <<EOF
${BOLD}Suite de Testes de Integração — Módulo de Protocolo${NC}

USO:
  ./run_protocol_tests.sh [opções]

OPÇÕES:
  --isolated         Executa cada teste em sessão separada (default: suite única)
  --device <id>      Roda em device/emulador específico (flutter devices)
  --driver           Usa 'flutter drive' em vez de 'flutter test' (device real)
  --skip-deps        Pula 'flutter pub get'
  -h, --help         Mostra esta ajuda

TESTES EXECUTADOS (em ordem):
  1. protocol_module_flow_test        (fluxo base — login + criação)
  2. protocol_edit_flow_test          (edição)
  3. protocol_comment_flow_test       (comentário)
  4. protocol_receive_flow_test       (recebimento)
  5. protocol_forward_flow_test       (tramitação)
  6. protocol_appendix_flow_test      (apenso / subdocumento)
  7. protocol_attachment_flow_test    (UI de anexo — file_picker)
  8. protocol_cancel_flow_test        (cancelamento — condicional)
  9. protocol_archive_flow_test       (arquivamento — condicional)

Modo DEFAULT (sem --isolated):
  Executa APENAS a suite consolidada:
    integration_test/protocol_actions_suite_test.dart
  Esta suite rodа tudo em UMA sessão (Edit→Comment→Receive→Forward→
  Appendix→Cancel→Archive), o que é MUITO mais rápido.

EXEMPLOS:
  # Modo rápido (suite consolidada)
  ./run_protocol_tests.sh

  # Modo completo (cada teste isolado, maior cobertura)
  ./run_protocol_tests.sh --isolated

  # Em um device específico
  ./run_protocol_tests.sh --device emulator-5554

  # Em um device real usando flutter drive
  ./run_protocol_tests.sh --driver --device <device-id>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --isolated)  MODE="isolated"; shift ;;
    --device)    DEVICE_ID="$2"; shift 2 ;;
    --driver)    USE_DRIVER=true; shift ;;
    --skip-deps) SKIP_DEPS=true; shift ;;
    -h|--help)   print_help; exit 0 ;;
    *)
      echo -e "${RED}Opção desconhecida: $1${NC}"
      print_help
      exit 2
      ;;
  esac
done

# ─── Cabeçalho ───────────────────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}  APP-Integra — Suíte de Testes do Módulo de Protocolo${NC}"
echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Modo:${NC}          $MODE"
echo -e "${CYAN}Device:${NC}        ${DEVICE_ID:-<auto>}"
echo -e "${CYAN}Usar driver:${NC}   $USE_DRIVER"
echo -e "${CYAN}Skip deps:${NC}     $SKIP_DEPS"
echo ""

# ─── Verifica flutter ────────────────────────────────────────────────────────
if ! command -v flutter &>/dev/null; then
  echo -e "${RED}❌ Flutter não encontrado no PATH.${NC}"
  echo "   Instale o Flutter: https://docs.flutter.dev/get-started/install"
  exit 1
fi
echo -e "${GREEN}✔ Flutter encontrado:${NC} $(flutter --version | head -1)"
echo ""

# ─── pub get ─────────────────────────────────────────────────────────────────
if [[ "$SKIP_DEPS" == "false" ]]; then
  echo -e "${YELLOW}▶ flutter pub get${NC}"
  if ! flutter pub get; then
    echo -e "${RED}❌ 'flutter pub get' falhou.${NC}"
    exit 1
  fi
  echo ""
fi

# ─── Lista dispositivos ──────────────────────────────────────────────────────
echo -e "${YELLOW}▶ Dispositivos disponíveis:${NC}"
flutter devices || true
echo ""

# ─── Funções de execução ─────────────────────────────────────────────────────
DEVICE_FLAG=""
if [[ -n "$DEVICE_ID" ]]; then
  DEVICE_FLAG="-d $DEVICE_ID"
fi

# Lista de testes em ORDEM SEGURA (destrutivos por último, fluxos
# condicionais cobertos).
TESTS=(
  "integration_test/protocol_module_flow_test.dart"
  "integration_test/protocol_edit_flow_test.dart"
  "integration_test/protocol_comment_flow_test.dart"
  "integration_test/protocol_receive_flow_test.dart"
  "integration_test/protocol_forward_flow_test.dart"
  "integration_test/protocol_appendix_flow_test.dart"
  "integration_test/protocol_attachment_flow_test.dart"
  "integration_test/protocol_cancel_flow_test.dart"
  "integration_test/protocol_archive_flow_test.dart"
)

SUITE_FILE="integration_test/protocol_actions_suite_test.dart"

run_one() {
  local file="$1"
  local label
  label=$(basename "$file" .dart)

  echo -e "${BLUE}────────────────────────────────────────────────────────${NC}"
  echo -e "${BLUE}▶ Rodando:${NC} ${BOLD}$label${NC}"
  echo -e "${BLUE}────────────────────────────────────────────────────────${NC}"

  local cmd
  if [[ "$USE_DRIVER" == "true" ]]; then
    cmd="flutter drive --driver=test_driver/integration_test.dart --target=$file $DEVICE_FLAG"
  else
    cmd="flutter test $file $DEVICE_FLAG"
  fi

  echo -e "${CYAN}\$ $cmd${NC}"
  if eval "$cmd"; then
    echo -e "${GREEN}✔ $label — OK${NC}"
    return 0
  else
    echo -e "${RED}✘ $label — FALHOU${NC}"
    return 1
  fi
}

# ─── Execução principal ──────────────────────────────────────────────────────
FAILED=()
START_TIME=$(date +%s)

if [[ "$MODE" == "suite" ]]; then
  echo -e "${YELLOW}▶ Executando SUITE UNIFICADA (todos os fluxos em 1 sessão)${NC}"
  echo -e "${CYAN}Arquivo:${NC} $SUITE_FILE"
  echo ""
  if ! run_one "$SUITE_FILE"; then
    FAILED+=("suite")
  fi
else
  echo -e "${YELLOW}▶ Executando cada teste ISOLADO (sessões separadas)${NC}"
  echo ""
  for t in "${TESTS[@]}"; do
    if ! run_one "$t"; then
      FAILED+=("$(basename "$t" .dart)")
    fi
    echo ""
  done
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS_REM=$((ELAPSED % 60))

# ─── Relatório final ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}                    RELATÓRIO FINAL${NC}"
echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Tempo total:${NC} ${MINUTES}m ${SECONDS_REM}s"
echo ""

if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✔ TODOS OS TESTES PASSARAM${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}${BOLD}✘ TESTES QUE FALHARAM (${#FAILED[@]}):${NC}"
  for f in "${FAILED[@]}"; do
    echo -e "  ${RED}• $f${NC}"
  done
  echo ""
  exit 1
fi
