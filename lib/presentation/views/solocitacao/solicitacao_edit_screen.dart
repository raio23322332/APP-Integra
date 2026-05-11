// presentation/views/solocitacao/solicitacao_edit_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/models/estado_model.dart';
import 'package:integra_app/core/models/cidade_model.dart';
import 'package:integra_app/data/models/solicitacao_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/helpers/console_log.dart';
import '../../../services/http/solicitacao_edicao_http.dart';
import '../../../services/cep/cep_service.dart';
import '../../widgets/shared/custom_snack_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/selection_modal.dart';
import '../../widgets/common/app_loader.dart';
import 'package:integra_app/widgets/dialogs/confirmation_dialog.dart';
import '../../../core/constants/tipos_constants.dart';
import '../../../core/models/tipo_model.dart';

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

class SolicitacaoEditScreen extends StatefulWidget {
  final SolicitacaoModel solicitacao;

  const SolicitacaoEditScreen({super.key, required this.solicitacao});

  @override
  State<SolicitacaoEditScreen> createState() => _SolicitacaoEditScreenState();
}

class _SolicitacaoEditScreenState extends State<SolicitacaoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Stepper
  int _currentStep = 0;
  
  // Dados da solicitação
  Map<String, dynamic> _dados = {};
  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _complementoController = TextEditingController();
  final _referenciaController = TextEditingController();

  // Focus nodes
  final _cepFocus = FocusNode();
  final _logradouroFocus = FocusNode();
  final _numeroFocus = FocusNode();
  final _bairroFocus = FocusNode();
  final _cidadeFocus = FocusNode();
  final _complementoFocus = FocusNode();
  final _referenciaFocus = FocusNode();

  // Estado
  bool _usarLocalizacaoAtual = false;
  bool _isLoading = false;
  bool _validandoCep = false;
  bool _cepValido = false;
  bool _carregandoLocalizacao = false;
  Position? _currentPosition;

  String? _estadoSelecionado;
  List<Estado> _estados = [];
  List<Cidade> _cidades = [];
  List<Cidade> _cidadesFiltradas = [];
  Estado? _estadoSelecionadoObj;
  Cidade? _cidadeSelecionada;
  
  // final List<String> _estados = [ // Não utilizado atualmente
  //   'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG',
  //   'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  // ];

  final List<File> _novasImagens = [];

  // Cores padronizadas - removidas em favor de AppColors

  // Controle de imagens
  List<String> get _imagensExistentes {
    if (widget.solicitacao.arquivos == null) return [];
    return widget.solicitacao.arquivos!
        .where((arquivo) => arquivo.url != null && arquivo.url!.isNotEmpty)
        .map((arquivo) => arquivo.url!)
        .toList();
  }

  // IDs das imagens que serão removidas
  final List<String> _imagensParaRemover = [];

  // Calcula total de imagens (existentes + novas - removidas)
  int get _totalImagens {
    return _imagensExistentes.length + _novasImagens.length - _imagensParaRemover.length;
  }

  @override
  void initState() {
    super.initState();
    _initializeDados();
    _initializeFields();
    _carregarEstadosECidades();
  }

  void _initializeDados() {
    _dados = {
      'tipo': _getNomeTipo(widget.solicitacao.tipoId ?? ''),
      'subtipo': widget.solicitacao.subtipo?.descricao ?? '',
      'subtipoId': widget.solicitacao.subtipoId ?? '',
    };
  }

  String _getSlugFromTipoId(String tipoId) {
    try {
      final tipo = TiposConstants.data.firstWhere(
        (tipo) => tipo.id.toString() == tipoId,
        orElse: () => TipoModel.empty(),
      );
      return tipo.slug ?? '';
    } catch (e) {
      ConsoleLog.error('Erro ao obter slug do tipoId $tipoId: $e');
      return '';
    }
  }

  String _getNomeTipo(String tipoId) {
    try {
      final tipo = TiposConstants.data.firstWhere(
        (tipo) => tipo.id.toString() == tipoId,
        orElse: () => TipoModel.empty(),
      );
      return tipo.descricao ?? '';
    } catch (e) {
      ConsoleLog.error('Erro ao obter nome do tipoId $tipoId: $e');
      return '';
    }
  }

  Future<void> _carregarEstadosECidades() async {
    try {
      // Carregar estados
      final estadosResponse = await rootBundle.loadString('js/Estados.json');
      final estadosData = jsonDecode(estadosResponse) as List;
      _estados = estadosData.map((json) => Estado.fromJson(json)).toList();
      
      // Carregar cidades
      final cidadesResponse = await rootBundle.loadString('js/Cidades.json');
      final cidadesData = jsonDecode(cidadesResponse) as List;
      _cidades = cidadesData.map((json) => Cidade.fromJson(json)).toList();
      
      // Se já tiver estado selecionado, filtrar cidades
      if (_estadoSelecionado != null) {
        _estadoSelecionadoObj = _estados.firstWhere(
          (estado) => estado.sigla == _estadoSelecionado,
          orElse: () => _estados.first,
        );
        _cidadesFiltradas = _cidades
            .where((cidade) => cidade.estadoId == _estadoSelecionadoObj!.id)
            .toList();
        
        // Se tiver cidade, selecionar
        if (_cidadeController.text.isNotEmpty) {
          _cidadeSelecionada = _cidadesFiltradas
              .where((cidade) => cidade.nome.toLowerCase() == _cidadeController.text.toLowerCase())
              .firstOrNull;
        }
      }
      
      setState(() {});
    } catch (e) {
      ConsoleLog.error('Erro ao carregar estados e cidades: $e');
    }
  }

  void _initializeFields() {
    _descricaoController.text = widget.solicitacao.descricao ?? '';
    _observacaoController.text = widget.solicitacao.observacao ?? '';

    final endereco = widget.solicitacao.enderecos?.isNotEmpty == true
        ? widget.solicitacao.enderecos!.first
        : null;

    if (endereco != null) {
      _cepController.text = endereco.cep;
      _logradouroController.text = endereco.logradouro;
      _numeroController.text = endereco.numero;
      _bairroController.text = endereco.bairro;
      _cidadeController.text = endereco.cidade;
      _estadoSelecionado = endereco.estado;
      _complementoController.text = endereco.complemento ?? '';
      
      // Se já tiver CEP válido, marca como validado
      if (_cepController.text.length == 9) {
        _cepValido = true;
      }
    }
    
    // Carregar coordenadas existentes da solicitação
    if (widget.solicitacao.latitude != null && widget.solicitacao.longitude != null) {
      try {
        final lat = double.parse(widget.solicitacao.latitude!);
        final lng = double.parse(widget.solicitacao.longitude!);
        setState(() {
          _currentPosition = Position(
            latitude: lat,
            longitude: lng,
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
        ConsoleLog.debug('Coordenadas existentes carregadas: $lat, $lng');
      } catch (e) {
        ConsoleLog.error('Erro ao carregar coordenadas existentes: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTitles = ['ENDEREÇO', 'ANEXOS'];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Editar Solicitação'),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          tooltip: 'Voltar',
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () => Navigator.of(context).pop(),
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
      body: Column(
        children: [
          // Stepper compacto no topo
          GestureDetector(
            onTap: () {
              // Permitir navegação rápida para qualquer etapa
              _showStepSelector(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(2, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.primaryBlue
                                  : isCurrent
                                      ? AppColors.primaryBlue
                                      : Colors.grey.shade300,
                              border: isCurrent
                                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Icon(
                                      [
                                        Icons.layers_outlined,
                                        Icons.location_on_outlined,
                                        Icons.image_outlined
                                      ][index],
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      size: 20,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 70,
                            child: Text(
                              stepTitles[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent || isCompleted
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Connecting line (only between steps, not after last)
                      if (index < 2) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 30,
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
          // Conteúdo da etapa atual
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                color: AppColors.lightBackground,
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(6),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: _currentStep == 0
                          ? _buildEnderecoStep()
                          : _buildFotosStep(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Botões de navegação
          _buildControls(),
        ],
      ),
    );
  }

  
  Widget _buildEnderecoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEnderecoCard(),
        const SizedBox(height: 16),
        _buildDescricaoCard(),
        const SizedBox(height: 16),
        // Campo de observações comentado temporariamente
        // TODO: Implementar campo de observações conforme requisitos do negócio
        // Este container pode ser reativado quando houver necessidade funcional
        /*
        _buildObservacaoCard(),
        */
      ],
    );
  }

  Widget _buildFotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImagensCard(),
      ],
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
                      Navigator.of(context).pop();
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
                      isLastStep ? 'Salvar Alterações' : 'Continuar',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostra diálogo de confirmação antes de salvar solicitação
  Future<void> _showSaveConfirmationDialog() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Salvar Alterações',
      message: 'Deseja salvar as alterações desta solicitação? Verifique se todas as modificações estão corretas antes de confirmar.',
      icon: Icons.save_outlined,
      iconColor: AppColors.primaryBlue,
      iconBackgroundColor: AppColors.primaryBlue,
      confirmText: 'Salvar',
      confirmColor: AppColors.primaryBlue,
      showWarning: false, // Não é irreversível, apenas salva as alterações
    );
    
    if (confirmed == true) {
      _saveSolicitacao();
    }
  }

  void _handleStepContinue() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      // Última etapa - confirmar antes de salvar
      _showSaveConfirmationDialog();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Endereço
        return _formKey.currentState?.validate() ?? false;
      case 1: // Fotos
        return true; // Fotos são opcionais
      default:
        return false;
    }
  }

  void _showStepSelector(BuildContext context) {
    final stepTitles = ['ENDEREÇO', 'ANEXOS'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecionar Etapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              itemCount: 2,
              itemBuilder: (context, index) {
                final isCurrent = index == _currentStep;
                final isCompleted = index < _currentStep;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primaryBlue
                          : isCurrent
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                          : Colors.grey.shade600,
                    ),
                  ),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Atual',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : isCompleted
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryBlue,
                              size: 20,
                            )
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            index > _currentStep 
                                ? 'Complete a etapa atual antes de avançar'
                                : 'Esta etapa não está disponível',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDescricaoCard() {
    return Container(
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
                  '${_descricaoController.text.length}/500',
                  style: TextStyle(
                    fontSize: 12,
                    color: _descricaoController.text.length > 500
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
              maxLength: 500,
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
    );
  }

  Widget _buildEnderecoCard() {
    return Container(
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
                      _logradouroFocus.requestFocus();
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
                  controller: _logradouroController,
                  focusNode: _logradouroFocus,
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
                                  _estadoSelecionadoObj != null 
                                      ? '${_estadoSelecionadoObj!.nome} (${_estadoSelecionadoObj!.sigla})'
                                      : 'Selecione o estado',
                                  style: TextStyle(
                                    color: _estadoSelecionadoObj != null 
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

                // Ponto de Referência
                CustomTextField(
                  controller: _referenciaController,
                  focusNode: _referenciaFocus,
                  label: 'Ponto de Referência',
                  hint: 'Próximo ao...',
                  prefixIcon: FontAwesomeIcons.mapLocationDot,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildObservacaoCard() {
    return Container(
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
              maxLength: 1000,
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildImagensCard() {
    return _buildCard(
      title: 'Imagens',
      icon: Icons.photo_library,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imagens existentes (${_imagensExistentes.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (_imagensExistentes.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.solicitacao.arquivos!.map((arquivo) {
                final imageUrl = arquivo.url ?? '';
                final seraRemovida = _imagensParaRemover.contains(arquivo.id);
                
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: seraRemovida ? Colors.red : AppColors.lightBorder,
                          width: seraRemovida ? 2 : 1,
                        ),
                        color: seraRemovida ? Colors.red.withValues(alpha: 0.1) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                            if (seraRemovida)
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                child: const Center(
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (seraRemovida) {
                              _imagensParaRemover.remove(arquivo.id);
                              ConsoleLog.informacao('✅ Imagem ${arquivo.id} restaurada');
                            } else {
                              _imagensParaRemover.add(arquivo.id);
                              ConsoleLog.informacao('❌ Imagem ${arquivo.id} marcada para remoção');
                            }
                            ConsoleLog.informacao('📋 Imagens para remover: ${_imagensParaRemover.length}');
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: seraRemovida ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            seraRemovida ? Icons.undo : Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    if (seraRemovida)
                      Positioned(
                        bottom: 2,
                        left: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Será removida',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          if (_imagensExistentes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Nenhuma imagem existente',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 20),
          
          Text(
            'Adicionar novas imagens ($_totalImagens/5)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (_novasImagens.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _novasImagens.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryBlue),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () {
                          ConsoleLog.informacao('🗑️ Removendo nova imagem $index: ${image.path}');
                          setState(() {
                            _novasImagens.removeAt(index);
                            ConsoleLog.informacao('✅ Nova imagem removida. Restantes: ${_novasImagens.length}');
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _totalImagens >= 5 ? null : _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_totalImagens >= 5 ? 'Limite atingido (5/5)' : 'Adicionar Nova Imagem'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: _totalImagens >= 5 ? Colors.grey : AppColors.primaryBlue),
                foregroundColor: _totalImagens >= 5 ? Colors.grey : AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }


  Future<void> _saveSolicitacao() async {
    ConsoleLog.informacao('=== INÍCIO DO _saveSolicitacao ===');
    ConsoleLog.informacao('Widget solicitacao: ${widget.solicitacao}');
    ConsoleLog.informacao('Widget solicitacao id: ${widget.solicitacao.id}');
    ConsoleLog.informacao('Widget solicitacao tipoId: ${widget.solicitacao.tipoId}');
    
    if (!_formKey.currentState!.validate()) {
      ConsoleLog.informacao('Formulário inválido, retornando');
      return;
    }

    AppLoader.show(context, message: 'Salvando alterações...');
    setState(() => _isLoading = true);

    try {
      ConsoleLog.informacao('=== USANDO NOVO SERVIÇO DE EDIÇÃO ===');
      ConsoleLog.informacao('Solicitacao ID: ${widget.solicitacao.id}');
      ConsoleLog.informacao('TipoId: ${widget.solicitacao.tipoId}');
      ConsoleLog.informacao('SubtipoId: ${widget.solicitacao.subtipoId}');
      
      // Obter service_slug diretamente do campo service da API
      String serviceSlug = '';
      
      // 1. Tentar obter do service.slug (campo correto da API)
      if (widget.solicitacao.service?.slug != null) {
        serviceSlug = widget.solicitacao.service!.slug!;
        ConsoleLog.informacao('Service slug do service.slug: $serviceSlug');
      }
      
      // 2. Fallback - tentar do subtipo (método original)
      if (serviceSlug.isEmpty && widget.solicitacao.subtipo?.tipoId != null) {
        serviceSlug = _getSlugFromTipoId(widget.solicitacao.subtipo!.tipoId!);
        ConsoleLog.informacao('Service slug do subtipo: $serviceSlug');
      }
      
      // 3. Fallback - tentar do tipoId da solicitação
      if (serviceSlug.isEmpty && widget.solicitacao.tipoId != null) {
        serviceSlug = _getSlugFromTipoId(widget.solicitacao.tipoId!);
        ConsoleLog.informacao('Service slug do tipoId: $serviceSlug');
      }
      
      // 4. Último recurso - usar um valor padrão baseado no subtipo
      if (serviceSlug.isEmpty && widget.solicitacao.subtipo?.descricao != null) {
        final desc = widget.solicitacao.subtipo!.descricao!.toLowerCase();
        if (desc.contains('ilumina')) serviceSlug = 'iluminacao-publica';
        else if (desc.contains('limpeza')) serviceSlug = 'limpeza-urbana';
        else if (desc.contains('paviment')) serviceSlug = 'vias-publicas';
        else if (desc.contains('árvore') || desc.contains('arvore')) serviceSlug = 'arborizacao';
        else if (desc.contains('água') || desc.contains('agua')) serviceSlug = 'abastecimento-agua';
        else if (desc.contains('esgoto')) serviceSlug = 'esgoto-sanitario';
        else serviceSlug = 'outros';
        ConsoleLog.informacao('Service slug por descrição: $serviceSlug');
      }
      
      ConsoleLog.informacao('Service Slug final: "$serviceSlug"');
      
      // Validar se o service_slug foi encontrado
      if (serviceSlug.isEmpty) {
        throw Exception('Não foi possível identificar o serviço da solicitação. TipoId: ${widget.solicitacao.tipoId}, Subtipo: ${widget.solicitacao.subtipo?.descricao}');
      }
      
      ConsoleLog.informacao('Novas imagens: ${_novasImagens.length}');
      ConsoleLog.informacao('Imagens para remover: ${_imagensParaRemover.length}');

      final edicaoHttp = SolicitacaoEdicaoHttp();
      
      final response = await edicaoHttp.editarSolicitacao(
        solicitacaoId: int.parse(widget.solicitacao.id),
        serviceSlug: serviceSlug,
        descricao: _descricaoController.text.trim(),
        observacao: _observacaoController.text.trim().isEmpty 
            ? null 
            : _observacaoController.text.trim(),
        status: widget.solicitacao.status,
        cep: _cepController.text.trim().isEmpty ? null : _cepController.text.trim(),
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim().isEmpty 
            ? null 
            : _complementoController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _estadoSelecionado ?? '',
        latitude: _currentPosition?.latitude.toString() ?? widget.solicitacao.latitude,
        longitude: _currentPosition?.longitude.toString() ?? widget.solicitacao.longitude,
        imagens: _novasImagens.isNotEmpty ? _novasImagens : null,
        imagensParaRemover: _imagensParaRemover.isNotEmpty ? _imagensParaRemover : null,
      );

      ConsoleLog.informacao('Status Code: ${response.statusCode}');
      ConsoleLog.informacao('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Solicitação atualizada com sucesso!');
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ConsoleLog.error('Erro ao salvar solicitação: $e');
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao atualizar solicitação: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        AppLoader.hide(context);
      }
    }
  }

  Future<void> _validarCep() async {
    if (_cepController.text.length != 9) {
      return;
    }

    AppLoader.show(context, message: 'Validando CEP...');
    setState(() {
      _validandoCep = true;
    });

    try {
      final endereco = await CepService.buscarEndereco(_cepController.text);
      
      if (endereco != null && mounted) {
        setState(() {
          _logradouroController.text = endereco['logradouro'] ?? '';
          _bairroController.text = endereco['bairro'] ?? '';
          _cidadeController.text = endereco['cidade'] ?? '';
          final estadoSigla = endereco['estado'] ?? '';
          _estadoSelecionado = estadoSigla;
          _cepValido = true;
          
          // Se tiver estados carregados, tentar selecionar o estado correspondente
          if (_estados.isNotEmpty) {
            final estado = _estados.firstWhere(
              (e) => e.sigla.toUpperCase() == estadoSigla.toUpperCase(),
              orElse: () => _estados.first,
            );
            
            _onEstadoSelecionado(estado);
            
            // Se tiver cidade, tentar selecionar
            if (endereco['cidade'] != null && endereco['cidade']!.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 300), () {
                final cidade = _cidadesFiltradas
                    .where((c) => c.nome.toLowerCase() == endereco['cidade']!.toLowerCase())
                    .firstOrNull;
                if (cidade != null) {
                  _onCidadeSelecionada(cidade);
                }
              });
            }
          }
        });
        
        // Obter coordenadas da cidade apenas se não estiver usando localização atual
        if (!_usarLocalizacaoAtual && endereco['cidade'] != null && endereco['estado'] != null) {
          await _obterCoordenadasDaCidade(endereco['cidade']!, endereco['estado']!);
        }
        
        if (mounted) {
          CustomSnackBar.showSuccess(context, 'CEP validado com sucesso!');
        }
      } else {
        if (mounted) {
          setState(() {
            _cepValido = false;
          });
          CustomSnackBar.showError(context, 'CEP não encontrado. Verifique o número digitado.');
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro ao validar CEP: $e');
      if (mounted) {
        setState(() {
          _cepValido = false;
        });
        CustomSnackBar.showError(context, 'Erro ao validar CEP. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _validandoCep = false;
        });
        AppLoader.hide(context);
      }
    }
  }

  Future<void> _pickImage() async {
    if (_totalImagens >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Limite máximo de 5 imagens atingido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _showImagePicker();
  }

  void _showImagePicker() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Adicionar Imagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                title: const Text('� Câmera'),
                onTap: () async {
                  if (mounted) Navigator.pop(context);
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                title: const Text('📁 Galeria'),
                onTap: () async {
                  if (mounted) Navigator.pop(context);
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    if (_totalImagens >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Limite máximo de 5 imagens atingido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    ConsoleLog.informacao('�🔍 Iniciando seleção de imagem da fonte: $source...');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80, // 🔥 Qualidade normal para permitir até 5MB
      maxWidth: 1920,   // 🔥 Resolução maior
      maxHeight: 1080,  // 🔥 Resolução maior
    );
    
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      ConsoleLog.informacao('✅ Imagem selecionada: ${image.path}');
      ConsoleLog.informacao('✅ Fonte: $source');
      ConsoleLog.informacao('✅ Tamanho: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      setState(() {
        _novasImagens.add(file);
        ConsoleLog.informacao('🔄 setState chamado. Total de imagens: ${_novasImagens.length}');
      });
      
      ConsoleLog.informacao('✅ Imagem adicionada à lista. Total: ${_novasImagens.length}');
    } else {
      ConsoleLog.informacao('❌ Nenhuma imagem selecionada');
    }
  }

  Future<void> _obterLocalizacaoAtual() async {
    AppLoader.show(context, message: 'Obtendo sua localização...');
    setState(() => _carregandoLocalizacao = true);
    
    try {
      ConsoleLog.informacao('📍 Obtendo localização atual...');
      
      // Verificar permissão de localização
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Serviço de localização desativado');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Permissão de localização negada');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Permissão de localização permanentemente negada');
        }
        return;
      }

      // Obter posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Obter endereço a partir da coordenada
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        
        setState(() {
          // Tratar diferentes casos de logradouro inválido do GPS
          String? logradouro = place.street;
          
          // Verifica se é nulo, vazio, ou código inválido como "j72h+89"
          if (logradouro == null || 
              logradouro.trim().isEmpty || 
              logradouro.contains('+') || // Códigos do Google Maps
              logradouro.length <= 5 || // Códigos muito curtos
              RegExp(r'^[a-z0-9+]+$').hasMatch(logradouro.toLowerCase())) { // Apenas letras/numeros/+
          
            _logradouroController.text = 'Zona Rural';
          } else {
            _logradouroController.text = logradouro;
          }
          
          _bairroController.text = place.subLocality ?? '';
          final cidadeNome = place.subAdministrativeArea ?? place.locality ?? '';
          _cidadeController.text = cidadeNome;
          final adminArea = place.administrativeArea ?? '';
          final estadoSigla = (adminArea.length > 2) 
              ? adminArea.substring(0, 2).toUpperCase() 
              : adminArea.toUpperCase();
          _estadoSelecionado = estadoSigla;
          
          // Se tiver estados carregados, tentar selecionar o estado correspondente
          if (_estados.isNotEmpty) {
            final estado = _estados.firstWhere(
              (e) => e.sigla.toUpperCase() == estadoSigla.toUpperCase(),
              orElse: () => _estados.first,
            );
            
            _onEstadoSelecionado(estado);
            
            // Se tiver cidade, tentar selecionar
            if (cidadeNome.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 300), () {
                final cidade = _cidadesFiltradas
                    .where((c) => c.nome.toLowerCase() == cidadeNome.toLowerCase())
                    .firstOrNull;
                if (cidade != null) {
                  _onCidadeSelecionada(cidade);
                }
              });
            }
          }
          
          // Se tiver CEP, marca como válido
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            _cepController.text = place.postalCode!;
            if (_cepController.text.length == 9) {
              _cepValido = true;
            }
          }
        });
        
        CustomSnackBar.showSuccess(context, 'Localização obtida com sucesso!');
        ConsoleLog.informacao('📍 Localização obtida: ${place.street}, ${place.locality}');
      }
    } catch (e) {
      ConsoleLog.error('Erro ao obter localização: $e');
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao obter localização: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoLocalizacao = false);
        AppLoader.hide(context);
      }
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

  void _limparCamposEndereco() {
    setState(() {
      _cepController.clear();
      _logradouroController.clear();
      _numeroController.clear();
      _complementoController.clear();
      _bairroController.clear();
      _cidadeController.clear();
      _referenciaController.clear();
      _estadoSelecionado = null;
      _estadoSelecionadoObj = null;
      _cidadeSelecionada = null;
      _cidadesFiltradas = [];
      // Só limpar posição se não tiver CEP válido (ou seja, se não for desativação da localização atual)
      if (!_cepValido) {
        _currentPosition = null;
      }
      _cepValido = false;
    });
  }

  void _onEstadoSelecionado(Estado? estado) {
    setState(() {
      _estadoSelecionadoObj = estado;
      _cidadeSelecionada = null;
      _cidadesFiltradas = [];
      
      if (estado != null) {
        _estadoSelecionado = estado.sigla;
        _cidadesFiltradas = _cidades
            .where((cidade) => cidade.estadoId == estado.id)
            .toList();
      } else {
        _estadoSelecionado = null;
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
}
