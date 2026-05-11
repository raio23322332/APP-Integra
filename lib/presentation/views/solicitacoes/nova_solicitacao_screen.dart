import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/helpers/console_log.dart';
import '../../../core/models/estado_model.dart';
import '../../../core/models/cidade_model.dart';
import '../../../data/dao/user_dao.dart';
import '../../../services/solicitacao/solicitacao_servico.dart';
import '../../../services/cep/cep_service.dart';
import '../../../services/localizacao_service.dart';
import 'package:integra_app/presentation/widgets/common/custom_text_field.dart';
import '../../../presentation/widgets/common/selection_modal.dart';
import '../../widgets/common/breadcrumb_widget.dart';
import '../../../core/models/breadcrumb_model.dart';
import '../../providers/breadcrumb_provider.dart';
import 'package:provider/provider.dart';
import '../../../presentation/widgets/common/app_loader.dart';
import '../../../presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/widgets/dialogs/confirmation_dialog.dart';

// Formatter para texto maiúsculo
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

// Formatter para CEP - limita a 8 dígitos e formata com traço
class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remover tudo que não for dígito
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limitar a 8 dígitos
    if (newText.length > 8) {
      newText = newText.substring(0, 8);
    }
    
    // Adicionar traço após 5 dígitos
    if (newText.length > 5) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
      composing: TextRange.empty,
    );
  }
}

class NovaSolicitacaoScreen extends StatefulWidget {
  final Map<String, dynamic> dados;

  const NovaSolicitacaoScreen({
    super.key,
    required this.dados,
  });

  @override
  State<NovaSolicitacaoScreen> createState() => _NovaSolicitacaoScreenState();
}

class _NovaSolicitacaoScreenState extends State<NovaSolicitacaoScreen> {
  // Stepper
  int _currentStep = 0;

  // Controllers do formulário
  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _referenciaController = TextEditingController();

  // Focus nodes
  final _cepFocus = FocusNode();
  final _enderecoFocus = FocusNode();
  final _numeroFocus = FocusNode();
  final _complementoFocus = FocusNode();
  final _bairroFocus = FocusNode();
  final _cidadeFocus = FocusNode();
  final _estadoFocus = FocusNode();
  final _referenciaFocus = FocusNode();

  // Estado
  bool _usarLocalizacaoAtual = false;
  bool _isLoading = false;
  bool _validandoCep = false;
  
  // Dados de localização
  List<Estado> _estados = [];
  List<Cidade> _cidades = [];
  List<Cidade> _cidadesFiltradas = [];
  Estado? _estadoSelecionado;
  Cidade? _cidadeSelecionada;
  bool _carregandoLocalizacao = false;
  bool _cepValido = false;
  Position? _currentPosition;
  final List<File> _imagens = [];
  final ImagePicker _picker = ImagePicker();
  final SolicitacaoServico _solicitacaoServico = SolicitacaoServico();

  // Constantes
  static const int _maxImagens = 5;
  static const int _maxDescricaoLength = 500;

  // Método para obter ícone baseado no tipo de solicitação
  IconData _getIconForTipo(String tipo) {
    final tipoLower = tipo.toLowerCase();
    
    // Mapeamento baseado nos ícones usados na home - com termos exatos da API
    if (tipoLower.contains('iluminação') || tipoLower.contains('iluminacao') || tipoLower.contains('luz')) {
      return Icons.lightbulb;
    } else if (tipoLower.contains('pavimentação') || tipoLower.contains('pavimentacao') || tipoLower.contains('via') || tipoLower.contains('rua')) {
      return Icons.construction;
    } else if (tipoLower.contains('limpeza') || tipoLower.contains('lixo') || tipoLower.contains('resíduo') || tipoLower.contains('residuo')) {
      return Icons.cleaning_services;
    } else if (tipoLower.contains('água') || tipoLower.contains('agua') || tipoLower.contains('esgoto') || tipoLower.contains('hidráulico') || tipoLower.contains('hidraulico')) {
      return Icons.water_drop;
    } else if (tipoLower.contains('árvore') || tipoLower.contains('arvore') || tipoLower.contains('jardim') || tipoLower.contains('parque')) {
      return Icons.park;
    } else if (tipoLower.contains('ruído') || tipoLower.contains('ruido') || tipoLower.contains('barulho') || tipoLower.contains('som')) {
      return Icons.volume_up;
    } else if (tipoLower.contains('animal') || tipoLower.contains('cachorro') || tipoLower.contains('gato')) {
      return Icons.pets;
    } else if (tipoLower.contains('transporte') || tipoLower.contains('ônibus') || tipoLower.contains('onibus') || tipoLower.contains('tráfego') || tipoLower.contains('trafego')) {
      return Icons.directions_bus;
    } else if (tipoLower.contains('segurança') || tipoLower.contains('seguranca') || tipoLower.contains('policial') || tipoLower.contains('crime')) {
      return Icons.security;
    } else if (tipoLower.contains('saúde') || tipoLower.contains('saude') || tipoLower.contains('ambulância') || tipoLower.contains('ambulancia') || tipoLower.contains('hospital')) {
      return Icons.local_hospital;
    } else if (tipoLower.contains('educação') || tipoLower.contains('educacao') || tipoLower.contains('escola') || tipoLower.contains('aula')) {
      return Icons.school;
    } else {
      // Ícone padrão para solicitações genéricas
      return Icons.assignment;
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Carregar dados de localização
    _carregarDadosLocalizacao();
    
    // Configurar breadcrumbs após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupBreadcrumbs();
    });
  }
  
  void _setupBreadcrumbs() {
    final breadcrumbProvider = context.read<BreadcrumbProvider>();
    breadcrumbProvider.setBreadcrumbs([
      const BreadcrumbItem(title: 'Home', route: '/'),
      const BreadcrumbItem(
        title: 'Solicitações',
        route: '/solicitacoes',
      ),
      BreadcrumbItem(
        title: widget.dados['tipo'] ?? 'Nova Solicitação',
        route: null, // Página atual
      ),
    ]);
    breadcrumbProvider.sendBreadcrumbToApi();
  }

  Future<void> _carregarDadosLocalizacao() async {
    setState(() {
      _carregandoLocalizacao = true;
    });

    try {
      final estados = await LocalizacaoService.getEstados();
      final cidades = await LocalizacaoService.getCidades();
      
      setState(() {
        _estados = estados;
        _cidades = cidades;
        _carregandoLocalizacao = false;
      });
    } catch (e) {
      setState(() {
        _carregandoLocalizacao = false;
      });
    }
  }

  void _mostrarModalEstado() {
    ModalHelper.showEstadoModal(
      context,
      estados: _estados,
      onEstadoSelected: (Estado? estado) {
        _onEstadoSelecionado(estado);
      },
    );
  }

  void _mostrarModalCidade() {
    ModalHelper.showCidadeModal(
      context,
      cidades: _cidadesFiltradas,
      onCidadeSelected: (Cidade? cidade) {
        _onCidadeSelecionada(cidade);
      },
    );
  }

  void _onEstadoSelecionado(Estado? estado) {
    setState(() {
      _estadoSelecionado = estado;
      _cidadeSelecionada = null;
      _cidadesFiltradas = [];
      
      if (estado != null) {
        _cidadesFiltradas = _cidades
            .where((cidade) => cidade.estadoId == estado.id)
            .toList();
        
        _estadoController.text = estado.sigla;
      } else {
        _estadoController.clear();
      }
      
      _cidadeController.clear();
    });
  }

  void _onCidadeSelecionada(Cidade? cidade) {
    setState(() {
      _cidadeSelecionada = cidade;
      
      if (cidade != null) {
        _cidadeController.text = cidade.nome;
      } else {
        _cidadeController.clear();
      }
    });
  }

  @override
  void dispose() {
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _referenciaController.dispose();
    _descricaoController.dispose();
    _observacaoController.dispose();
    
    _cepFocus.dispose();
    _enderecoFocus.dispose();
    _numeroFocus.dispose();
    _complementoFocus.dispose();
    _bairroFocus.dispose();
    _cidadeFocus.dispose();
    _estadoFocus.dispose();
    _referenciaFocus.dispose();
    
    _imagens.clear();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepTitles = ['ENDEREÇO', 'ANEXOS'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        actions: [
          // Ícone do tipo de solicitação
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _getIconForTipo(widget.dados['tipo'] ?? ''),
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          tooltip: 'Voltar',
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            // Remover apenas o último item do breadcrumb ao voltar
            final breadcrumbProvider = context.read<BreadcrumbProvider>();
            breadcrumbProvider.removeLast();
            context.pop();
          },
        ),
        titleSpacing: -16,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.lightBlue,
              ],
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height -
               MediaQuery.of(context).padding.top -
               kToolbarHeight -
               MediaQuery.of(context).padding.bottom,
        child: Column(
        children: [
          // BREADCRUMB ALINHADO À ESQUERDA
          Align(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: BreadcrumbWidget(),
            ),
          ),
          // Stepper compacto no topo
          GestureDetector(
            onTap: () {
              // Permitir navegação rápida para qualquer etapa
              _showStepSelector(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(2, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  final canAccess = index < _currentStep || 
                                   (index == _currentStep + 1 && _validateCurrentStep());

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle with number/check
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.primaryBlue
                                  : isCurrent
                                      ? AppColors.primaryBlue.withValues(alpha: 0.2)
                                      : canAccess
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: isCurrent
                                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(Icons.check, color: Colors.white, size: 20)
                                  : Icon(
                                      [Icons.layers_outlined, Icons.location_on_outlined, Icons.image_outlined][index],
                                      color: isCurrent
                                          ? AppColors.primaryBlue
                                          : canAccess
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade400,
                                      size: 20,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title below circle
                          SizedBox(
                            width: 70,
                            child: Text(
                              stepTitles[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                                color: isCompleted || isCurrent
                                    ? AppColors.primaryBlue
                                    : canAccess
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Connecting line (only between steps, not after last)
                      if (index < 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 35,
                          height: 2,
                          margin: const EdgeInsets.only(top: 18), // Center vertically with circle
                          decoration: BoxDecoration(
                            color: index < _currentStep - 1
                                ? AppColors.primaryBlue
                                : index == _currentStep - 1
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ),

          // Conteúdo da etapa atual - Solução profissional para layout constraints
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6,
              radius: const Radius.circular(6),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStep == 0
                    ? _buildEnderecoStep()
                    : _buildFotosStep(),
              ),
            ),
          ),

          // Controles de navegação
          _buildControls(),
        ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final isLastStep = _currentStep == 1;
    final isFirstStep = _currentStep == 0;
    final canContinue = _validateCurrentStep();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: OutlinedButton(
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    } else {
                      context.pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: canContinue ? _handleStepContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canContinue ? AppColors.primaryBlue : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isLastStep ? 'Enviar Solicitação' : 'Continuar',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildEnderecoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Container 1: Informações de Localização (até Ponto de Referência)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da seção
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primaryBlue, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Informações de Localização',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divisória
              const Divider(height: 1, color: Colors.grey),
              
              // Opção de usar localização atual
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Usar minha localização atual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Switch(
                      value: _usarLocalizacaoAtual,
                      onChanged: (value) {
                        setState(() {
                          _usarLocalizacaoAtual = value;
                          if (value) {
                            _obterLocalizacaoAtual();
                          } else {
                            _limparCamposEndereco();
                          }
                        });
                      },
                      activeThumbColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
              
              // Divisória
              const Divider(height: 1, color: Colors.grey),
              
              // Seção de endereço
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endereço Completo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // CEP
                    CustomTextField(
                      controller: _cepController,
                      focusNode: _cepFocus,
                      label: 'CEP Brasileiro *',
                      isRequired: true,
                      hint: '00000-000',
                      prefixIcon: FontAwesomeIcons.envelope,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                        _CepInputFormatter(),
                      ],
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_validandoCep) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                                ),
                              ),
                            ),
                          ],
                          if (_cepController.text.length == 9 && !_validandoCep)
                            GestureDetector(
                              onTap: () => _validarCep(),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Buscar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onFieldSubmitted: (_) async {
                        if (_cepController.text.length == 9) {
                          await _validarCep();
                        } else {
                          _enderecoFocus.requestFocus();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Informe o CEP';
                        if (value.length != 9) return 'CEP inválido';
                        if (!_cepValido) return 'CEP brasileiro não validado';
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _cepValido = false;
                        });
                        
                        if (value.length == 9 && !_validandoCep) {
                          Future.delayed(const Duration(milliseconds: 1000), () async {
                            if (_cepController.text.length == 9 && !_cepValido) {
                              await _validarCep();
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Endereço
                    CustomTextField(
                      controller: _enderecoController,
                      focusNode: _enderecoFocus,
                      label: 'Logradouro *',
                      isRequired: true,
                      hint: 'Rua, Avenida, etc.',
                      prefixIcon: FontAwesomeIcons.road,
                      textInputAction: TextInputAction.next,
                      maxLength: 255,
                      onFieldSubmitted: (_) => _numeroFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Informe o logradouro';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Número
                    CustomTextField(
                      controller: _numeroController,
                      focusNode: _numeroFocus,
                      label: 'Número *',
                      isRequired: true,
                      hint: '123',
                      prefixIcon: FontAwesomeIcons.hashtag,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 20,
                      onFieldSubmitted: (_) => _complementoFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Informe o número';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Complemento
                    CustomTextField(
                      controller: _complementoController,
                      focusNode: _complementoFocus,
                      label: 'Complemento',
                      hint: 'Apto, Casa',
                      prefixIcon: FontAwesomeIcons.house,
                      textInputAction: TextInputAction.next,
                      maxLength: 255,
                      onFieldSubmitted: (_) => _bairroFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Bairro
                    CustomTextField(
                      controller: _bairroController,
                      focusNode: _bairroFocus,
                      label: 'Bairro *',
                      isRequired: true,
                      hint: 'Centro',
                      prefixIcon: FontAwesomeIcons.locationDot,
                      textInputAction: TextInputAction.next,
                      maxLength: 100,
                      onFieldSubmitted: (_) => _cidadeFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Informe o bairro';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.flag, color: AppColors.primaryBlue, size: 16),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Estado (UF)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.lightSecondaryText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightBorder, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.lightSurface,
                          ),
                          child: InkWell(
                            onTap: _carregandoLocalizacao ? null : () => _mostrarModalEstado(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _estadoSelecionado != null 
                                          ? '${_estadoSelecionado!.nome} (${_estadoSelecionado!.sigla})'
                                          : 'Selecione o estado',
                                      style: TextStyle(
                                        color: _estadoSelecionado != null 
                                            ? Colors.black
                                            : AppColors.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.grey600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cidade
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.city, color: AppColors.primaryBlue, size: 16),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Cidade',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.lightSecondaryText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightBorder, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.lightSurface,
                          ),
                          child: InkWell(
                            onTap: _carregandoLocalizacao || _cidadesFiltradas.isEmpty ? null : () => _mostrarModalCidade(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _cidadeSelecionada != null 
                                          ? _cidadeSelecionada!.nome
                                          : 'Selecione a cidade',
                                      style: TextStyle(
                                        color: _cidadeSelecionada != null 
                                            ? Colors.black
                                            : AppColors.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.grey600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Referência
                    CustomTextField(
                      controller: _referenciaController,
                      focusNode: _referenciaFocus,
                      label: 'Ponto de Referência',
                      hint: 'Próximo à farmácia, esquina, etc.',
                      prefixIcon: FontAwesomeIcons.mapPin,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Container 2: Descrição do Problema
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Descrição do Problema',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_descricaoController.text.length}/$_maxDescricaoLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: _descricaoController.text.length > _maxDescricaoLength
                            ? AppColors.error
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _descricaoController,
                  hint: 'Descreva detalhadamente o que está acontecendo...',
                  maxLines: 4,
                  maxLength: _maxDescricaoLength,
                  counterText: '',
                  contentPadding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(8),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Descreva o problema';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Container 3: Observações (comentado temporariamente)
        // TODO: Implementar campo de observações conforme requisitos do negócio
        // Este container pode ser reativado quando houver necessidade funcional
        /*
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_add_outlined, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Observações (opcional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _observacaoController,
                  hint: 'Informações adicionais que possam ajudar...',
                  maxLines: 3,
                  maxLength: 1000,
                  contentPadding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
        */
      ],
    );
  }



  Widget _buildFotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Adicione fotos do local (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Máximo de $_maxImagens fotos com até 5MB cada.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        if (_imagens.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _imagens
                .asMap()
                .entries
                .map((entry) => _buildImageItem(entry.value, entry.key))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_imagens.length < _maxImagens) _buildAddImageButton(),
      ],
    );
  }




  Widget _buildImageItem(File image, int index) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.file(
              image,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _imagens.removeAt(index);
                    });
                  }
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: const Center(
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Adicionar Imagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('📷 Câmera'),
              onTap: () async {
                if (mounted) Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              title: const Text('📁 Galeria'),
              onTap: () async {
                if (mounted) Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    if (_imagens.length >= _maxImagens) return;
    
    try {
      final picked = await _picker.pickImage(
        source: source, 
        imageQuality: 80, // 🔥 Qualidade normal para permitir até 5MB
        maxWidth: 1920,   // 🔥 Resolução maior
        maxHeight: 1080,  // 🔥 Resolução maior
      );
      
      if (picked != null && mounted) {
        // 🔥 Verificar tamanho do arquivo
        final file = File(picked.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);
        
        ConsoleLog.debug('Imagem selecionada: ${fileSizeMB.toStringAsFixed(2)}MB');
        
        // 🔥 Limitar a 5MB por imagem
        if (fileSizeMB > 5) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Imagem muito grande. Escolha até 5MB.');
          }
          return;
        }
        
        setState(() {
          _imagens.add(file);
        });
        
        // 🔥 Verificar tamanho total (máximo 15MB para 3 imagens)
        final totalSize = _imagens.fold<int>(0, (sum, img) => sum + img.lengthSync());
        final totalSizeMB = totalSize / (1024 * 1024);
        
        ConsoleLog.debug('Tamanho total: ${totalSizeMB.toStringAsFixed(2)}MB');
        
        if (totalSizeMB > 15) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Total de imagens muito grande. Limite: 15MB.');
          }
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro ao selecionar imagem: $e');
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao selecionar imagem');
      }
    }
  }

  // Mostra diálogo de confirmação antes de criar solicitação
  Future<void> _showCreateConfirmationDialog() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Enviar Solicitação',
      message: 'Deseja enviar esta solicitação para análise? Verifique se todos os dados estão corretos antes de confirmar.',
      icon: Icons.send_outlined,
      iconColor: AppColors.primaryBlue,
      iconBackgroundColor: AppColors.primaryBlue,
      confirmText: 'Enviar',
      confirmColor: AppColors.primaryBlue,
      showWarning: false, // Não é irreversível, apenas envia para análise
    );
    
    if (confirmed == true) {
      _enviarSolicitacao();
    }
  }

  void _handleStepContinue() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      // Última etapa - confirmar antes de enviar
      _showCreateConfirmationDialog();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Endereço
        return _cepController.text.trim().isNotEmpty &&
               _cepController.text.length == 9 &&
               _cepValido &&
               _enderecoController.text.trim().isNotEmpty &&
               _numeroController.text.trim().isNotEmpty &&
               _bairroController.text.trim().isNotEmpty &&
               _estadoSelecionado != null &&
               _cidadeSelecionada != null &&
               _descricaoController.text.trim().isNotEmpty &&
               _descricaoController.text.trim().length <= _maxDescricaoLength;
      case 1: // Fotos
        return true; // Fotos são opcionais
      default:
        return false;
    }
  }

  Future<void> _enviarSolicitacao() async {
    AppLoader.show(context, message: 'Enviando solicitação...');
    
    try {
      setState(() => _isLoading = true);

      // 🔥 VALIDAR TAMANHO TOTAL ANTES DE ENVIAR
      if (_imagens.isNotEmpty) {
        final totalSize = _imagens.fold<int>(0, (sum, img) => sum + img.lengthSync());
        final totalSizeMB = totalSize / (1024 * 1024);
        
        ConsoleLog.debug('Tamanho total antes do envio: ${totalSizeMB.toStringAsFixed(2)}MB');
        
        if (totalSizeMB > 15) { // 🔥 15MB para 3 imagens de 5MB cada
          if (mounted) {
            CustomSnackBar.showError(context, 'Total de imagens muito grande. Reduza o tamanho ou quantidade (máx. 15MB total).');
          }
          return;
        }
      }

      final user = await UserDao().getCurrentUser();
      if (user == null) throw Exception('Usuário não autenticado');

      final resultado = await _solicitacaoServico.criarSolicitacao(
        serviceSlug: widget.dados['slug'] ?? '', //  Enviar service_slug obrigatório
        descricao: _descricaoController.text.trim(),
        observacao: _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        userId: user.id ?? 1,
        latitude: _currentPosition?.latitude.toString(),
        longitude: _currentPosition?.longitude.toString(),
        cep: _cepController.text,
        logradouro: _enderecoController.text,
        numero: _numeroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeSelecionada?.nome ?? _cidadeController.text,
        estado: _estadoSelecionado?.sigla ?? _estadoController.text,
        imagens: _imagens,
      );

      _handleResultado(resultado);
    } catch (e) {
      ConsoleLog.error('Erro ao enviar solicitação: $e');
      if (mounted) {
        CustomSnackBar.showError(context, 'Não foi possível enviar a solicitação. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) AppLoader.hide(context);
    }
  }

  void _handleResultado(Map<String, dynamic> resultado) {
    if (resultado['success'] == true) {
      CustomSnackBar.showSuccess(context, resultado['message'] ?? 'Solicitação enviada com sucesso!');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/');
      });
    } else {
      CustomSnackBar.showError(context, resultado['message'] ?? 'Erro ao processar a solicitação.');
    }
  }

  Future<void> _obterLocalizacaoAtual() async {
    AppLoader.show(context, message: 'Obtendo sua localização...');
    
    try {
      setState(() => _isLoading = true);
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomSnackBar.showError(context, 'Serviço de localização desativado. Ative o GPS nas configurações do dispositivo.');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      await _preencherEnderecoBaseadoNaLocalizacao(position);
      
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Localização obtida com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackBar.showError(context, 'Erro ao obter localização: ${e.toString()}');
      }
    } finally {
      if (mounted) AppLoader.hide(context);
    }
  }

  Future<void> _preencherEnderecoBaseadoNaLocalizacao(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        setState(() {
          // ✅ Tratar diferentes casos de logradouro inválido do GPS
          String? logradouro = place.street;
          
          // Verifica se é nulo, vazio, ou código inválido como "j72h+89"
          if (logradouro == null || 
              logradouro.trim().isEmpty || 
              logradouro.contains('+') || // Códigos do Google Maps
              logradouro.length <= 5 || // Códigos muito curtos
              RegExp(r'^[a-z0-9+]+$').hasMatch(logradouro.toLowerCase())) { // Apenas letras/numeros/+
            
            _enderecoController.text = 'Zona Rural';
          } else {
            _enderecoController.text = logradouro;
          }
          
          _bairroController.text = place.subLocality ?? '';
          final cidadeNome = place.subAdministrativeArea ?? place.locality ?? '';
          _cidadeController.text = cidadeNome;
          final adminArea = place.administrativeArea ?? '';
          final estadoSigla = (adminArea.length > 2) 
              ? adminArea.substring(0, 2).toUpperCase() 
              : adminArea.toUpperCase();
          _estadoController.text = estadoSigla;
          
          // Tentar selecionar estado e cidade nos dropdowns
          if (_estados.isNotEmpty) {
            final estado = _estados.firstWhere(
              (e) => e.sigla.toUpperCase() == estadoSigla.toUpperCase(),
              orElse: () => _estados.first,
            );
            
            // Primeiro seleciona o estado
            _onEstadoSelecionado(estado);
            
            // Aguardar um pouco mais para garantir que as cidades foram carregadas
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_cidadesFiltradas.isNotEmpty) {
                final cidade = _cidadesFiltradas.firstWhere(
                  (c) => c.nome.toUpperCase().contains(cidadeNome.toUpperCase()),
                  orElse: () => _cidadesFiltradas.first,
                );
                // Depois seleciona a cidade
                _onCidadeSelecionada(cidade);
              }
            });
          }
          _cepController.text = place.postalCode ?? '';
        });
        
        // ✅ Verificar automaticamente o CEP preenchido pelo GPS
        final cepPreenchido = place.postalCode ?? '';
        if (cepPreenchido.isNotEmpty) {
          // Aguardar um frame para garantir que o campo foi atualizado
          Future.delayed(const Duration(milliseconds: 500), () async {
            if (mounted && _cepController.text.length == 9) {
              await _validarCep();
            }
          });
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro ao preencher endereço: $e');
    }
  }

  void _limparCamposEndereco() {
    setState(() {
      _cepController.clear();
      _enderecoController.clear();
      _numeroController.clear();
      _complementoController.clear();
      _bairroController.clear();
      _cidadeController.clear();
      _estadoController.clear();
      _referenciaController.clear();
      // Só limpar posição se não tiver CEP válido (ou seja, se não for desativação da localização atual)
      if (!_cepValido) {
        _currentPosition = null;
      }
      _cepValido = false;
      
      // Limpar dropdowns
      setState(() {
        _estadoSelecionado = null;
        _cidadeSelecionada = null;
        _cidadesFiltradas = [];
      });
    });
  }

  Future<void> _validarCep() async {
    if (_cepController.text.length != 9) return;
    
    AppLoader.show(context, message: 'Validando CEP...');
    setState(() => _validandoCep = true);
    
    try {
      final ehValido = await CepService.validarCepBrasileiro(_cepController.text);
      
      if (ehValido) {
        final endereco = await CepService.buscarEndereco(_cepController.text);
        
        if (endereco != null) {
          setState(() {
            // Só preencher se a API retornou dados válidos (não vazios)
            if (endereco['logradouro'] != null && endereco['logradouro']!.isNotEmpty) {
              _enderecoController.text = endereco['logradouro']!;
            }
            if (endereco['bairro'] != null && endereco['bairro']!.isNotEmpty) {
              _bairroController.text = endereco['bairro']!;
            }
            if (endereco['cidade'] != null && endereco['cidade']!.isNotEmpty) {
              _cidadeController.text = endereco['cidade']!;
            }
            if (endereco['estado'] != null && endereco['estado']!.isNotEmpty) {
              _estadoController.text = endereco['estado']!;
            }
            
            // Tentar selecionar estado e cidade nos dropdowns
            if (_estados.isNotEmpty && endereco['estado'] != null && endereco['estado']!.isNotEmpty) {
              final estadoSigla = endereco['estado']!;
              final estado = _estados.firstWhere(
                (e) => e.sigla.toUpperCase() == estadoSigla.toUpperCase(),
                orElse: () => _estados.first,
              );
              
              // Primeiro seleciona o estado
              _onEstadoSelecionado(estado);
              
              // Aguardar um pouco mais para garantir que as cidades foram carregadas
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_cidadesFiltradas.isNotEmpty && endereco['cidade'] != null && endereco['cidade']!.isNotEmpty) {
                  final cidadeNome = endereco['cidade']!;
                  final cidade = _cidadesFiltradas.firstWhere(
                    (c) => c.nome.toUpperCase().contains(cidadeNome.toUpperCase()),
                    orElse: () => _cidadesFiltradas.first,
                  );
                  // Depois seleciona a cidade
                  _onCidadeSelecionada(cidade);
                }
              });
            }
          _cepValido = true;
          });
          
          // Obter coordenadas da cidade apenas se não estiver usando localização atual
          if (!_usarLocalizacaoAtual && endereco['cidade'] != null && endereco['estado'] != null) {
            await _obterCoordenadasDaCidade(endereco['cidade']!, endereco['estado']!);
          }

          if (mounted) {
            CustomSnackBar.showSuccess(context, '✅ CEP brasileiro válido! Endereço preenchido.');
          }
          
          _numeroFocus.requestFocus();
        } else {
          setState(() => _cepValido = false);
          if (mounted) {
            CustomSnackBar.showInfo(context, '❌ CEP encontrado mas sem endereço completo.');
          }
        }
      } else {
        setState(() => _cepValido = false);
        if (mounted) {
          CustomSnackBar.showError(context, '❌ CEP brasileiro inválido ou não encontrado.');
        }
      }
    } catch (e) {
      setState(() => _cepValido = false);
      if (mounted) {
        CustomSnackBar.showError(context, '❌ Erro: ${e.toString()}');
      }
    } finally {
      setState(() => _validandoCep = false);
      if (mounted) AppLoader.hide(context);
    }
  }

  Future<void> _obterCoordenadasDaCidade(String cidade, String estado) async {
    try {
      ConsoleLog.debug('Obtendo coordenadas da cidade: $cidade, $estado');
      
      // Montar o endereço para geocoding
      final address = '$cidade, $estado, Brasil';
      
      // Usar geocoding para obter coordenadas
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _currentPosition = Position(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        });
        ConsoleLog.debug('Coordenadas obtidas com sucesso: ${location.latitude}, ${location.longitude}');
      } else {
        ConsoleLog.debug('Nenhuma coordenada encontrada para: $address');
      }
    } catch (e) {
      ConsoleLog.error('Erro ao obter coordenadas da cidade: $e');
    }
  }

    void _showStepSelector(BuildContext context) {
    final stepTitles = ['ENDEREÇO', 'ANEXOS'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ir para etapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) {
                  final isCurrent = index == _currentStep;
                  final isCompleted = index < _currentStep;
                  final canAccess = index < _currentStep || 
                                   (index == _currentStep + 1 && _validateCurrentStep());

                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primaryBlue
                            : isCurrent
                                ? AppColors.primaryBlue.withValues(alpha: 0.2)
                                : canAccess
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: isCurrent
                            ? Border.all(color: AppColors.primaryBlue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? AppColors.primaryBlue
                                      : canAccess
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      stepTitles[index],
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent || isCompleted
                            ? AppColors.primaryBlue
                            : canAccess
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue, size: 16)
                        : !canAccess
                            ? Icon(Icons.lock, color: Colors.grey.shade400, size: 16)
                            : null,
                    onTap: () {
                      // Só permite navegar se:
                      // 1. For uma etapa anterior (já concluída)
                      // 2. For a próxima etapa (e a atual estiver válida)
                      if (index < _currentStep || 
                          (index == _currentStep + 1 && _validateCurrentStep())) {
                        Navigator.pop(context);
                        setState(() => _currentStep = index);
                      } else {
                        // Mostra mensagem explicativa
                        Navigator.pop(context);
                        CustomSnackBar.showInfo(context, index > _currentStep 
                            ? 'Complete a etapa atual antes de avançar'
                            : 'Etapa anterior já preenchida. Use o botão Voltar.');
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}