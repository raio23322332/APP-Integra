import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/helpers/console_log.dart';
import '../../../data/dao/user_dao.dart';
import '../../../services/solicitacao/solicitacao_servico.dart';
import '../../../services/cep/cep_service.dart';
import 'package:integra_app/presentation/widgets/solicitacoes/cep_input_field.dart';
import 'package:integra_app/presentation/widgets/solicitacoes/address_input_fields.dart';
import 'package:integra_app/presentation/widgets/solicitacoes/description_input_fields.dart';
import '../../widgets/common/breadcrumb_widget.dart';
import '../../../core/models/breadcrumb_model.dart';
import '../../providers/breadcrumb_provider.dart';
import 'package:provider/provider.dart';

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
  final bool _validandoCep = false;
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
      return Icons.assignment;
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Adicionar listeners para atualizar o estado quando os campos forem preenchidos
    _cepController.addListener(() => setState(() {}));
    _enderecoController.addListener(() => setState(() {}));
    _numeroController.addListener(() => setState(() {}));
    _bairroController.addListener(() => setState(() {}));
    _cidadeController.addListener(() => setState(() {}));
    _estadoController.addListener(() => setState(() {}));
    _descricaoController.addListener(() => setState(() {}));
    
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
          // BREADCRUMB
          Align(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: BreadcrumbWidget(),
            ),
          ),
          // Stepper
          _buildStepper(stepTitles),
          // Conteúdo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepContent(),
            ),
          ),
          // Controles
          _buildControls(),
        ],
        ),
      ),
    );
  }

  Widget _buildStepper(List<String> stepTitles) {
    return GestureDetector(
      onTap: () => _showStepSelector(context),
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
                _buildStepCircle(index, isCompleted, isCurrent, canAccess),
                _buildStepTitle(index, isCompleted, isCurrent, canAccess, stepTitles[index]),
                if (index < 1) ...[
                  const SizedBox(width: 8),
                  _buildConnectingLine(index),
                  const SizedBox(width: 8),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int index, bool isCompleted, bool isCurrent, bool canAccess) {
    return Column(
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
                    [Icons.location_on_outlined, Icons.image_outlined][index],
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
      ],
    );
  }

  Widget _buildStepTitle(int index, bool isCompleted, bool isCurrent, bool canAccess, String title) {
    return SizedBox(
      width: 70,
      child: Text(
        title,
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
    );
  }

  Widget _buildConnectingLine(int index) {
    return Container(
      width: 35,
      height: 2,
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        color: index < _currentStep - 1
            ? AppColors.primaryBlue
            : index == _currentStep - 1
                ? AppColors.primaryBlue
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildEnderecoStep();
      case 1:
        return _buildFotosStep();
      default:
        return Container();
    }
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
            TextButton(
              onPressed: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  context.pop();
                }
              },
              child: const Text('Voltar'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: canContinue ? _handleStepContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isLastStep ? 'Enviar' : 'Continuar'),
          ),
        ],
      ),
    );
  }

  
  Widget _buildEnderecoStep() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationHeader(),
          const SizedBox(height: 20),
          _buildLocationToggle(),
          const SizedBox(height: 20),
          _buildAddressTitle(),
          const SizedBox(height: 16),
          
          // CEP Input Componentizado
          CepInputField(
            controller: _cepController,
            focusNode: _cepFocus,
            nextFocusNode: _enderecoFocus,
            onCepValidated: (cep) {
              setState(() {
                _cepValido = true;
              });
              _preencherEnderecoAutomatico(cep);
              return true;
            },
          ),
          const SizedBox(height: 16),

          // Campos de Endereço Componentizados
          AddressInputFields(
            enderecoController: _enderecoController,
            numeroController: _numeroController,
            complementoController: _complementoController,
            bairroController: _bairroController,
            cidadeController: _cidadeController,
            estadoController: _estadoController,
            referenciaController: _referenciaController,
            enderecoFocus: _enderecoFocus,
            numeroFocus: _numeroFocus,
            complementoFocus: _complementoFocus,
            bairroFocus: _bairroFocus,
            cidadeFocus: _cidadeFocus,
            estadoFocus: _estadoFocus,
            referenciaFocus: _referenciaFocus,
          ),
          const SizedBox(height: 24),

          // Campos de Descrição Componentizados
          DescriptionInputFields(
            descricaoController: _descricaoController,
            observacaoController: _observacaoController,
            maxDescricaoLength: _maxDescricaoLength,
            onDescricaoChanged: (_) => setState(() {}),
            onObservacaoChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Text(
            'Informações de Localização',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildAddressTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        'Endereço Completo',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
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
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (picked != null && mounted) {
        final file = File(picked.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);
        
        ConsoleLog.debug('Imagem selecionada: ${fileSizeMB.toStringAsFixed(2)}MB');
        
        if (fileSizeMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imagem muito grande. Escolha até 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        setState(() {
          _imagens.add(file);
        });
        
        final totalSize = _imagens.fold<int>(0, (sum, img) => sum + img.lengthSync());
        final totalSizeMB = totalSize / (1024 * 1024);
        
        ConsoleLog.debug('Tamanho total: ${totalSizeMB.toStringAsFixed(2)}MB');
        
        if (totalSizeMB > 15) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Total de imagens muito grande. Limite: 15MB.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao selecionar imagem')),
        );
      }
    }
  }

  void _handleStepContinue() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      _enviarSolicitacao();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _cepController.text.trim().isNotEmpty &&
               _cepController.text.length == 9 &&
               _cepValido &&
               _enderecoController.text.trim().isNotEmpty &&
               _numeroController.text.trim().isNotEmpty &&
               _bairroController.text.trim().isNotEmpty &&
               _cidadeController.text.trim().isNotEmpty &&
               _estadoController.text.trim().length == 2 &&
               _descricaoController.text.trim().isNotEmpty &&
               _descricaoController.text.trim().length <= _maxDescricaoLength;
      case 1:
        return true; // Fotos são opcionais
      default:
        return false;
    }
  }

  Future<void> _enviarSolicitacao() async {
    try {
      setState(() => _isLoading = true);

      final user = await UserDao().getCurrentUser();
      if (user == null) throw Exception('Usuário não autenticado');

      final resultado = await _solicitacaoServico.criarSolicitacao(
        serviceSlug: widget.dados['slug'] ?? '',
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
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        imagens: _imagens,
      );

      _handleResultado(resultado);
    } catch (e) {
      ConsoleLog.error('Erro ao enviar solicitação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível enviar a solicitação. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResultado(Map<String, dynamic> resultado) {
    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Solicitação enviada com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Erro ao processar a solicitação.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _obterLocalizacaoAtual() async {
    try {
      setState(() => _isLoading = true);
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização obtida com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          _enderecoController.text = place.street ?? '';
          _bairroController.text = place.subLocality ?? '';
          _cidadeController.text = place.subAdministrativeArea ?? place.locality ?? '';
          final adminArea = place.administrativeArea ?? '';
          _estadoController.text = (adminArea.length > 2) 
              ? adminArea.substring(0, 2).toUpperCase() 
              : adminArea.toUpperCase();
          _cepController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      ConsoleLog.error('Erro ao preencher endereço: $e');
    }
  }

  Future<void> _preencherEnderecoAutomatico(String cep) async {
    try {
      final endereco = await CepService.buscarEndereco(cep);
      
      if (endereco != null) {
        setState(() {
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
          _cepValido = true;
        });
        
        // Obter coordenadas da cidade apenas se não estiver usando localização atual
        if (!_usarLocalizacaoAtual && endereco['cidade'] != null && endereco['estado'] != null) {
          _obterCoordenadasDaCidade(endereco['cidade']!, endereco['estado']!);
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro ao preencher endereço automaticamente: $e');
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
    });
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
                      if (index < _currentStep || 
                          (index == _currentStep + 1 && _validateCurrentStep())) {
                        Navigator.pop(context);
                        setState(() => _currentStep = index);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              index > _currentStep 
                                  ? 'Complete a etapa atual antes de avançar'
                                  : 'Esta etapa não está disponível',
                            ),
                            backgroundColor: AppColors.primaryBlue,
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
