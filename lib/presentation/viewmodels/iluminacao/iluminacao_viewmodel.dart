import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/data/models/accordion_item_model.dart';


const List<AccordionItemModel> iluminacaoAccordionData = [
  AccordionItemModel(
    header: 'O que é',
    body:
        'Informe falhas em postes de luz, como lâmpadas queimadas ou oscilações, para que o conserto seja feito, garantindo mais segurança nas ruas e avenidas do município.',
    icon: FontAwesomeIcons.lightbulb,
  ),
  AccordionItemModel(
    header: 'Público Alvo',
    body:
        'Qualquer cidadão que resida, trabalhe ou constate o problema na área de jurisdição municipal.',
    icon: FontAwesomeIcons.users,
  ),
  AccordionItemModel(
    header: 'Como fazer',
    body:
        'Preencha o formulário informando o endereço exato da ocorrência e o tipo de problema. É muito importante, se houver, informar o número da placa de identificação do poste.',
    icon: FontAwesomeIcons.listCheck,
  ),
  AccordionItemModel(
    header: 'Documentação necessária',
    body:
        'Nenhuma documentação é exigida para abrir a solicitação. Apenas o endereço da falha e dados de contato para acompanhamento.',
    icon: FontAwesomeIcons.fileLines,
  ),
  AccordionItemModel(
    header: 'Quanto tempo leva',
    body:
        'O prazo de reparo é de até 48 horas úteis a partir da abertura da solicitação (este prazo pode ser estendido em casos de grande demanda ou condições climáticas adversas).',
    icon: FontAwesomeIcons.hourglassHalf,
  ),
  AccordionItemModel(
    header: 'Quanto custa',
    body:
        'Este é um serviço gratuito de zeladoria municipal, custeado pela Contribuição de Iluminação Pública (CIP/COSIP).',
    icon: FontAwesomeIcons.moneyBillWave,
  ),
  AccordionItemModel(
    header: 'Outras informações',
    body:
        'ATENÇÃO: Em casos de risco iminente, como queda de poste, fiação elétrica solta no chão ou incêndios, ligue imediatamente para a Defesa Civil (199) ou para a concessionária de energia local.',
    icon: FontAwesomeIcons.circleInfo,
  ),
];
