# Documentação de Flavors e Geração de APKs

## Visão geral
Este projeto agora suporta três flavors Android com configurações diferentes de ambiente e logo:

- `dev`
- `homologacao`
- `prod`

Cada flavor usa um arquivo `.env` diferente para definir a URL da API e o ambiente ativo.

---

## Arquivos de ambiente
Os arquivos de ambiente foram criados em:

- `assets/env/env.dev`
- `assets/env/env.homologacao`
- `assets/env/env.prod`

Além disso, o arquivo principal de desenvolvimento local continua em:

- `.env`

### Conteúdo dos arquivos
- `assets/env/env.dev`
  - `URL_BASE_API="https://dev.integradigital.com.br"`
  - `WEBVIEW_PORT=8000`
  - `ENVIRONMENT=development`

- `assets/env/env.homologacao`
  - `URL_BASE_API="https://hmg.integradigital.com.br"`
  - `WEBVIEW_PORT=8000`
  - `ENVIRONMENT=staging`

- `assets/env/env.prod`
  - `URL_BASE_API="https://integradigital.com.br"`
  - `WEBVIEW_PORT=8000`
  - `ENVIRONMENT=production`

---

## Configuração do Flutter
O helper de flavor está em:

- `lib/core/config/flavor_config.dart`

Ele define:
- `FlavorConfig.flavor` via `--dart-define=FLAVOR=...`
- `FlavorConfig.envFile` via `--dart-define=ENV_FILE=...`
- `FlavorConfig.logoAsset` para alternar entre `assets/images/logo.png` e `assets/images/logo_nobackground.png`

O `main.dart` carrega o arquivo de ambiente usando:

```dart
await dotenv.load(fileName: FlavorConfig.envFile);
```

---

## Uso de nome e logo por flavor
Os componentes que exibem o logo agora usam `FlavorConfig.logoAsset`:

- `lib/presentation/views/auth/login.dart`
- `lib/presentation/views/auth/register_page.dart`
- `lib/presentation/widgets/shared/scaffold_with_navbar.dart`

E o título do app em Flutter agora usa `FlavorConfig.appName`.

Comportamento:
- `dev` → nome `Integra Desenvolvimento`
  - logo: `assets/images/logo_desenvolvimento.png`
- `homologacao` → nome `Integra Homologação`
  - logo: `assets/images/logo_homologacao.png`
- `prod` → nome `Integra`
  - logo: `assets/images/logo_nobackground.png`

---

## Configuração de flavors Android
O `android/app/build.gradle.kts` já possui as flavors configuradas:

- `dev`
- `homologacao`
- `prod`

Cada flavor usa a dimensão `environment`.

O `AndroidManifest.xml` também agora usa `@string/app_name`, de modo que o nome do app muda por flavor.

---

## Assinatura temporária
Para permitir a geração de APKs sem alterar o código do Gradle, foi criado um keystore temporário:

- `android/app/key.jks`
- `android/key.properties`

O arquivo `android/key.properties` contém:

```properties
storeFile=key.jks
keyAlias=integra
keyPassword=integra123
storePassword=integra123
```

> Atenção: esta assinatura é temporária e apenas para testes. Não use esta chave em produção.

---

## Comandos para gerar APKs
### Dev

```bash
flutter build apk --flavor dev --dart-define=FLAVOR=dev --dart-define=ENV_FILE=assets/env/env.dev --release
```

### Homologação

```bash
flutter build apk --flavor homologacao --dart-define=FLAVOR=homologacao --dart-define=ENV_FILE=assets/env/env.homologacao --release
```

### Produção

```bash
flutter build apk --flavor prod --dart-define=FLAVOR=prod --dart-define=ENV_FILE=assets/env/env.prod --release
```

---

## Resultado
O APK `dev` foi gerado com sucesso em:

- `build/app/outputs/flutter-apk/app-dev-release.apk`

Se desejar, posso gerar também o APK de `homologacao` e o APK de `prod`.
