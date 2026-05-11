# Documento de Casos de Teste Funcionais  
## Sistema: Integra Digital - App Mobile Flutter  
## Padrão: ISTQB / ISO/IEC 29119  

**Versão:** 1.0  
**Plataforma:** Android/iOS  
**Escopo:** Aplicativo mobile com múltiplos tenants e funcionalidades offline

---

## Índice

1. [Autenticação e Seleção de Tenant](#1-autenticação-e-seleção-de-tenant)
2. [Registro de Usuário](#2-registro-de-usuário)
3. [Perfil e Segurança](#3-perfil-e-segurança)
4. [Dashboard/Home](#4-dashboardhome)
5. [Serviços e Categorias](#5-serviços-e-categorias)
6. [Solicitações](#6-solicitações)
7. [Sistema de Favoritos](#7-sistema-de-favoritos)
8. [Busca e Filtros](#8-busca-e-filtros)
9. [Navegação e Interface](#9-navegação-e-interface)
10. [Funcionalidades Offline](#10-funcionalidades-offline)

---

## 1. Autenticação e Seleção de Tenant

### CT001 - Seleção de Tenant e Login com credenciais válidas

#### Objetivo
Validar que o usuário consegue selecionar o tenant (domínio) e autenticar-se com sucesso.

#### Pré-Condições
- Aplicativo instalado e online.
- Usuário cadastrado em tenant específico.
- Tela de seleção de tenant acessível.

#### Severidade
Crítica

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Abrir o aplicativo | Tela de seleção de tenant/domínio exibida |
| 2 | Selecionar tenant válido ou digitar domínio correto | Domínio aceito e processado |
| 3 | Clicar em "Acessar" ou "Continuar" | Navegação para tela de login do tenant |
| 4 | Informar e-mail válido e senha correta | Campos aceitos sem mensagem de erro |
| 5 | Clicar em "Entrar" | Sistema autentica o usuário |
| 6 | — | Redirecionamento para dashboard/home |
| 7 | — | BottomNavigationBar visível com abas principais |
| 8 | — | Tenant selecionado mantido na sessão |

---

### CT002 - Login com campos obrigatórios vazios

#### Objetivo
Validar que o sistema exige e-mail e senha e exibe mensagem adequada quando os campos estão vazios.

#### Pré-Condições
- Tenant selecionado.
- Tela de login acessível.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar a tela de login do tenant | Formulário exibido |
| 2 | Deixar e-mail e senha vazios e clicar em "Entrar" | Sistema não autentica |
| 3 | — | Mensagem de validação indicando campos obrigatórios |
| 4 | — | Usuário permanece na tela de login |
| 5 | — | Campos destacados visualmente (cor/ícone) |

---

### CT003 - Login com formato de e-mail inválido

#### Objetivo
Validar que o sistema rejeita e-mail em formato inválido com feedback visual imediato.

#### Pré-Condições
- Tenant selecionado.
- Tela de login acessível.

#### Severidade
Média

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Informar e-mail em formato inválido (ex.: "emailinvalido", "a@") | Campo aceita digitação mas mostra erro |
| 2 | Informar qualquer senha e clicar em "Entrar" | Sistema não autentica |
| 3 | — | Mensagem de validação solicitando e-mail válido |
| 4 | — | Campo de e-mail destacado em vermelho |

---

### CT004 - Login com credenciais inválidas

#### Objetivo
Validar que o sistema informa falha de autenticação sem redirecionamento indevido.

#### Pré-Condições
- Tenant selecionado.
- Tela de login acessível.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Informar e-mail válido e senha incorreta | Campos aceitos |
| 2 | Clicar em "Entrar" | Sistema não autentica |
| 3 | — | Mensagem genérica de credenciais inválidas |
| 4 | — | Usuário permanece na tela de login (sem redirecionar) |
| 5 | — | Sem erro de "used after being disposed" |

---

### CT005 - Logout e encerramento de sessão

#### Objetivo
Validar que o logout encerra a sessão corretamente e retorna à seleção de tenant.

#### Pré-Condições
- Usuário autenticado no tenant.

#### Severidade
Crítica

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Estar logado e acessar perfil | Tela de perfil exibida |
| 2 | Clicar em "Sair" / "Logout" | Confirmação exibida (se aplicável) |
| 3 | Confirmar logout | Sessão encerrada |
| 4 | — | Redirecionamento para tela de seleção de tenant |
| 5 | Tentar acessar área interna sem login | Redirecionado para seleção de tenant |

---

## 2. Registro de Usuário

### CT006 - Registro com todos os campos válidos

#### Objetivo
Validar que um novo usuário consegue se cadastrar no tenant selecionado.

#### Pré-Condições
- Tenant selecionado.
- Tela de registro acessível.
- E-mail ainda não utilizado no tenant.

#### Severidade
Crítica

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar tela de registro (via "Inscrever-se") | Formulário de registro exibido |
| 2 | Preencher nome, e-mail válido, senha (mín. 8) e confirmação | Campos aceitos |
| 3 | Clicar em "Cadastrar" | Cadastro processado |
| 4 | — | Mensagem de sucesso exibida |
| 5 | — | Redirecionamento para login ou dashboard |
| 6 | Tentar login com novas credenciais | Autenticação bem-sucedida |

---

### CT007 - Registro com e-mail já existente

#### Objetivo
Validar que o sistema não permite cadastro duplicado de e-mail no mesmo tenant.

#### Pré-Condições
- Tenant selecionado.
- E-mail já cadastrado no tenant.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Preencher formulário com e-mail já existente | Campos preenchidos |
| 2 | Submeter formulário | Cadastro não realizado |
| 3 | — | Mensagem indicando e-mail já em uso |
| 4 | — | Dados mantidos para correção |

---

## 3. Perfil e Segurança

### CT008 - Acesso e visualização do perfil

#### Objetivo
Validar que o usuário autenticado consegue acessar a tela de perfil e visualizar seus dados.

#### Pré-Condições
- Usuário autenticado no tenant.

#### Severidade
Média

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar aba "Meu Perfil" na BottomNavigationBar | Tela de perfil exibida |
| 2 | — | Dados do usuário visíveis (nome, e-mail) |
| 3 | — | BottomNavigationBar permanece visível |
| 4 | — | Tenant atual exibido no header |

---

### CT009 - Edição de dados cadastrais

#### Objetivo
Validar que o usuário consegue editar nome e e-mail do perfil.

#### Pré-Condições
- Usuário autenticado.
- Tela de perfil acessível.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Clicar em "Editar Perfil" | Navegação para tela de edição |
| 2 | — | BottomNavigationBar não visível (tela individual) |
| 3 | Alterar nome e/ou e-mail e salvar | Dados validados |
| 4 | — | Mensagem de sucesso exibida |
| 5 | Retornar ao perfil | Dados atualizados visíveis |

---

### CT010 - Edição de senha

#### Objetivo
Validar que o usuário consegue alterar sua senha com validações adequadas.

#### Pré-Condições
- Usuário autenticado.
- Acesso à tela de segurança.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar tela de "Segurança e Senha" | Formulário de alteração exibido |
| 2 | Preencher senha atual, nova senha (mín. 8) e confirmação | Campos aceitos |
| 3 | Clicar em "Alterar Senha" | Validação e processamento |
| 4 | — | Mensagem de sucesso exibida |
| 5 | Fazer login com nova senha | Autenticação bem-sucedida |

---

### CT011 - Validação de senha (tamanho mínimo)

#### Objetivo
Validar que o sistema exige senha com no mínimo 8 caracteres.

#### Pré-Condições
- Tela de edição de senha acessível.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Preencher nova senha com menos de 8 caracteres | Campo aceita digitação |
| 2 | Tentar salvar | Validação falha |
| 3 | — | Mensagem indicando tamanho mínimo |
| 4 | — | Campo destacado visualmente |

---

## 4. Dashboard/Home

### CT012 - Acesso ao dashboard após login

#### Objetivo
Validar que após login o usuário é redirecionado para o dashboard/home.

#### Pré-Condições
- Usuário autenticado com sucesso.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Efetuar login com credenciais válidas | Redirecionamento automático |
| 2 | — | Dashboard/home exibido |
| 3 | — | BottomNavigationBar visível |
| 4 | — | Aba "Início" selecionada |
| 5 | — | Conteúdo do dashboard carregado |

---

### CT013 - Navegação entre abas principais

#### Objetivo
Validar navegação funcional entre as abas: Início, Perfil, Favoritos, Buscar.

#### Pré-Condições
- Usuário autenticado.

#### Severidade
Média

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Clicar em aba "Início" | Dashboard exibido |
| 2 | Clicar em aba "Meu Perfil" | Perfil exibido |
| 3 | Clicar em aba "Favoritos" | Favoritos exibidos |
| 4 | Clicar em aba "Buscar" | Tela de busca exibida |
| 5 | — | Navegação suave sem erros |
| 6 | — | Aba correta destacada visualmente |

---

## 5. Serviços e Categorias

### CT014 - Listagem de serviços

#### Objetivo
Validar que a listagem de serviços é exibida com categorias e itens.

#### Pré-Condições
- Usuário autenticado.
- Serviços cadastrados no tenant.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar dashboard/home | Categorias de serviços visíveis |
| 2 | Clicar em uma categoria | Lista de serviços da categoria exibida |
| 3 | — | Serviços com título, descrição, ícone |
| 4 | — | Loading durante carregamento (se aplicável) |
| 5 | — | Tratamento de erro se offline |

---

### CT015 - Detalhes de um serviço

#### Objetivo
Validar que ao clicar em um serviço, seus detalhes são exibidos corretamente.

#### Pré-Condições
- Serviço existente no tenant.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Na listagem, clicar em um serviço | Navegação para detalhes |
| 2 | — | Tela de detalhes com informações completas |
| 3 | — | Botão "Abrir no Web" visível (se aplicável) |
| 4 | — | Botão "Voltar" funcional |
| 5 | — | Conteúdo responsivo |

---

### CT016 - Acesso a serviço via WebView

#### Objetivo
Validar que o botão "Abrir no Web" abre o serviço em WebView interno.

#### Pré-Condições
- Serviço com URL configurada.
- Conectividade com internet.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Clicar em "Abrir no Web" | WebView aberto com URL do serviço |
| 2 | — | Loading inicial exibido |
| 3 | — | Conteúdo do serviço carregado |
| 4 | — | Botão de refresh funcional |
| 5 | — | Botão voltar retorna para detalhes |
| 6 | — | Mensagem informativa de redirecionamento |

---

## 6. Solicitações

### CT017 - Listagem de solicitações do usuário

#### Objetivo
Validar que o usuário visualiza suas solicitações na tela correspondente.

#### Pré-Condições
- Usuário autenticado.
- Solicitações existentes (ou lista vazia).

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar tela de solicitações | Lista de solicitações exibida |
| 2 | — | Cards com informações básicas (protocolo, status, data) |
| 3 | — | Indicador de carregamento durante refresh |
| 4 | — | Mensagem se lista vazia |
| 5 | — | Pull-to-refresh funcional |

---

### CT018 - Criação de nova solicitação

#### Objetivo
Validar fluxo completo de criação de solicitação com dados obrigatórios.

#### Pré-Condições
- Usuário autenticado.
- Serviço selecionado para criação.

#### Severidade
Crítica

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Selecionar serviço e clicar em "Solicitar" | Tela de nova solicitação aberta |
| 2 | Preencher informações de localização (CEP, endereço, etc.) | Campos validados |
| 3 | Preencher descrição do problema | Campo aceita texto até limite |
| 4 | Adicionar observações (opcional) | Campo funcional |
| 5 | Anexar imagens (opcional) | Upload processado |
| 6 | Clicar em "Enviar Solicitação" | Solicitação criada |
| 7 | — | Mensagem de sucesso exibida |
| 8 | — | Redirecionamento para listagem |
| 9 | — | Nova solicitação visível na lista |

---

### CT019 - Validação de CEP na criação

#### Objetivo
Validar funcionamento do campo CEP com busca e validação automática.

#### Pré-Condições
- Tela de nova solicitação aberta.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Digitar CEP válido (8 dígitos formatados) | Campo formatado automaticamente |
| 2 | Clicar em "Buscar" | Loading exibido durante busca |
| 3 | — | Endereço preenchido automaticamente se encontrado |
| 4 | Digitar CEP inválido/inexistente | Mensagem de erro exibida |
| 5 | Tentar salvar sem CEP válido | Validação falha |

---

### CT020 - Upload de imagens na solicitação

#### Objetivo
Validar upload de imagens com validações de formato e tamanho.

#### Pré-Condições
- Tela de criação/edição de solicitação.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Clicar em "Adicionar Imagem" | Opções: câmera ou galeria |
| 2 | Selecionar imagem válida (JPEG/PNG, <5MB) | Imagem adicionada à lista |
| 3 | — | Thumbnail exibido |
| 4 | Tentar upload de formato inválido | Mensagem de erro |
| 5 | Tentar upload >5MB | Mensagem de tamanho excedido |
| 6 | Remover imagem adicionada | Imagem removida da lista |

---

### CT021 - Edição de solicitação existente

#### Objetivo
Validar que usuário consegue editar solicitação existente.

#### Pré-Condições
- Solicitação existente e editável.
- Usuário com permissão.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Na listagem, clicar em editar solicitação | Tela de edição aberta |
| 2 | — | Dados atuais preenchidos nos campos |
| 3 | Alterar informações desejadas | Campos aceitam alterações |
| 4 | Salvar alterações | Atualização processada |
| 5 | — | Mensagem de sucesso exibida |
| 6 | — | Dados atualizados visíveis na listagem |

---

### CT022 - Detalhes de uma solicitação

#### Objetivo
Validar visualização completa dos detalhes de uma solicitação.

#### Pré-Condições
- Solicitação existente.

#### Severidade
Média

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Clicar em uma solicitação na listagem | Tela de detalhes aberta |
| 2 | — | Todas as informações visíveis |
| 3 | — | Imagens anexadas exibidas |
| 4 | — | Status e histórico visíveis |
| 5 | — | Botões de ação disponíveis (editar, excluir) |

---

## 7. Sistema de Favoritos

### CT023 - Adicionar serviço aos favoritos

#### Objetivo
Validar que usuário pode marcar serviços como favoritos.

#### Pré-Condições
- Usuário autenticado.
- Serviço disponível.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Nos detalhes do serviço, clicar em estrela/favorito | Ícone muda para estado ativo |
| 2 | — | Feedback visual (cor, animação) |
| 3 | — | Mensagem de sucesso (opcional) |
| 4 | Acessar aba "Favoritos" | Serviço aparece na lista |

---

### CT024 - Listagem de favoritos

#### Objetivo
Validar exibição dos serviços marcados como favoritos.

#### Pré-Condições
- Usuário com serviços favoritados.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar aba "Favoritos" | Lista de favoritos exibida |
| 2 | — | Apenas serviços favoritados visíveis |
| 3 | — | Mensagem se lista vazia |
| 4 | Clicar em serviço favorito | Navegação para detalhes |
| 5 | Remover dos favoritos | Serviço some da lista |

---

## 8. Busca e Filtros

### CT025 - Busca de serviços

#### Objetivo
Validar funcionalidade de busca de serviços por texto.

#### Pré-Condições
- Usuário autenticado.
- Serviços cadastrados.

#### Severidade
Média

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar aba "Buscar" | Campo de busca exibido |
| 2 | Digitar termo de busca | Resultados filtrados em tempo real |
| 3 | — | Loading durante busca (se aplicável) |
| 4 | Buscar termo inexistente | Mensagem "nenhum resultado" |
| 5 | Limpar campo | Lista completa exibida novamente |

---

### CT026 - Filtros de solicitações

#### Objetivo
Validar filtros disponíveis na listagem de solicitações.

#### Pré-Condições
- Usuário autenticado.
- Solicitações existentes.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Acessar tela de filtros de solicitações | Opções de filtro exibidas |
| 2 | Selecionar filtros (status, data, etc.) | Filtros aplicados |
| 3 | Clicar em "Aplicar" | Lista atualizada com filtros |
| 4 | Limpar filtros | Lista completa exibida |

---

## 9. Navegação e Interface

### CT027 - Botão voltar físico (Android)

#### Objetivo
Validar comportamento do botão voltar físico do Android.

#### Pré-Condições
- Dispositivo Android com botão voltar físico.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Pressionar botão voltar em tela principal | App minimizado (não fecha) |
| 2 | Pressionar voltar em tela de detalhes | Retorna para tela anterior |
| 3 | Pressionar voltar em tela de edição | Retorna sem salvar (ou pede confirmação) |
| 4 | Pressionar voltar em WebView | Retorna para detalhes do serviço |
| 5 | Pressionar voltar repetidamente | Comportamento consistente |

---

### CT028 - Navegação por gestos

#### Objetivo
Validar navegação por gestos swipe em telas compatíveis.

#### Pré-Condições
- Dispositivo com suporte a gestos.

#### Severidade
Baixa

#### Prioridade
Baixa

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Swipe da esquerda para direita em tela de detalhes | Retorna para tela anterior |
| 2 | Swipe em telas principais | Navegação funcional ou bloqueada |
| 3 | — | Gestos não conflitam com outros componentes |

---

### CT029 - Responsividade e orientação

#### Objetivo
Validar comportamento do app em diferentes orientações e tamanhos.

#### Pré-Condições
- Aplicativo aberto.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Rotacionar dispositivo para paisagem | Layout adaptado |
| 2 | Rotacionar para retrato | Layout restaurado |
| 3 | — | Componentes não sobrepostos |
| 4 | — | Texto legível em ambas orientações |

---

## 10. Funcionalidades Offline

### CT030 - Funcionamento offline - dados cacheados

#### Objetivo
Validar que o app funciona offline com dados em cache.

#### Pré-Condições
- Dados já carregados anteriormente.
- Conectividade removida.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Desconectar da internet | Banner offline exibido |
| 2 | Acessar serviços já carregados | Dados exibidos do cache |
| 3 | Acessar perfil | Dados do usuário visíveis |
| 4 | Tentar carregar novos dados | Mensagem offline |
| 5 | — | Indicador visual de status offline |

---

### CT031 - Criação de solicitação offline

#### Objetivo
Validar que solicitações podem ser criadas offline e sincronizadas depois.

#### Pré-Condições
- App em modo offline.

#### Severidade
Média

#### Prioridade
Média

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Criar solicitação offline | Formulário funcional |
| 2 | Preencher e enviar | Solicitação salva localmente |
| 3 | — | Indicador "pendente sincronização" |
| 4 | Reconectar internet | Sincronização automática |
| 5 | — | Solicitação enviada e status atualizado |

---

### CT032 - Sincronização automática

#### Objetivo
Validar sincronização automática ao voltar online.

#### Pré-Condições
- Dados pendentes de sincronização.
- Conectividade restaurada.

#### Severidade
Alta

#### Prioridade
Alta

| Id | Ação | Resultado Esperado |
|----|------|-------------------|
| 1 | Reconectar internet | Detecção automática |
| 2 | — | Sincronização iniciada |
| 3 | — | Indicador de sincronização visível |
| 4 | — | Dados atualizados automaticamente |
| 5 | — | Mensagem de sucesso ao completar |

---

## Rastreabilidade (Resumo)

| Módulo | Casos de Teste | Funcionalidades Cobertas |
|--------|----------------|------------------------------|
| Autenticação | CT001–CT005 | Login, seleção tenant, validações, logout |
| Registro | CT006–CT007 | Cadastro, validação e-mail único |
| Perfil | CT008–CT011 | Visualização, edição dados, alteração senha |
| Dashboard | CT012–CT013 | Acesso pós-login, navegação abas |
| Serviços | CT014–CT016 | Listagem, detalhes, WebView |
| Solicitações | CT017–CT022 | CRUD completo, validações, upload imagens |
| Favoritos | CT023–CT024 | Adicionar/remover, listagem |
| Busca | CT025–CT026 | Busca texto, filtros solicitações |
| Navegação | CT027–CT029 | Botão voltar, gestos, responsividade |
| Offline | CT030–CT032 | Cache, criação offline, sincronização |

---

## Considerações Específicas Mobile

### **Plataformas Testadas:**
- Android 8.0+ (com e sem botões físicos)
- iOS 13.0+ (com navegação por gestos)

### **Componentes Mobile Validados:**
- BottomNavigationBar e navegação principal
- Campos de formulário mobile (teclado, validações)
- Upload de imagem (câmera/galeria)
- Notificações e feedback visual
- Orientação e responsividade

### **Funcionalidades Offline:**
- Cache local com SQLite
- Sincronização automática
- Indicadores visuais de status
- Fila de operações pendentes

---

*Documento gerado especificamente para o projeto Flutter Integra Digital. Padrão ISTQB / ISO/IEC 29119 adaptado para testes funcionais mobile.*
