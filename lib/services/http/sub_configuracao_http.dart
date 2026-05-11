import 'package:http/http.dart' as http;

class SubConfiguracaoHttp {
  Future<http.Response> tipos() async {
    String urlTenant = "";
    final uri = Uri.parse('$urlTenant/api/v1/configuration/tipos');

    // ConsoleLog.debug("uri: ${uri.toString()}");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }
}
