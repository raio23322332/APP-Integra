// providers/solicitacao_provider.dart
import 'package:flutter/material.dart';
import 'package:integra_app/core/models/tipo_model.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import '../data/models/solicitacao_model.dart';
import '../services/solicitacao/solicitacao_servico.dart';

class SolicitacaoProvider extends ChangeNotifier {
  final solicitacaoServico = SolicitacaoServico();
  String _title = "";
  String _slug = "";
  List<SolicitacaoModel> _solicitacoes = [];
  bool _isLoad = false;
  String get title => _title;
  String get slug => _slug;
  List<SolicitacaoModel> get solicitacoes => _solicitacoes;
  bool get isLoad => _isLoad;
  TipoModel tipo = TipoModel.empty();
  Future<void> init(String? title, String? slug) async {
    await clear();
    if (title != null && slug != null) {
      setDataPreview(title: title, slug: slug);
    }
    await loadData();
  }

  Future<void> clear() async {
    _title = "";
    _slug = "";
    _solicitacoes = [];
    notifyListeners();
  }

  void setDataPreview({required String title, required String slug}) {
    _title = title;
    _slug = slug;
    ConsoleLog.debug("title: $title | slug: $slug");
    notifyListeners();
  }

  Future<void> loadData() async {
    if (_isLoad) return;
    _isLoad = true;
    notifyListeners();
    try {
      ConsoleLog.debug('=== PROVIDER CARREGANDO DADOS ===');
      ConsoleLog.debug('Slug para busca: $slug');
      final data = await solicitacaoServico.getDataSolicitacoes(slug: slug);
      _solicitacoes = data;
      ConsoleLog.debug('Solicitações carregadas: ${_solicitacoes.length}');
    } catch (e) {
      ConsoleLog.error('Erro ao carregar solicitações: $e');
      _solicitacoes = [];
    } finally {
      _isLoad = false;
      notifyListeners();
    }
  }
}
