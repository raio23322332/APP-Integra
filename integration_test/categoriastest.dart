import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestCategoriesPage(),
    );
  }
}

class TestCategoriesPage extends StatefulWidget {
  const TestCategoriesPage({super.key});

  @override
  State<TestCategoriesPage> createState() => _TestCategoriesPageState();
}

class _TestCategoriesPageState extends State<TestCategoriesPage> {
  String responseText = 'Clique no botão para testar a API';

  Future<void> fetchCategories() async {
    const String baseUrl = 'http://192.168.1.2:8000';
    const String token =
        'PjEptuN5i7WYBDchvzgaKMoILsyITMBKDK2BCeJb714dc4e3';

    final Uri url = Uri.parse('$baseUrl/v1/categories');

    // 🔹 LOG DA REQUISIÇÃO
    debugPrint('================ REQUEST ================');
    debugPrint('GET $url');
    debugPrint('Headers:');
    debugPrint('Authorization: Bearer $token');
    debugPrint('Host: test.localhost');
    debugPrint('=========================================');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Host': 'test.localhost',
        },
      );

      // 🔹 LOG DA RESPOSTA
      debugPrint('================ RESPONSE ===============');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('=========================================');

      setState(() {
        responseText =
            'STATUS: ${response.statusCode}\n\n${response.body}';
      });
    } catch (e, stack) {
      // 🔴 LOG DE ERRO
      debugPrint('================ ERROR ==================');
      debugPrint('Erro: $e');
      debugPrint('Stack: $stack');
      debugPrint('=========================================');

      setState(() {
        responseText = 'ERRO: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Services API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: fetchCategories,
              child: const Text('Buscar Services'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  responseText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
