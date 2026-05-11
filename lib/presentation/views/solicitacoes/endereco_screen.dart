import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class EnderecoScreen extends StatefulWidget {
  final Map<String, dynamic> dados;

  const EnderecoScreen({
    super.key,
    required this.dados,
  });

  @override
  State<EnderecoScreen> createState() => _EnderecoScreenState();
}

class _EnderecoScreenState extends State<EnderecoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _referenciaController = TextEditingController();

  // Focus nodes para navegação por teclado
  final _cepFocus = FocusNode();
  final _enderecoFocus = FocusNode();
  final _numeroFocus = FocusNode();
  final _complementoFocus = FocusNode();
  final _bairroFocus = FocusNode();
  final _cidadeFocus = FocusNode();
  final _estadoFocus = FocusNode();
  final _referenciaFocus = FocusNode();

  bool _usarLocalizacaoAtual = false;
  bool _isLoading = false;
  Position? _currentPosition;

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
    _cepFocus.dispose();
    _enderecoFocus.dispose();
    _numeroFocus.dispose();
    _complementoFocus.dispose();
    _bairroFocus.dispose();
    _cidadeFocus.dispose();
    _estadoFocus.dispose();
    _referenciaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Endereço da Solicitação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Onde ocorre o problema?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Informe o local exato para melhor atendê-lo(a):',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Formulário
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Opção de usar localização atual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Usar minha localização atual',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkText,
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
                    const SizedBox(height: 8),
                    
                    // Botão de teste para preenchimento manual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ative a localização ou preencha manualmente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // CEP
                    _buildTextField(
                      controller: _cepController,
                      focusNode: _cepFocus,
                      label: 'CEP',
                      hint: '00000-000',
                      icon: FontAwesomeIcons.envelope,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _enderecoFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o CEP';
                        }
                        if (value.length != 9) {
                          return 'CEP inválido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 8 && !value.contains('-')) {
                          _cepController.text = '${value.substring(0, 5)}-${value.substring(5)}';
                          _cepController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _cepController.text.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Endereço
                    _buildTextField(
                      controller: _enderecoController,
                      focusNode: _enderecoFocus,
                      label: 'Logradouro',
                      hint: 'Rua, Avenida, etc.',
                      icon: FontAwesomeIcons.road,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _numeroFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o logradouro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Número e Complemento
                    _buildTextField(
                      controller: _numeroController,
                      focusNode: _numeroFocus,
                      label: 'Número',
                      hint: '123',
                      icon: FontAwesomeIcons.hashtag,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _complementoFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o número';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _complementoController,
                      focusNode: _complementoFocus,
                      label: 'Complemento',
                      hint: 'Apto, Casa',
                      icon: FontAwesomeIcons.house,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _bairroFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Bairro
                    _buildTextField(
                      controller: _bairroController,
                      focusNode: _bairroFocus,
                      label: 'Bairro',
                      hint: 'Centro',
                      icon: FontAwesomeIcons.locationDot,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _cidadeFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o bairro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cidade
                    _buildTextField(
                      controller: _cidadeController,
                      focusNode: _cidadeFocus,
                      label: 'Cidade',
                      hint: 'Sua cidade',
                      icon: FontAwesomeIcons.city,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _estadoFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a cidade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estado (UF)
                    _buildTextField(
                      controller: _estadoController,
                      focusNode: _estadoFocus,
                      label: 'Estado (UF)',
                      hint: 'Ex: PB, SP, RJ',
                      icon: FontAwesomeIcons.flag,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                      ],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _referenciaFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o estado';
                        }
                        if (value.length != 2) {
                          return 'O estado deve ter exatamente 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ponto de referência
                    _buildTextField(
                      controller: _referenciaController,
                      focusNode: _referenciaFocus,
                      label: 'Ponto de Referência',
                      hint: 'Próximo à farmácia, esquina, etc.',
                      icon: FontAwesomeIcons.mapPin,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _proximoPasso,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                : const Text('Próximo Passo'),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization? textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction ?? (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _obterLocalizacaoAtual() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar permissões de localização
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

      // Obter posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        
        // Preencher campos com dados mais realistas baseados na localização
        // Em um app real, você usaria um serviço de geocoding reverso aqui
        _preencherEnderecoBaseadoNaLocalizacao(position);
        
        // Mostrar snackbar com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização obtida com sucesso!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _preencherEnderecoBaseadoNaLocalizacao(Position position) async {
    try {
      // Geocoding reverso para obter endereço real
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Preencher campos com dados reais do geocoding
        _enderecoController.text = place.street ?? place.thoroughfare ?? '';
        _numeroController.text = ''; // Número não vem do geocoding, deixar vazio (opcional)
        
        // Para geocoding brasileiro, subLocality geralmente contém a cidade quando locality está vazio
        _cidadeController.text = place.locality ?? place.subLocality ?? '';
        _bairroController.text = ''; // Bairro geralmente não vem do geocoding brasileiro
        final adminArea = place.administrativeArea ?? '';
        _estadoController.text = (adminArea.length > 2) 
            ? adminArea.substring(0, 2).toUpperCase() 
            : adminArea.toUpperCase(); // Garante sigla de 2 caracteres maiúsculos
        _complementoController.text = ''; // Complemento não vem do geocoding, deixar vazio (opcional)
        
        // Tentar obter CEP (postal code)
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          _cepController.text = place.postalCode!;
        }
        
        // Se os campos principais estiverem vazios, tentar outros campos
        if (_cidadeController.text.isEmpty) {
          _cidadeController.text = place.subAdministrativeArea ?? '';
        }
        
        // Log dos dados obtidos
        ConsoleLog.debug('=== DADOS COMPLETOS DO GEOCODING ===');
        ConsoleLog.debug('street: ${place.street}');
        ConsoleLog.debug('thoroughfare: ${place.thoroughfare}');
        ConsoleLog.debug('subThoroughfare: ${place.subThoroughfare}');
        ConsoleLog.debug('subLocality: ${place.subLocality}');
        ConsoleLog.debug('locality: ${place.locality}');
        ConsoleLog.debug('subAdministrativeArea: ${place.subAdministrativeArea}');
        ConsoleLog.debug('administrativeArea: ${place.administrativeArea}');
        ConsoleLog.debug('postalCode: ${place.postalCode}');
        ConsoleLog.debug('country: ${place.country}');
        ConsoleLog.debug('=====================================');
        ConsoleLog.debug('CAMPOS PREENCHIDOS:');
        ConsoleLog.debug('Logradouro: ${_enderecoController.text}');
        ConsoleLog.debug('Bairro: ${_bairroController.text}');
        ConsoleLog.debug('Cidade: ${_cidadeController.text}');
        ConsoleLog.debug('Estado: ${_estadoController.text}');
        ConsoleLog.debug('CEP: ${_cepController.text}');
        ConsoleLog.debug('Número: deixado vazio (opcional)');
        ConsoleLog.debug('Complemento: deixado vazio (opcional)');
        
        // Atualizar estado para mostrar que os campos foram preenchidos
        if (mounted) {
          setState(() {});
        }
        
      } else {
        // Se não encontrar endereço, mostrar mensagem
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível obter o endereço da localização atual'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      ConsoleLog.error('Erro no geocoding reverso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter endereço: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    
    // Log das coordenadas para debug
    ConsoleLog.debug('Localização obtida: Lat: ${position.latitude}, Lng: ${position.longitude}');
  }

  void _limparCamposEndereco() {
    _cepController.clear();
    _enderecoController.clear();
    _numeroController.clear();
    _complementoController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _estadoController.clear();
    _referenciaController.clear();
    _currentPosition = null;
  }

  void _proximoPasso() {
    if (_formKey.currentState!.validate()) {
      ConsoleLog.debug('=== ENVIANDO DO ENDEREÇO ===');
      ConsoleLog.debug('Dados atuais: ${widget.dados}');
      ConsoleLog.debug('Tipo ID nos dados: ${widget.dados['tipoId']}');
      ConsoleLog.debug('Subtipo ID nos dados: ${widget.dados['subtipoId']}');
      
      // Navegar para tela de upload de imagem
      final dadosParaUpload = {
        ...widget.dados,
        'endereco': {
          'cep': _cepController.text,
          'logradouro': _enderecoController.text,
          'numero': _numeroController.text,
          'complemento': _complementoController.text,
          'bairro': _bairroController.text,
          'cidade': _cidadeController.text,
          'estado': _estadoController.text,
          'referencia': _referenciaController.text,
          'usarLocalizacaoAtual': _usarLocalizacaoAtual,
          'latitude': _currentPosition?.latitude.toString(),
          'longitude': _currentPosition?.longitude.toString(),
        },
      };
      
      ConsoleLog.debug('Dados completos para upload: $dadosParaUpload');
      ConsoleLog.debug('Navegando para /solicitacoes/upload');

      context.push('/solicitacoes/upload', extra: dadosParaUpload);
    }
  }
}
