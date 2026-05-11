
import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class MeuIpvaViewModel extends BaseViewModel {
  final List<Map<String, String>> services = [
    {
      "titulo": "Pagar IPVA",
      "descricao": "Emita o boleto para pagar o IPVA do veículo",
      "rota": "/PagarIpva",
    },
    {
      "titulo": "Emitir Certidão de Quitação",
      "descricao": "Emita a certidão de quitação do IPVA",
      "rota": "/EmitirQuitacao",
    },
    {
      "titulo": "Validar Certidão de Quitação",
      "descricao":
          "Valide a certidão de quitação para comprovar o pagamento do IPVA",
      "rota": "/validar",
    },
    {
      "titulo": "Consultar IPVA por veículo",
      "descricao": "Consulte o valor do IPVA por veículo",
      "rota": "/ConsultarIpva",
    },
    {
      "titulo": "Consultar IPVA por modelo e ano",
      "descricao":
          "Consulte o valor do IPVA de acordo com o modelo e ano do veículo",
      "rota": "/ConsultarIpvaModelo",
    },
    {
      "titulo": "Baixar Aplicativo Meu IPVA",
      "descricao": "Baixe o aplicativo oficial Meu IPVA",
      "rota": "/baixar-app-ipva",
    },
  ];

}
