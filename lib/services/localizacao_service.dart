import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/models/estado_model.dart';
import '../core/models/cidade_model.dart';

class LocalizacaoService {
  static List<Estado>? _estadosCache;
  static List<Cidade>? _cidadesCache;

  static Future<List<Estado>> getEstados() async {
    if (_estadosCache != null) {
      return _estadosCache!;
    }

    try {
      final String jsonString = await rootBundle.loadString('js/Estados.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _estadosCache = jsonList.map((json) => Estado.fromJson(json)).toList();
      return _estadosCache!;
    } catch (e) {
      throw Exception('Erro ao carregar estados: $e');
    }
  }

  static Future<List<Cidade>> getCidades() async {
    if (_cidadesCache != null) {
      return _cidadesCache!;
    }

    try {
      final String jsonString = await rootBundle.loadString('js/Cidades.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _cidadesCache = jsonList.map((json) => Cidade.fromJson(json)).toList();
      return _cidadesCache!;
    } catch (e) {
      throw Exception('Erro ao carregar cidades: $e');
    }
  }

  static Future<List<Cidade>> getCidadesPorEstado(String estadoId) async {
    final cidades = await getCidades();
    return cidades.where((cidade) => cidade.estadoId == estadoId).toList();
  }

  static Estado? getEstadoPorSigla(String sigla) {
    if (_estadosCache == null) return null;
    
    try {
      return _estadosCache!.firstWhere(
        (estado) => estado.sigla.toUpperCase() == sigla.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static Estado? getEstadoPorId(String id) {
    if (_estadosCache == null) return null;
    
    try {
      return _estadosCache!.firstWhere((estado) => estado.id == id);
    } catch (e) {
      return null;
    }
  }

  static void limparCache() {
    _estadosCache = null;
    _cidadesCache = null;
  }
}
