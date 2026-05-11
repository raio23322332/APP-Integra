import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicoCard extends StatefulWidget {
  final Map<String, String> servico;

  const ServicoCard({super.key, required this.servico});

  @override
  State<ServicoCard> createState() => _ServicoCardState();
}

class _ServicoCardState extends State<ServicoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) {
      context.push(widget.servico["rota"] ?? "/").then((_) {
        _controller.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipo = widget.servico["tipo"] ?? "";

    // 🔥 Cores dinâmicas para o selo de tipo
    Color corFundo;
    Color corTexto;

    if (tipo == "Digital") {
      corFundo = Colors.green.shade600;
      corTexto = Colors.white;
    } else if (tipo == "Parcialmente Digital") {
      corFundo = Colors.amber;
      corTexto = Colors.brown.shade900;
    } else {
      corFundo = Colors.grey.shade700;
      corTexto = Colors.white;
    }

    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: Colors.white, // cor de fundo dos cards
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corFundo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.servico["titulo"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.servico["descricao"] ?? "",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
