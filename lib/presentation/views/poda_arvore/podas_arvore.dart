import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


const Color primaryColor = Color(0xFF17cf17);
const Color backgroundLight = Color(0xFFf6f8f6);
const Color backgroundDark = Color(0xFF112111);
const Color gray900 = Color(0xFF111827);
const Color gray800 = Color(0xFF1f2937);
const Color gray700 = Color(0xFF374151);
const Color gray600 = Color(0xFF4b5563);
const Color gray500 = Color(0xFF6b7280);
const Color gray400 = Color(0xFF9ca3af);
const Color gray300 = Color(0xFFd1d5db);
const Color gray200 = Color(0xFFe5e7eb);
const Color gray100 = Color(0xFFf3f4f6);

class TreePruningApp extends StatelessWidget {
  const TreePruningApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.publicSansTextTheme(
      Theme.of(context).textTheme,
    );

    return MaterialApp(
      title: 'Nova Solicitação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          surface: backgroundLight,
        ),
        textTheme: textTheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          surface: backgroundDark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: textTheme,
        useMaterial3: true,
      ),
      home: const NewRequestScreen(),
    );
  }
}

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  String? _selectedProblem;
  final List<String> _problemOptions = [
    'Galhos caindo',
    'Risco de queda',
    'Árvore muito grande',
    'Árvore morta',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final textColor = isDarkMode ? gray100 : gray900;
    final secondaryTextColor = isDarkMode ? gray200 : gray800;
    final hintColor = isDarkMode ? gray400 : gray500;
    final borderColor = isDarkMode ? gray700 : gray300;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // AppBar/Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
            decoration: BoxDecoration(color: backgroundColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  icon: Icons.arrow_back,
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),
                Expanded(
                  child: Text(
                    'Nova Solicitação',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do Mapa
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * (3 / 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuA65X1b8lYC8NLaW2nEOB9YRsHOJy06qE6K92xxwev1WLaGlsYrHXltH4f8BEVQNh07YlopQ3HynECYuqGdUfideUTgcjPueqZBzoJ5FpG5Vha6WJmJTLEOMFcK_I3003P8t341hC6Ewy7lAtTxHkwpH5o4aqsALVAZ5pZOfFCXDqwykTLZc_zQ218ExCpJgsA7ogTwnsbnK9b1OatVDG1LkpRLwjBclKZTCLSEHeQqDBDmn8aHn8Gf_O17WVANq3xTjUTNL7ZvTU_r',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campo de Endereço
                  _buildTextFieldLabel(
                    label: 'Endereço da Árvore',
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: "Rua Exemplo, 123, Bairro",
                            style: TextStyle(color: textColor, fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              hintText: 'Digite o endereço',
                              hintStyle: TextStyle(color: hintColor),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                borderSide: const BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              fillColor: backgroundColor,
                              filled: true,
                              isDense: true,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border(
                                top: BorderSide(color: borderColor),
                                right: BorderSide(color: borderColor),
                                bottom: BorderSide(color: borderColor),
                              ),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tipo de Problema (Dropdown)
                  _buildTextFieldLabel(
                    label: 'Tipo de Problema',
                    child: DropdownButtonFormField<String>(
                      value: _selectedProblem,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: hintColor),
                      decoration: InputDecoration(
                        hintText: 'Selecione o tipo de problema',
                        hintStyle: TextStyle(color: hintColor),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        fillColor: backgroundColor,
                        filled: true,
                        isDense: true,
                      ),
                      dropdownColor: isDarkMode
                          ? backgroundDark
                          : backgroundLight,
                      style: TextStyle(color: textColor, fontSize: 16),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            'Selecione o tipo de problema',
                            style: TextStyle(color: gray500),
                          ),
                        ),
                        ..._problemOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProblem = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Adicionar Foto (Button)
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? gray600 : gray400,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add_a_photo,
                                  color: primaryColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Adicionar Foto (Opcional)',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.camera_alt, color: hintColor, size: 28),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Enviar Solicitação'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final color = isDarkMode ? Colors.white : gray800;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel({required String label, required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? gray200 : gray800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
