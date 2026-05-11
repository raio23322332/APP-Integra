import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';

class DetranServicesViewModel extends BaseViewModel {
  final List<Map<String, dynamic>> services = [
    {
      "title": "2ª via da Carteira de Habilitação definitiva",
      "subtitle": "Solicite a 2ª via da sua Carteira de Habilitação",
      "isWebView": true,
      "url": "https://www.detran.gov.br/2via-cnh"
    },
    {
      "title": "Carteira Nacional de Habilitação (CNH) Definitiva",
      "subtitle": "Solicite a sua CNH Definitiva",
      "isWebView": true,
      "url": "https://www.detran.gov.br/cnh-definitiva"
    },
    {
      "title": "Certidão Nada Consta",
      "subtitle": "Verifique a situação da sua carteira de habilitação",
      "isWebView": true,
      "url": "https://www.detran.gov.br/certidao-nada-consta"
    },
    {
      "title": "Consultar CNH",
      "subtitle": "Acesse informações da CNH",
      "isWebView": false,
      "route": "/consultar-cnh"
    },
    {
      "title": "Consultar Pendências",
      "subtitle": "Consulte as pendências do seu veículo.",
      "isWebView": false,
      "route": "/consultar-pendencias"
    },
    {
      "title": "Informativo sobre Clonagem de Veículo",
      "subtitle": "Saiba o que fazer se a placa do seu veículo for clonada",
      "isWebView": false,
      "route": "/clonagem-veiculo"
    },
    {
      "title": "Licenciamento",
      "subtitle": "Emita o licenciamento do seu veículo",
      "isWebView": false,
      "route": "/licenciamento"
    },
    {
      "title": "Renovação de Carteira de Habilitação",
      "subtitle": "Solicite a renovação da sua Carteira de Habilitação",
      "isWebView": true,
      "url": "https://www.detran.gov.br/renovacao-cnh"
    },
    {
      "title": "Validar certidão negativa",
      "subtitle": "Valide sua certidão negativa emitida via CPF",
      "isWebView": false,
      "route": "/validar-certidao"
    },
  ];

}
