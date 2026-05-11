import 'dart:async';
import 'package:flutter/material.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  static ImageCacheManager get instance => _instance;

  final Map<String, ImageProvider> _cache = {};
  final Map<String, Completer<ImageInfo>> _loadingCompleters = {};

  ImageCacheManager._internal();

  Future<ImageProvider> getImage(String url, {double? width, double? height}) async {
    final cacheKey = '$url${width}x$height';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    if (_loadingCompleters.containsKey(cacheKey)) {
      return _loadingCompleters[cacheKey]!.future.then((_) => _cache[cacheKey]!);
    }

    final completer = Completer<ImageInfo>();
    _loadingCompleters[cacheKey] = completer;

    final image = NetworkImage(url);
    final stream = image.resolve(ImageConfiguration.empty);

    stream.addListener(ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        _cache[cacheKey] = image;
        completer.complete(info);
        _loadingCompleters.remove(cacheKey);
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception);
        _loadingCompleters.remove(cacheKey);
      },
    ));

    await completer.future;
    return image;
  }

  void clearCache() {
    _cache.clear();
    _loadingCompleters.clear();
  }

  void clearExpiredCache() {
    // Implementar limpeza baseada em tempo se necessário
    // Por enquanto, mantém cache simples
  }
}
