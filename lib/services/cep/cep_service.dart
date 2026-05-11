// services/cep/cep_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/helpers/console_log.dart';

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';
  
  static Future<bool> validarCepBrasileiro(String cep) async {
    try {
      // Remover caracteres não numéricos
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      ConsoleLog.debug('Validando CEP brasileiro: $cep -> $cepLimpo');
      
      // Verificar se tem 8 dígitos (formato brasileiro)
      if (cepLimpo.length != 8) {
        ConsoleLog.debug('CEP não tem 8 dígitos: $cepLimpo');
        return false;
      }
      
      // Verificar se não começa com 0 (CEPs brasileiros não começam com 0)
      if (cepLimpo.startsWith('0')) {
        ConsoleLog.debug('CEP começa com 0 (não é brasileiro): $cepLimpo');
        return false;
      }
      
      // Consultar API ViaCEP para verificar se existe
      ConsoleLog.debug('Consultando ViaCEP: $_baseUrl/$cepLimpo/json/');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$cepLimpo/json/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      ConsoleLog.debug('Status: ${response.statusCode}');
      ConsoleLog.debug('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Se retornar {"erro": true}, o CEP não existe
        if (data.containsKey('erro') && data['erro'] == true) {
          ConsoleLog.debug('CEP não encontrado no Brasil: $cepLimpo');
          return false;
        }
        
        // Verificar se tem cidade brasileira
        final cidade = data['localidade']?.toString().trim() ?? '';
        if (cidade.isEmpty) {
          ConsoleLog.debug('CEP não tem cidade válida: $cepLimpo');
          return false;
        }
        
        ConsoleLog.debug('✅ CEP brasileiro válido: $cepLimpo -> $cidade');
        return true;
      }
      
      return false;
    } catch (e) {
      ConsoleLog.error('Erro ao validar CEP brasileiro: $e');
      return false;
    }
  }
  
  static Future<Map<String, dynamic>?> buscarEndereco(String cep) async {
    try {
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cepLimpo.length != 8) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$cepLimpo/json/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('erro') && data['erro'] == true) {
          return null;
        }
        
        final Map<String, String> endereco = {};
        
        // Só adicionar campos que têm dados válidos
        final logradouro = data['logradouro']?.toString().trim() ?? '';
        if (logradouro.isNotEmpty) {
          endereco['logradouro'] = logradouro;
        }
        
        final bairro = data['bairro']?.toString().trim() ?? '';
        if (bairro.isNotEmpty) {
          endereco['bairro'] = bairro;
        }
        
        final cidade = data['localidade']?.toString().trim() ?? '';
        if (cidade.isNotEmpty) {
          endereco['cidade'] = cidade;
        }
        
        final estado = data['uf']?.toString().trim().toUpperCase() ?? '';
        if (estado.isNotEmpty) {
          endereco['estado'] = estado;
        }
        
        ConsoleLog.debug('Endereço retornado: $endereco');
        return endereco.isNotEmpty ? endereco : null;
      }
      
      return null;
    } catch (e) {
      ConsoleLog.error('Erro ao buscar endereço: $e');
      return null;
    }
  }
}
