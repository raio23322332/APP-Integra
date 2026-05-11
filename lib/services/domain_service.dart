// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '../../da../../da../../da../../da../../data/models/tenant_model.dart';

// /// Serviço para buscar subdomínios (Tenants) da API.
// class DomainService {
//   /// Busca a lista de Tenants (subdomínios) na API.
//   Future<List<Tenant>> fetchTenants() async {
//     // 1. Obter as variáveis de ambiente
//     final String serverIp = dotenv.env['SERVER_IP'] ?? "192.168.1.5";
//     final int serverPort = int.tryParse(dotenv.env['SERVER_PORT'] ?? "8000") ?? 8000;

//     // 2. Construir a URL completa para buscar tenants
//     final Uri tenantsUrl =
//         Uri.parse("http://$serverIp:$serverPort/api/v1/configuration/domains");

//     try {
//       final response = await http.get(tenantsUrl);

//       if (response.statusCode != 200) {
//         throw Exception("Resposta inválida: ${response.statusCode}");
//       }

//       final jsonData = jsonDecode(response.body);

//       if (jsonData["tenants"] == null) {
//         throw Exception("Formato inesperado no JSON: campo 'tenants' ausente.");
//       }

//       List tenantsList = jsonData["tenants"];

//       return tenantsList
//           .map((t) => Tenant.fromJson(t, serverIp, serverPort))
//           .toList();
//     } catch (e) {
//       // Em um app real, usar um logger.
//       print("Erro ao buscar subdomínios: $e");
//       return [];
//     }
//   }
// }





