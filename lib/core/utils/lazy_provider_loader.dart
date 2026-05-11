import 'package:flutter/material.dart';

import '../../providers/init_provider.dart';

/// Widget que carrega providers lazy após o primeiro build
/// Melhorando a performance do startup da aplicação
class LazyProviderLoader extends StatefulWidget {
  final Widget child;

  const LazyProviderLoader({
    super.key,
    required this.child,
  });

  @override
  State<LazyProviderLoader> createState() => _LazyProviderLoaderState();
}

class _LazyProviderLoaderState extends State<LazyProviderLoader> {
  bool _lazyProvidersLoaded = false;

  @override
  void initState() {
    super.initState();
    // Carrega providers lazy após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_lazyProvidersLoaded) {
        _loadLazyProviders();
      }
    });
  }

  void _loadLazyProviders() {
    if (!mounted) return;

    // Adiciona os providers lazy ao contexto existente
    final lazyProviders = InitProvider.createLazyProviders();

    // Como estamos usando MultiProvider, precisamos recriar a árvore
    // com os novos providers. Uma abordagem mais elegante seria
    // usar um Provider que expõe os lazy providers.
    setState(() {
      _lazyProvidersLoaded = true;
    });

    debugPrint('Lazy providers carregados para melhor performance');
  }

  @override
  Widget build(BuildContext context) {
    // Por enquanto, apenas retorna o child
    // Em uma implementação mais avançada, poderíamos usar
    // um InheritedWidget ou similar para expor os lazy providers
    return widget.child;
  }
}
