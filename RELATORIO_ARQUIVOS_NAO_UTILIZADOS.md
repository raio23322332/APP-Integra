# 📊 Relatório de Arquivos Não Utilizados - APP-Integra

## 📈 Estatísticas Gerais
- **Total de arquivos Dart:** 306
- **Arquivos importados:** 134  
- **Arquivos NÃO utilizados:** 172
- **Taxa de utilização:** 43.8%

## 🚨 Arquivos Não Utilizados por Categoria

### 📱 Presentation/Views (85 arquivos)
**Módulos inteiros não utilizados:**
- Veículos e Condutores (13 arquivos)
- Serviços Mulher (13 arquivos)  
- Agropecuária (3 arquivos)
- Educação (2 arquivos)
- Emprego e Trabalho (2 arquivos)
- Consulta CNH (1 arquivo)

**Arquivos específicos:**
- `presentation/views/agropecuaria/intro.dart`
- `presentation/views/agropecuaria/servicos.dart`
- `presentation/views/auth/register.dart`
- `presentation/views/cadastro.dart`
- `presentation/views/consulta_cnh/consulta.dart`
- `presentation/views/emprego_e_trabalho/intro.dart`
- `presentation/views/favorites_screen_OLD.dart` ⚠️
- `presentation/views/favorites_screen.dart`
- `presentation/views/home/home_ui_adapter.dart`
- `presentation/views/perfil/second_screen.dart`
- `presentation/views/poda_arvore/podas_arvore.dart`
- `presentation/views/solicitacoes/nova_solicitacao_screen_componentized.dart` ⚠️
- `presentation/views/solicitacoes/subtipo_selection_screen.dart`
- `presentation/views/webview_page.dart`
- **Todos os arquivos de Veículos e Condutores (13 arquivos)**
- **Todos os arquivos de Serviços Mulher (13 arquivos)**

### 🧠 Presentation/ViewModels (31 arquivos)
- `presentation/viewmodels/favorite_viewmodel.dart`
- `presentation/viewmodels/ui_action.dart`
- **Todos os ViewModels de Veículos e Condutores (9 arquivos)**
- **Todos os ViewModels de Serviços Mulher (13 arquivos)**
- `presentation/viewmodels/webview/webview_viewmodel.dart`

### 🎨 Presentation/Widgets (22 arquivos)
**Widgets comuns não utilizados:**
- `presentation/widgets/common/cached_image.dart`
- `presentation/widgets/common/custom_button.dart`
- `presentation/widgets/common/enhanced_loading_overlay.dart`
- `presentation/widgets/common/loading_overlay.dart`
- `presentation/widgets/common/section_title_widget.dart`
- `presentation/widgets/common/service_card_widget.dart`
- `presentation/widgets/common/smooth_animations.dart`
- `presentation/widgets/common/smooth_animations_v2.dart`
- `presentation/widgets/common/tenant_skeleton_loader.dart`

**Widgets específicos:**
- `presentation/widgets/home/access_grid_widget.dart`
- `presentation/widgets/home/category_list_widget.dart`
- `presentation/widgets/home/highlight_grid_widget.dart`
- `presentation/widgets/home/search_results_widget.dart`
- `presentation/widgets/shared/event_subscriber.dart`
- `presentation/widgets/shared/login_status_widget.dart`
- `presentation/widgets/shared/reusable_widgets.dart`
- `presentation/widgets/shared/view_state_builder.dart`
- `presentation/widgets/solicitacoes/address_input_fields.dart`
- `presentation/widgets/solicitacoes/cep_input_field.dart`
- `presentation/widgets/solicitacoes/description_input_fields.dart`
- `presentation/widgets/solicitacoes/step_progress_widget.dart`
- `presentation/widgets/widgets_mulher/servicos-mulher.dart`

### 🔧 Services (17 arquivos)
**Services de autenticação não utilizados:**
- `services/auth/credentials_handler.dart`
- `services/auth/offline_auth_handler.dart`
- `services/auth/token_validator.dart`
- `services/auth/user_data_manager.dart`

**Outros services:**
- `services/baseapi.dart`
- `services/domain_service.dart`
- `services/http/base_service.dart`
- `services/http/sub_configuracao_http.dart`
- `services/local/hive_local_storage_service.dart`
- `services/local/user_service.dart`
- `services/most_accessed_service.dart`
- `services/poda_de_arvore/image_service.dart`
- `services/service_service.dart`
- `services/solicitacao/solicitacao_parser.dart`
- `services/solicitacao/solicitacao_payload.dart`
- `services/solicitacao/solicitacao_validator.dart`
- `services/storage/domain_storage_service_impl.dart`

### 🏗️ Domain (14 arquivos)
**Contratos e entidades não utilizadas:**
- `domain/contracts/logout_service.dart`
- `domain/entities/accordion_item.dart`
- `domain/entities/auth_credentials.dart`
- `domain/entities/auth_response.dart`
- `domain/entities/tenant_entity.dart`

**Mappers e repositories:**
- `domain/mappers/mapper_service.dart`
- `domain/repositories/auth_repository.dart`
- `domain/repositories/auth_repository_impl.dart`
- `domain/repositories/tenant_repository.dart`

**Use cases não utilizados:**
- `domain/services/login_form_validator.dart`
- `domain/usecases/auth/register_usecase.dart`
- `domain/usecases/home/load_categories_usecase.dart`
- `domain/usecases/home/search_services_usecase.dart`
- `domain/usecases/services/get_iluminacao_accordion_usecase.dart`

### 💾 Data (18 arquivos)
**DAOs não utilizados:**
- `data/dao/favorite_dao.dart`
- `data/dao/repair_request_dao.dart`

**Banco de dados:**
- `data/database/database.dart`

**Data sources:**
- `data/datasources/auth_remote_datasource.dart`
- `data/datasources/auth_remote_datasource_impl.dart`
- `data/datasources/local/auth_local_datasource.dart`
- `data/datasources/local/auth_local_datasource_impl.dart`

**Models não utilizados:**
- `data/models/accordion_item_model.dart`
- `data/models/arquivo_model.dart`
- `data/models/domain_model.dart`
- `data/models/endereco_model.dart`
- `data/models/home_item_model.dart`
- `data/models/repair_request_model.dart`
- `data/models/status_ui.dart`
- `data/models/subtipo_model.dart`
- `data/models/tenant_config_model.dart`

**Tabelas:**
- `data/tables/category_table.dart`
- `data/tables/tenant_config_table.dart`

### 🎯 Core (15 arquivos)
**Configurações e constantes:**
- `core/config/app_config.dart`
- `core/constants/tenant_constants.dart`

**Contratos:**
- `core/contracts/auth_service_contract.dart`
- `core/contracts/domain_http_contract.dart`

**Enums e errors:**
- `core/enums/status_console.dart`
- `core/errors/tenant_errors.dart`

**Helpers e models:**
- `core/helpers/data_time_helper.dart`
- `core/models/recent_search_model.dart`
- `core/models/subt_tipo_model.dart`

**Navegação e tema:**
- `core/navigation/custom_transitions.dart`
- `core/theme/app_colors_login.dart`
- `core/theme/app_text_styles.dart`

**Utils:**
- `core/utils/crypto_utils.dart`
- `core/utils/image_cache_manager.dart`
- `core/utils/lazy_provider_loader.dart`

### 📦 Widgets (3 arquivos)
- `widgets/dialogs/dialog_examples.dart`
- `widgets/dialogs/logout_example.dart`
- `widgets/dialogs/no_internet_dialog.dart`

### 🔧 Utils (2 arquivos)
- `utils/html_text_extractor.dart`
- `utils/service_type_formatter.dart`

### 🗂️ Outros (1 arquivo)
- `presentation/providers/tenant_providers.dart`

## ⚠️ Arquivos Suspeitos (Verificação Manual)
- `presentation/views/favorites_screen_OLD.dart` - Arquivo antigo, seguro para remover
- `presentation/views/solicitacoes/nova_solicitacao_screen_componentized.dart` - Versão componentizada, pode ser removida

## 💡 Recomendações

### 🗑️ Pode Remover com Segurança (172 arquivos)
Esses arquivos não são referenciados por nenhum outro arquivo no projeto e podem ser removidos com segurança.

### 📋 Módulos Inteiros para Remover
1. **Veículos e Condutores** - 26 arquivos (views + viewmodels)
2. **Serviços Mulher** - 26 arquivos (views + viewmodels + widget)
3. **Agropecuária** - 6 arquivos
4. **Educação** - 4 arquivos  
5. **Emprego e Trabalho** - 4 arquivos

### 🔍 Verificação Manual Necessária
- Verificar se algum desses arquivos é carregado dinamicamente ou via reflection
- Confirmar que não há rotas dinâmicas que usem esses arquivos
- Verificar arquivos de configuração que possam referenciar esses módulos

## 📋 Comandos para Remoção
```bash
# Remover arquivos OLD e componentizados
rm lib/presentation/views/favorites_screen_OLD.dart
rm lib/presentation/views/solicitacoes/nova_solicitacao_screen_componentized.dart

# Remover módulos inteiros (exemplo)
rm -rf lib/presentation/views/Veiculos_e_condutores/
rm -rf lib/presentation/viewmodels/veiculos_e_condutores/
rm -rf lib/presentation/views/servico_mulher/
rm -rf lib/presentation/widgets/widgets_mulher/
```

## 🎯 Impacto da Limpeza
- **Redução de código:** ~172 arquivos removidos
- **Melhoria de manutenção:** Menos código para manter
- **Redução de confusão:** Apenas código em uso ativo
- **Build mais rápido:** Menos arquivos para compilar
