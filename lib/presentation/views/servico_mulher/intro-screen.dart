import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';



// const Color AppColors.primaryBlue = Color(0xFF1a7337);

class ServicosMulherPage extends StatelessWidget {
  const ServicosMulherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> servicos = [
      {
        'titulo': 'Ouvidoria para Mulheres e Meninas - Sala Girassol',
        'descricao':
            'A ouvidoria representa um espaço de acolhimento, escuta e orientação...',
        'status': 'Parcialmente Digital',
      },
      {
        'titulo':
            'Atendimento especializado às mulheres em situação de violência na Casa da Mulher Cearense',
        'descricao':
            'Casas da Mulher Cearense é um espaço de atendimento às mulheres...',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Atendimento especializado às mulheres em situação de violência na Sala Lilás da Estação da Mulher',
        'descricao':
            'Sala Lilás é um espaço de atendimento às mulheres em situação de violência...',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Solicitar prótese mamária externa removível no Instituto de Prevenção do Câncer do Ceará (IPC)',
        'descricao':
            'Serviço de solicitação de prótese mamária para mulheres mastectomizadas.',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Projetos produtivos para mulheres rurais via Projeto São José',
        'descricao':
            'Apoio a projetos de inclusão produtiva para mulheres rurais.',
        'status': 'Parcialmente Digital',
      },
      {
        'titulo': 'Construção do Plano Estadual de Políticas para Mulheres',
        'descricao':
            'Participação social na elaboração de políticas públicas para mulheres.',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Situação de Violência Doméstica e Familiar (Consulta sobre acolhimento institucional)',
        'descricao':
            'Informações e orientação sobre acolhimento para vítimas de violência.',
        'status': 'Não Digital',
      },
      {
        'titulo': 'Solicitar Bolsa para o projeto Mulheres na Ciência',
        'descricao':
            'Incentivo à participação de mulheres na área científica e tecnológica.',
        'status': 'Parcialmente Digital',
      },
      {
        'titulo':
            'Capacitação para Conselho Municipal dos Direitos da Mulher CMDM',
        'descricao':
            'Formação para conselheiras municipais de direitos da mulher.',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Solicitar atendimento itinerante para mulheres em situação de violência em grandes eventos - Tenda Lilás ou Casa da Mulher Móvel',
        'descricao':
            'Atendimento móvel para mulheres em eventos de grande público.',
        'status': 'Digital',
      },
      {
        'titulo':
            'Atendimento multiprofissional para mulheres no Centro de Referência da Mulher',
        'descricao': 'Apoio psicológico, social e jurídico para mulheres.',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Solicitar apoio na implantação da Casa da Mulher e Sala Lilás Municipais',
        'descricao':
            'Suporte técnico para municípios na criação de espaços de acolhimento.',
        'status': 'Parcialmente Digital',
      },
      {
        'titulo':
            'Solicitar oficina de empreendedorismo e autonomia econômica para mulheres',
        'descricao':
            'Capacitação para o desenvolvimento de negócios e geração de renda.',
        'status': 'Não Digital',
      },
      {
        'titulo':
            'Capacitação profissionalizante para mulheres em situação de violência e outras vulnerabilidades',
        'descricao':
            'Cursos e treinamentos para inserção no mercado de trabalho.',
        'status': 'Não Digital',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.authText,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.green),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mulher',
            style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Consulte os serviços relacionados à Mulher',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...servicos.map(
            (servico) => _ServicoCard(
              titulo: servico['titulo'],
              descricao: servico['descricao'],
              status: servico['status'],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String status;

  const _ServicoCard({
    required this.titulo,
    required this.descricao,
    required this.status,
  });

  Color _statusColor() {
    switch (status) {
      case 'Digital':
        return AppColors.success;
      case 'Parcialmente Digital':
        return AppColors.warning;
      default:
        return AppColors.lightIcon;
    }
  }

  Color _statusTextColor() {
    switch (status) {
      case 'Parcialmente Digital':
        return Colors.black87;
      default:
        return const Color.fromARGB(255, 255, 255, 255);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descricao,
                  style: TextStyle(
                    color: AppColors.lightSecondaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _statusTextColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
