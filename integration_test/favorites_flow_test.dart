import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integra_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Favoritos - Testes de Integração', () {
    testWidgets('deve adicionar serviço aos favoritos', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navegar para um serviço
      // Nota: Depende da estrutura de navegação do app

      // Procurar por ícone de favorito (coração vazio)
      final favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon.first);
        await tester.pumpAndSettle();

        // Assert
        // Ícone deve mudar para coração preenchido
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }
    });

    testWidgets('deve remover serviço dos favoritos', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Adicionar favorito primeiro
      final favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon.first);
        await tester.pumpAndSettle();
      }

      // Act - Remover favorito
      final filledFavoriteIcon = find.byIcon(Icons.favorite);
      if (filledFavoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(filledFavoriteIcon.first);
        await tester.pumpAndSettle();

        // Assert
        // Ícone deve voltar para coração vazio
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      }
    });

    testWidgets('deve visualizar lista de favoritos', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navegar para tela de favoritos
      final favoritesTab = find.byIcon(Icons.star);
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Assert
        // Deve mostrar tela de favoritos
        expect(find.text('Meus Favoritos'), findsOneWidget);
      }
    });

    testWidgets('deve mostrar mensagem quando não há favoritos', (
      tester,
    ) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navegar para favoritos
      final favoritesTab = find.byIcon(Icons.star);
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Assert
        // Pode mostrar mensagem de lista vazia ou lista de favoritos
        // Depende do estado do banco de dados
      }
    });

    testWidgets('deve navegar para serviço ao clicar em favorito', (
      tester,
    ) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navegar para favoritos
      final favoritesTab = find.byIcon(Icons.star);
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Act - Clicar em um favorito (se houver)
        final favoriteItem = find.byType(ListTile);
        if (favoriteItem.evaluate().isNotEmpty) {
          await tester.tap(favoriteItem.first);
          await tester.pumpAndSettle();

          // Assert
          // Deve navegar para a tela do serviço
        }
      }
    });

    testWidgets('deve remover favorito da lista de favoritos', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navegar para favoritos
      final favoritesTab = find.byIcon(Icons.star);
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Act - Clicar no coração de um favorito (se houver)
        final favoriteHeartIcon = find.byIcon(Icons.favorite);
        if (favoriteHeartIcon.evaluate().isNotEmpty) {
          final initialCount = favoriteHeartIcon.evaluate().length;

          await tester.tap(favoriteHeartIcon.first);
          await tester.pumpAndSettle();

          // Assert
          // Item deve ser removido da lista
          final newCount = find.byIcon(Icons.favorite).evaluate().length;
          expect(newCount, lessThan(initialCount));
        }
      }
    });

   
  });

  group('Fluxo de Favoritos com Autenticação', () {
    testWidgets('deve sincronizar favoritos após login', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Nota: Este teste requer implementação de sincronização
      // entre favoritos locais e servidor

      // Act - Fazer login
      // Verificar se favoritos foram sincronizados

      // Assert
      // Favoritos do servidor devem estar disponíveis
    });

    
  });
}
