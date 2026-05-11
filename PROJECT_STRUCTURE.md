# Estrutura do Projeto APP-Integra

## Visão Geral da Arquitetura

Este projeto segue a arquitetura MVVM (Model-View-ViewModel) com clean architecture principles. A estrutura é organizada em camadas bem definidas que garantem separação de responsabilidades, testabilidade e manutenibilidade.

## Estrutura de Diretórios

```
lib/
├── core/                 # Camada de infraestrutura compartilhada
├── data/                 # Camada de dados (repositories, datasources, models)
├── domain/               # Camada de domínio (entities, usecases, services)
├── presentation/         # Camada de apresentação (views, viewmodels, providers)
├── providers/            # Providers globais da aplicação
└── services/             # Serviços de infraestrutura
```

## Camada Core

### `/core/constants/`
- `tenant_constants.dart`: Constantes relacionadas aos tenants (municípios)
- `navigation_constants.dart`: Constantes de navegação e rotas

### `/core/contracts/`
- `auth_service_contract.dart`: Contrato para serviços de autenticação
- `domain_http_contract.dart`: Contrato para comunicação HTTP

### `/core/enums/`
- Define enums compartilhados da aplicação

### `/core/errors/`
- `tenant_errors.dart`: Tratamento de erros específicos dos tenants

### `/core/helpers/`
- `console_log.dart`: Utilitário para logging estruturado

### `/core/navigation/`
- Contém lógica de navegação

### `/core/theme/`
- Configurações de tema da aplicação

### `/core/utils/`
- `lazy_provider_loader.dart`: Utilitário para carregamento lazy de providers
- `icon_mapper.dart`: Mapeamento de ícones

## Camada Data

### `/data/dao/`
- `tenant_config_dao.dart`: Data Access Object para configuração de tenants

### `/data/datasources/`
- `auth_remote_datasource.dart`: Fonte de dados remota para autenticação
- `auth_remote_datasource_impl.dart`: Implementação da fonte de dados de auth

### `/data/models/`
- `tenant_model.dart`: Modelo de dados para tenant
- `user_model.dart`: Modelo de dados para usuário
- `category_model.dart`: Modelo de dados para categorias
- `service_model.dart`: Modelo de dados para serviços

### `/data/repositories/`
- Implementações concretas dos repositories

## Camada Domain

### `/domain/contracts/`
- `logout_service.dart`: Contrato para serviço de logout

### `/domain/entities/`
- `tenant_entity.dart`: Entidade de domínio para tenant
- `auth_response.dart`: Entidade para resposta de autenticação

### `/domain/mappers/`
- `tenant_mapper.dart`: Mapeamento entre entidades e modelos
- `mapper_service.dart`: Serviço de mapeamento genérico

### `/domain/repositories/`
- `tenant_repository.dart`: Contrato do repositório de tenants
- `tenant_repository_impl.dart`: Implementação do repositório
- `auth_repository.dart`: Contrato do repositório de auth
- `auth_repository_impl.dart`: Implementação do repositório

### `/domain/services/`
- `login_authentication_service.dart`: Serviço de autenticação de login
- `form_validation_service.dart`: Serviço de validação de formulários

### `/domain/usecases/`
- `login_usecase.dart`: Caso de uso para login
- `get_tenants_usecase.dart`: Caso de uso para obter tenants
- `save_selected_tenant_usecase.dart`: Caso de uso para salvar tenant selecionado

## Camada Presentation

### `/presentation/providers/`
- `tenant_providers.dart`: Providers específicos dos tenants

### `/presentation/routes/`
- `app_router.dart`: Configuração das rotas da aplicação usando GoRouter

### `/presentation/viewmodels/`
- `auth/login_viewmodel.dart`: ViewModel para tela de login
- `tenant_select_viewmodel.dart`: ViewModel para seleção de tenant
- `home/home_viewmodel.dart`: ViewModel para tela principal
- `categorias_e_servicos/categories_viewmodel.dart`: ViewModel para categorias
- `categorias_e_servicos/services_viewmodel.dart`: ViewModel para serviços
- `base/base_form_viewmodel.dart`: ViewModel base para formulários

### `/presentation/views/`
- `auth/login.dart`: Tela de login
- `tenant_select_page.dart`: Tela de seleção de município
- `home/home_screen.dart`: Tela principal (home)
- `categorias_e_servicos/categoria_scree.dart`: Tela de categorias
- `categorias_e_servicos/services_screen.dart`: Tela de serviços
- `cadastro.dart`: Tela de cadastro

### `/presentation/widgets/`
- `common/`: Widgets comuns reutilizáveis
  - `app_loader.dart`: Loader da aplicação
  - `tenant_skeleton_loader.dart`: Skeleton loader para tenants
  - `smooth_animations.dart`: Animações suaves
- `shared/`: Widgets compartilhados
  - `custom_snack_bar.dart`: SnackBar customizado
  - `view_model_event.dart`: Sistema de eventos para comunicação View-ViewModel
  - `view_state_builder.dart`: Builder para estados de view

## Providers Globais

### `/providers/`
- `init_provider.dart`: Provider de inicialização da aplicação
- `municipio_provider.dart`: Provider para dados do município

## Serviços de Infraestrutura

### `/services/`
- `auth/`: Serviços de autenticação
  - `auth_service.dart`: Serviço principal de autenticação
  - `auth_service_adapter.dart`: Adaptador para serviço de auth
- `domain/`: Serviços de domínio
  - `domain_service.dart`: Serviço para operações de domínio
  - `domain_http.dart`: Cliente HTTP para domínio
- `http/`: Serviços HTTP
- `local/`: Serviços locais
- `storage/`: Serviços de armazenamento
  - `domain_storage.dart`: Armazenamento para dados de domínio
- `category_service.dart`: Serviço para categorias
- `navigation_service.dart`: Serviço de navegação
- `connectivity_service.dart`: Serviço de conectividade
- `logout_service_impl.dart`: Implementação do serviço de logout

## Como Funciona Cada Arquivo

### Arquivos Principais

#### `main.dart`
Ponto de entrada da aplicação. Configura providers globais, rotas e tema.

#### `lib/presentation/routes/app_router.dart`
Centraliza toda a configuração de navegação usando GoRouter. Define rotas, guards de autenticação e transições.

#### `lib/providers/init_provider.dart`
Provider que gerencia o estado inicial da aplicação, incluindo carregamento de configurações e autenticação.

### Fluxo de Autenticação

1. **Login View** (`login.dart`): Interface do usuário para login
2. **Login ViewModel** (`login_viewmodel.dart`): Gerencia estado do formulário e validação
3. **Login UseCase** (`login_usecase.dart`): Orquestra a lógica de negócio do login
4. **Authentication Service** (`login_authentication_service.dart`): Coordena autenticação online/offline
5. **Auth Repository** (`auth_repository_impl.dart`): Acesso aos dados de autenticação
6. **Auth DataSource** (`auth_remote_datasource_impl.dart`): Comunicação com API

### Fluxo de Tenants

1. **Tenant Select View** (`tenant_select_page.dart`): Interface para seleção de município
2. **Tenant Select ViewModel** (`tenant_select_viewmodel.dart`): Gerencia lista de tenants
3. **Get Tenants UseCase** (`get_tenants_usecase.dart`): Caso de uso para buscar tenants
4. **Tenant Repository** (`tenant_repository_impl.dart`): Acesso aos dados de tenant
5. **Domain Service** (`domain_service.dart`): Serviço que busca tenants da API

### Sistema de Eventos

O sistema de eventos (`ViewModelEvent`) permite comunicação desacoplada entre ViewModels e Views:

- `ShowSnackBarEvent`: Exibe mensagens para o usuário
- `CategorySelectedEvent`: Navegação para categoria selecionada
- `NavigationEvent`: Navegação genérica

### Gerenciamento de Estado

Usamos Provider para gerenciamento de estado reativo:

- **ChangeNotifierProvider**: Para ViewModels que precisam notificar mudanças
- **FutureProvider**: Para dados assíncronos
- **Consumer**: Para rebuild reativo da UI

### Padrões de Arquitetura

#### MVVM Pattern
- **Model**: Entities e lógica de domínio pura
- **View**: Widgets responsivos sem lógica de negócio
- **ViewModel**: Estado da UI e orquestração de serviços

#### Repository Pattern
- Abstrai acesso aos dados
- Permite testes com mocks
- Centraliza lógica de cache e error handling

#### Service Layer
- Encapsula lógica de negócio complexa
- Coordena múltiplas fontes de dados
- Implementa regras transversais (logging, cache)

#### Dependency Injection
- Todas as dependências são injetadas via construtor
- Facilita testes unitários
- Reduz acoplamento entre classes

### Tratamento de Erros

- **Erros de Rede**: Tratados com fallback para modo offline
- **Erros de Validação**: Validação em tempo real nos formulários
- **Erros de API**: Mapeamento para mensagens user-friendly
- **Erros de UI**: Estados de erro específicos por tela

### Estratégia de Cache

- **Cache de Tenants**: Validade de 5 minutos para reduzir chamadas à API
- **Cache de Auth**: Tokens salvos localmente com SharedPreferences
- **Lazy Loading**: Providers carregados sob demanda

Esta estrutura garante que o código seja:
- **Manutenível**: Separação clara de responsabilidades
- **Testável**: Dependências injetáveis e interfaces bem definidas
- **Escalável**: Camadas independentes que podem crescer separadamente
- **Reutilizável**: Componentes modulares que podem ser reutilizados
