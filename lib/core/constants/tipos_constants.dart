// lib/constants/tipos_constants.dart

import 'package:integra_app/core/models/subt_tipo_model.dart';
import 'package:integra_app/core/models/tipo_model.dart';

class TiposConstants {
  static final List<TipoModel> data = [
    TipoModel(
      id: '1',
      descricao: "Iluminação Pública",
      slug: "iluminacao-publica",
      status: "ATIVO",
      subtipos: [
        SubtTipoModel(
          id: '1',
          tipoId: '1',
          descricao: "Lâmpada apagada",
          slug: "lampada-apagada",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '2',
          tipoId: '1',
          descricao: "Lâmpada acesa durante o dia",
          slug: "lampada-acesa-dia",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '3',
          tipoId: '1',
          descricao: "Lâmpada oscilando",
          slug: "lampada-oscilando",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '4',
          tipoId: '1',
          descricao: "Problema não especificado",
          slug: "problema-nao-especificado-iluminacao",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '5',
          tipoId: '1',
          descricao: "Solicitação de nova iluminação",
          slug: "nova-iluminacao",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '6',
          tipoId: '1',
          descricao: "Vandalismo",
          slug: "vandalismo-iluminacao",
          status: "ATIVO",
        ),
      ],
    ),
    TipoModel(
      id: '2',
      descricao: "Limpeza Pública",
      slug: "limpeza-publica",
      status: "ATIVO",
      subtipos: [
        SubtTipoModel(
          id: '7',
          tipoId: '2',
          descricao: "Lixo acumulado",
          slug: "lixo-acumulado",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '8',
          tipoId: '2',
          descricao: "Entulho em via pública",
          slug: "entulho-via-publica",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '9',
          tipoId: '2',
          descricao: "Ponto de descarte irregular",
          slug: "descarte-irregular",
          status: "ATIVO",
        ),
      ],
    ),
    TipoModel(
      id: '3',
      descricao: "Pavimentação",
      slug: "pavimentacao",
      status: "ATIVO",
      subtipos: [
        SubtTipoModel(
          id: '10',
          tipoId: '3',
          descricao: "Presença de buracos na superfície da rua",
          slug: "buracos-rua",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '11',
          tipoId: '3',
          descricao: "Via com irregularidades na pavimentação",
          slug: "irregularidades-pavimentacao",
          status: "ATIVO",
        ),
      ],
    ),
    TipoModel(
      id: '4',
      descricao: "Poda de Árvore",
      slug: "poda-de-arvore",
      status: "ATIVO",
      subtipos: [
        SubtTipoModel(
          id: '12',
          tipoId: '4',
          descricao: "Poda de árvore em via pública",
          slug: "poda-arvore-via",
          status: "ATIVO",
        ),
        SubtTipoModel(
          id: '13',
          tipoId: '4',
          descricao: "Remoção de árvore de risco",
          slug: "remocao-arvore-risco",
          status: "ATIVO",
        ),
      ],
    ),
  ];
}
