# Componente ConfirmationDialog

Um componente reutilizável para diálogos de confirmação com o mesmo estilo visual do diálogo de exclusão de solicitações.

## 🎨 Características

- **Design consistente** com o diálogo de exclusão existente
- **Totalmente customizável** (ícones, cores, textos)
- **Responsivo** e acessível
- **Fácil de usar** com método estático

## 📦 Como usar

### Uso básico com método estático:

```dart
// Importar
import 'package:integra_app/widgets/dialogs/confirmation_dialog.dart';

// Diálogo de exclusão
final confirmed = await ConfirmationDialog.show(
  context: context,
  title: 'Excluir Item',
  message: 'Tem certeza que deseja excluir este item?',
  detailText: 'Descrição do item a ser excluído',
  confirmText: 'Excluir',
  icon: Icons.delete_outline,
  iconColor: Colors.red,
  confirmColor: Colors.red,
);

if (confirmed == true) {
  // Executar ação de exclusão
}
```

### Uso com DialogExamples:

```dart
// Importar
import 'package:integra_app/widgets/dialogs/dialog_examples.dart';

// Diálogo de exclusão
final confirmed = await DialogExamples.showDeleteDialog(
  context: context,
  itemName: 'Minha Solicitação',
  itemDescription: 'Descrição detalhada...',
);

// Diálogo de confirmação genérico
final confirmed = await DialogExamples.showConfirmDialog(
  context: context,
  title: 'Salvar Alterações',
  message: 'Deseja salvar as alterações feitas?',
);

// Diálogo de logout
final confirmed = await DialogExamples.showLogoutDialog(context: context);
```

## 🎛️ Parâmetros

### ConfirmationDialog.show()

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `context` | `BuildContext` | ✅ | Contexto do Flutter |
| `title` | `String` | ✅ | Título do diálogo |
| `message` | `String` | ✅ | Mensagem principal |
| `detailText` | `String?` | `null` | Texto detalhado (opcional) |
| `warningText` | `String?` | `'Esta ação não poderá ser desfeita!'` | Texto de aviso |
| `icon` | `IconData` | `Icons.delete_outline` | Ícone principal |
| `iconColor` | `Color` | `Colors.red` | Cor do ícone |
| `iconBackgroundColor` | `Color` | `Colors.red` | Cor de fundo do ícone |
| `confirmText` | `String` | `'Confirmar'` | Texto do botão confirmar |
| `cancelText` | `String` | `'Cancelar'` | Texto do botão cancelar |
| `confirmColor` | `Color` | `Colors.red` | Cor do botão confirmar |
| `showWarning` | `bool` | `true` | Mostrar aviso |

## 🎨 Exemplos Prontos

### 1. Diálogo de Exclusão (vermelho)
```dart
await ConfirmationDialog.show(
  context: context,
  title: 'Excluir Solicitação',
  message: 'Tem certeza que deseja excluir esta solicitação?',
  detailText: solicitacao.descricao,
  icon: Icons.delete_outline,
  iconColor: Colors.red,
  confirmColor: Colors.red,
);
```

### 2. Diálogo de Confirmação (azul)
```dart
await ConfirmationDialog.show(
  context: context,
  title: 'Salvar Alterações',
  message: 'Deseja salvar as alterações feitas?',
  icon: Icons.save,
  iconColor: Colors.blue,
  iconBackgroundColor: Colors.blue,
  confirmColor: Colors.blue,
  showWarning: false,
);
```

### 3. Diálogo de Aviso (laranja)
```dart
await ConfirmationDialog.show(
  context: context,
  title: 'Atenção',
  message: 'Verifique as informações antes de continuar',
  icon: Icons.warning_rounded,
  iconColor: Colors.orange,
  iconBackgroundColor: Colors.orange,
  confirmColor: Colors.orange,
);
```

### 4. Diálogo de Sucesso (verde)
```dart
await ConfirmationDialog.show(
  context: context,
  title: 'Operação Concluída',
  message: 'A operação foi realizada com sucesso!',
  icon: Icons.check_circle,
  iconColor: Colors.green,
  iconBackgroundColor: Colors.green,
  confirmColor: Colors.green,
  showWarning: false,
);
```

## 🔧 Exemplos de DialogExamples

### Diálogo de Logout
```dart
await DialogExamples.showLogoutDialog(context: context);
```

### Diálogo de Cancelamento
```dart
await DialogExamples.showCancelDialog(
  context: context,
  itemName: 'Edição de Perfil',
);
```

### Diálogo de Reset
```dart
await DialogExamples.showResetDialog(
  context: context,
  itemName: 'Configurações',
);
```

## 🎯 Benefícios

✅ **Consistência visual** - Mesmo estilo em todo o app  
✅ **Reutilizável** - Um componente para todos os diálogos  
✅ **Customizável** - Cores, ícones e textos configuráveis  
✅ **Acessível** - Bom contraste e navegação por teclado  
✅ **Fácil de usar** - Método estático simples  
✅ **Manutenível** - Código centralizado e organizado

## 📱 Estrutura Visual

```
┌─────────────────────────────┐
│          🗑️ Ícone             │
│                               │
│         Título Principal       │
│                               │
│      Mensagem de confirmação   │
│                               │
│  📋 Detalhes (opcional)       │
│                               │
│  ⚠️ Aviso (opcional)          │
│                               │
│   [Cancelar]   [Confirmar]    │
└─────────────────────────────┘
```

## 🔄 Retorno

O método `show()` retorna `Future<bool?>`:
- `true` - Usuário confirmou
- `false` - Usuário cancelou
- `null` - Diálogo foi fechado sem resposta

## 📝 Notas

- O diálogo é **modal** (barreira não dispensável)
- Use `showWarning: false` para diálogos informativos
- `detailText` é útil para mostrar informações específicas
- Cores seguem o padrão Material Design
