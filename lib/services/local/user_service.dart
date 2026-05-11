import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/data/models/user_model.dart';

class UserService {
  static const String _usersEndpoint = '/users';

  // Helper para obter os headers com o token de autenticação
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _getBaseUrl() {
    final baseUrl = dotenv.env['URL_BASE_API'];
    if (baseUrl == null) {
      throw Exception("URL_BASE_API not found in .env file");
    }
    // Supondo que o endpoint de usuários está sob /api/v1/auth
    return '$baseUrl/api/v1/auth';
  }

  // 1. READ: Listar usuários
  Future<List<User>> getUsers(String token) async {
    final url = Uri.parse('${_getBaseUrl()}$_usersEndpoint');
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        // A API Laravel geralmente retorna um objeto com uma chave 'data' para coleções
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => User.fromMap(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Não autorizado (401). Token inválido ou expirado. Faça o login novamente.',
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          'Sem permissão (403). Você não pode executar esta ação.',
        );
      } else {
        throw Exception(
          'Falha ao carregar usuários. Status: ${response.statusCode}. Resposta: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API para listar usuários: $e');
    }
  }

  // 2. CREATE: Criar novo usuário
  Future<User> createUser(String token, Map<String, dynamic> userData) async {
    final url = Uri.parse('${_getBaseUrl()}$_usersEndpoint');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return User.fromMap(jsonDecode(response.body)['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado (401). Token inválido ou expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('Sem permissão (403). Você não pode criar usuários.');
      } else {
        throw Exception(
          'Falha ao criar usuário. Status: ${response.statusCode}. Resposta: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API para criar usuário: $e');
    }
  }

  // 3. UPDATE: Atualizar usuário
  Future<User> updateUser(
    String token,
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse('${_getBaseUrl()}$_usersEndpoint/$userId');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(token),
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return User.fromMap(jsonDecode(response.body)['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado (401). Token inválido ou expirado.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Sem permissão (403). Você não pode atualizar este usuário.',
        );
      } else {
        throw Exception(
          'Falha ao atualizar usuário. Status: ${response.statusCode}. Resposta: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API para atualizar usuário: $e');
    }
  }

  // 4. DELETE: Deletar usuário
  Future<void> deleteUser(String token, int userId) async {
    final url = Uri.parse('${_getBaseUrl()}$_usersEndpoint/$userId');
    try {
      final response = await http.delete(url, headers: _getHeaders(token));

      if (response.statusCode == 204) {
        // 204 No Content é o esperado para sucesso
        return; // Sucesso
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado (401). Token inválido ou expirado.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Sem permissão (403). Você não pode deletar este usuário.',
        );
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API para deletar usuário: $e');
    }
  }
}
