#!/bin/bash

# Script para executar todos os testes do Integra App

echo "======================================"
echo "Integra App - Suite de Testes"
echo "======================================"
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null
then
    echo -e "${RED}Flutter não encontrado. Por favor, instale o Flutter primeiro.${NC}"
    exit 1
fi

echo -e "${YELLOW}1. Instalando dependências...${NC}"
flutter pub get

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao instalar dependências.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}2. Gerando mocks...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao gerar mocks.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}3. Executando testes unitários e de widget...${NC}"
flutter test --coverage

if [ $? -ne 0 ]; then
    echo -e "${RED}Alguns testes falharam.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Todos os testes passaram!${NC}"

echo ""
echo -e "${YELLOW}4. Gerando relatório de cobertura...${NC}"

# Verificar se lcov está instalado
if command -v lcov &> /dev/null
then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✓ Relatório de cobertura gerado em coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠ lcov não encontrado. Instale para gerar relatório HTML de cobertura.${NC}"
    echo "  Linux: sudo apt-get install lcov"
    echo "  Mac: brew install lcov"
fi

echo ""
echo "======================================"
echo -e "${GREEN}Suite de testes concluída!${NC}"
echo "======================================"
echo ""
echo "Para executar testes de integração:"
echo "  flutter test integration_test/login_flow_test.dart"
echo "  flutter test integration_test/favorites_flow_test.dart"
echo "  flutter test integration_test/navigation_flow_test.dart"
echo ""
