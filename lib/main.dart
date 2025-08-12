import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:convert';
import 'dart:typed_data';

// Clase para validación de números telefónicos
class PhoneValidator {
  static final RegExp _phoneRegex = RegExp(r'^[+]?[0-9\s\-\(\)]{7,15}$');
  
  static bool isValidPhoneNumber(String phone) {
    if (phone.trim().isEmpty) return false;
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return _phoneRegex.hasMatch(phone) && cleanPhone.length >= 7 && cleanPhone.length <= 15;
  }
  
  static String formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}

// Clase para manejar contactos de emergencia
class EmergencyContactsManager {
  static const String _contactsKey = 'emergency_contacts';
  static const String _primaryContactKey = 'emergency_contact';
  
  static Future<List<Map<String, String>>> getContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey);
      if (contactsJson != null) {
        final List<dynamic> contactsList = json.decode(contactsJson);
        return contactsList.map((contact) => Map<String, String>.from(contact)).toList();
      }
    } catch (e) {
      print('Error loading emergency contacts: $e');
    }
    return [];
  }
  
  static Future<bool> saveContacts(List<Map<String, String>> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = json.encode(contacts);
      return await prefs.setString(_contactsKey, contactsJson);
    } catch (e) {
      print('Error saving emergency contacts: $e');
      return false;
    }
  }
  
  static Future<bool> addContact(String name, String phone) async {
    try {
      final contacts = await getContacts();
      contacts.add({
        'name': name,
        'phone': phone,
        'description': 'Se llamará a este contacto al presionar el botón de emergencia.',
      });
      return await saveContacts(contacts);
    } catch (e) {
      print('Error adding emergency contact: $e');
      return false;
    }
  }
  
  static Future<bool> removeContact(int index) async {
    try {
      final contacts = await getContacts();
      if (index >= 0 && index < contacts.length) {
        contacts.removeAt(index);
        return await saveContacts(contacts);
      }
      return false;
    } catch (e) {
      print('Error removing emergency contact: $e');
      return false;
    }
  }
  
  static Future<String> getPrimaryContact() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_primaryContactKey) ?? '';
    } catch (e) {
      print('Error getting primary contact: $e');
      return '';
    }
  }
}

// Clase para optimizar el manejo de iconos
class AppIconCache {
  static final Map<String, Uint8List?> _iconCache = {};
  
  static Uint8List? getCachedIcon(String packageName) {
    return _iconCache[packageName];
  }
  
  static void cacheIcon(String packageName, Uint8List? icon) {
    if (_iconCache.length > 100) {
      // Limpiar caché si es muy grande
      _iconCache.clear();
    }
    _iconCache[packageName] = icon;
  }
  
  static void clearCache() {
    _iconCache.clear();
  }
}

void main() {
  runApp(const AdulTechLauncher());
}

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _nameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isDarkMode ? const Color(0xFF6A4C93) : Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.elderly,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'AdulTech',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Configuración inicial',
                style: TextStyle(
                  fontSize: 18,
                  color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: _buildCurrentStep(),
              ),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        'Anterior',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: _currentStep == 3 ? _completeSetup : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4C93),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Finalizar' : 'Siguiente',
                      style: TextStyle(fontSize: _fontSize),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildThemeStep();
      case 1:
        return _buildFontSizeStep();
      case 2:
        return _buildNameStep();
      case 3:
        return _buildEmergencyContactStep();
      default:
        return Container();
    }
  }

  Widget _buildThemeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Elige tu tema preferido',
          style: TextStyle(
            fontSize: _fontSize + 8,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDarkMode = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: !_isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                      width: !_isDarkMode ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.light_mode,
                        size: 50,
                        color: !_isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Modo Claro',
                        style: TextStyle(
                          fontSize: _fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: !_isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDarkMode = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                      width: _isDarkMode ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        size: 50,
                        color: _isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Modo Oscuro',
                        style: TextStyle(
                          fontSize: _fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? const Color(0xFF6A4C93) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tamaño de letra',
            style: TextStyle(
              fontSize: _fontSize + 8, // Cambio dinámico del título
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Selecciona el tamaño de letra que prefieras',
            style: TextStyle(
              fontSize: _fontSize, // Cambio dinámico del subtítulo
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              _buildFontSizeOption('Pequeño', 14.0),
              const SizedBox(height: 15),
              _buildFontSizeOption('Mediano', 16.0),
              const SizedBox(height: 15),
              _buildFontSizeOption('Grande', 20.0),
              const SizedBox(height: 15),
              _buildFontSizeOption('Muy Grande', 24.0),
            ],
          ),
          const SizedBox(height: 100), // Espacio adicional para evitar sobreposición con botones
        ],
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    bool isSelected = _fontSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _fontSize = size;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF6A4C93) : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? const Color(0xFF6A4C93) 
                : (_isDarkMode ? Colors.white : Colors.black),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      );
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Cómo te llamas?',
            style: TextStyle(
              fontSize: _fontSize + 8,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Este nombre aparecerá en tu pantalla de bienvenida',
            style: TextStyle(
              fontSize: _fontSize,
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            style: TextStyle(
              fontSize: _fontSize + 4,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tu nombre aquí',
              hintStyle: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              filled: true,
              fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 100), // Espacio adicional para evitar que el teclado oculte el contenido
         ],
       ),
     );
  }

  Widget _buildEmergencyContactStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
          'Contacto de emergencia',
          style: TextStyle(
            fontSize: _fontSize + 8,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Este número se llamará cuando presiones el botón de emergencia',
          style: TextStyle(
            fontSize: _fontSize,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
          const SizedBox(height: 40),
          TextField(
            controller: _emergencyContactController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: _fontSize + 4,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Número de teléfono',
              hintStyle: TextStyle(
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              filled: true,
              fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              prefixIcon: Icon(
                Icons.phone,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 100), // Espacio adicional para evitar que el teclado oculte el contenido
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Future<void> _completeSetup() async {
    // Validación del nombre
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa tu nombre');
      return;
    }
    
    if (_nameController.text.trim().length < 2) {
      _showErrorDialog('El nombre debe tener al menos 2 caracteres');
      return;
    }
    
    // Validación del contacto de emergencia
    if (_emergencyContactController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa un contacto de emergencia');
      return;
    }
    
    if (!PhoneValidator.isValidPhoneNumber(_emergencyContactController.text.trim())) {
      _showErrorDialog('Por favor, ingresa un número de teléfono válido\n(7-15 dígitos, puede incluir +, espacios, guiones y paréntesis)');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final formattedPhone = PhoneValidator.formatPhoneNumber(_emergencyContactController.text.trim());
      
      await prefs.setBool('initial_setup_completed', true);
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setDouble('font_size', _fontSize);
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('emergency_contact', formattedPhone);

      if (mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const LauncherScreen()),
         );
       }
    } catch (e) {
      print('Error completing setup: $e');
      _showErrorDialog('Error al guardar la configuración. Por favor, inténtalo de nuevo.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Error',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );
  }
}

class AdulTechLauncher extends StatelessWidget {
  const AdulTechLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdulTech Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkInitialSetup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF1A1A1A),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6A4C93),
                ),
              ),
            );
          }
          
          if (snapshot.data == true) {
            return const LauncherScreen();
          } else {
            return const InitialSetupScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _checkInitialSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('initial_setup_completed') ?? false;
  }
}

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  String _userName = 'Adulto mayor';
  String _emergencyContact = '';
  List<AppInfo> _installedApps = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    // Cargar aplicaciones después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstalledApps();
    });
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _fontSize = prefs.getDouble('font_size') ?? 16.0;
      _userName = prefs.getString('user_name') ?? 'Adulto mayor';
      _emergencyContact = prefs.getString('emergency_contact') ?? '';
    });
  }

  Future<void> _addMissingEssentialApps(List<AppInfo> validApps, List<AppInfo> allInstalledApps) async {
    // Lista de aplicaciones esenciales que queremos mostrar siempre
    final essentialPackages = [
      'com.google.android.youtube',
      'com.google.android.gm',
      'com.android.vending',
      'com.android.chrome',
      'com.google.android.apps.maps',
    ];

    for (String packageName in essentialPackages) {
      // Verificar si la aplicación ya está en la lista válida
      bool alreadyExists = validApps.any((app) => app.packageName == packageName);
      print('DEBUG: Verificando $packageName - Ya existe en validApps: $alreadyExists');
      
      if (!alreadyExists) {
        // Buscar la aplicación en la lista completa de aplicaciones instaladas
        AppInfo? installedApp;
        try {
           installedApp = allInstalledApps.firstWhere(
             (app) => app.packageName == packageName,
           );
           print('DEBUG: Encontrada aplicación instalada: ${installedApp.name} (${installedApp.packageName})');
          // La aplicación está instalada, agregarla con su icono original
          print('DEBUG: Agregando aplicación esencial instalada: ${installedApp.name} con icono original');
          validApps.add(installedApp);
        } catch (e) {
          // La aplicación no está instalada, crear una entrada manual
          String appName = _getEssentialAppName(packageName);
          print('DEBUG: Agregando aplicación esencial no instalada: $appName');
          
          AppInfo manualApp = AppInfo(
            name: appName,
            packageName: packageName,
            icon: null, // Sin icono para apps no instaladas
            versionName: '1.0',
            versionCode: 1,
            builtWith: BuiltWith.flutter,
            installedTimestamp: DateTime.now().millisecondsSinceEpoch,
          );
          
          validApps.add(manualApp);
        }
      } else {
        print('DEBUG: Aplicación esencial $packageName ya existe en la lista');
      }
    }
  }
  
  String _getEssentialAppName(String packageName) {
    switch (packageName) {
      case 'com.google.android.youtube':
        return 'YouTube';
      case 'com.google.android.gm':
        return 'Gmail';
      case 'com.android.vending':
        return 'Play Store';
      case 'com.android.chrome':
        return 'Google Chrome';
      case 'com.google.android.apps.maps':
        return 'Google Maps';
      default:
        return 'App';
    }
  }

  Future<void> _loadInstalledApps() async {
    try {
      print('Cargando aplicaciones instaladas...');
      
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cargando aplicaciones...'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      
      if (apps.isEmpty) {
        throw Exception('No se pudieron cargar las aplicaciones instaladas');
      }
      
      print('=== ANÁLISIS DETALLADO DE APLICACIONES ===');
      print('Total de aplicaciones detectadas: ${apps.length}');
      
      // Buscar específicamente YouTube y Gmail en TODAS las aplicaciones
      for (AppInfo app in apps) {
        if (app.packageName != null && app.name != null) {
          String packageName = app.packageName!.toLowerCase();
          String appName = app.name!.toLowerCase();
          
          // Detectar YouTube
          if (packageName.contains('youtube') || appName.contains('youtube')) {
            print('🔍 YOUTUBE ENCONTRADO: "${app.name}" - ${app.packageName}');
          }
          
          // Detectar Gmail
          if (packageName.contains('gmail') || packageName.contains('mail') || appName.contains('gmail') || appName.contains('mail')) {
            print('📧 GMAIL/MAIL ENCONTRADO: "${app.name}" - ${app.packageName}');
          }
          
          // Detectar Play Store
          if (packageName.contains('vending') || packageName.contains('play') || appName.contains('play') || appName.contains('store')) {
            print('🏪 PLAY STORE ENCONTRADO: "${app.name}" - ${app.packageName}');
          }
        }
      }
      print('=== FIN ANÁLISIS DETALLADO ===');
      
      // Lista de paquetes del sistema que queremos excluir
      Set<String> systemPackagesToExclude = {
        'com.android.systemui',
        'com.android.settings',
        'com.android.launcher',
        'com.android.inputmethod',
        'com.android.keychain',
        'com.android.providers',
        'com.android.server',
        'com.google.android.setupwizard',
        'com.google.android.partnersetup',
        'com.google.android.configupdater',
        'com.google.android.syncadapters',
        'com.google.android.backuptransport',
        'com.google.android.feedback',
        'com.google.android.onetimeinitializer',
        'com.google.android.ext.services',
        'com.google.android.webview',
        'com.google.android.packageinstaller'
      };
      
      // Lista de aplicaciones de Google esenciales que NO deben ser excluidas
      Set<String> allowedGoogleApps = {
        'com.google.android.contacts',
        'com.google.android.dialer',
        'com.google.android.apps.photos', // Google Fotos
        'com.google.android.GoogleCamera',
        'com.google.android.apps.messaging',
        'com.google.android.calendar',
        'com.google.android.gm', // Gmail
        'com.google.android.youtube', // YouTube
        'com.google.android.apps.maps',
        'com.google.android.music',
        'com.google.android.apps.docs', // Drive (ya aparece en logs)
        'com.google.android.keep',
        'com.android.vending', // Google Play Store
        'com.google.android.apps.gmail', // Gmail alternativo
        'com.google.android.apps.photos.vrmode', // Google Fotos VR
        'com.google.android.apps.youtube.music', // YouTube Music (ya aparece)
        'com.google.android.apps.bard', // Gemini
        'com.google.android.apps.magazines', // Google Noticias
        'com.google.android.apps.podcasts', // Google Podcasts
        'com.google.android.videos', // Google TV
        'com.google.android.apps.docs.editors.slides', // Diapositivas
        'com.google.android.apps.docs.editors.docs', // Documentos
        'com.google.android.apps.docs.editors.sheets' // Hojas de cálculo
      };
      
      // Lista de aplicaciones esenciales que siempre deben aparecer
      Set<String> essentialApps = {
        'com.google.android.youtube',
        'com.google.android.gm',
        'com.android.vending',
        'com.android.chrome',
        'com.google.android.apps.maps',
      };
      
      // Filtrar aplicaciones válidas
      List<AppInfo> validApps = apps.where((app) {
        if ((app.name?.isEmpty ?? true) ||
            (app.packageName?.isEmpty ?? true)) {
          return false;
        }
        
        String packageName = app.packageName!;
        
        // Las aplicaciones esenciales siempre pasan el filtro
        if (essentialApps.contains(packageName)) {
          print('✅ APLICACIÓN ESENCIAL DETECTADA: ${app.name} - $packageName');
          return true;
        }
        
        // Debug: Imprimir aplicaciones de Google para diagnóstico
        if (packageName.contains('google') && packageName.contains('android')) {
          print('Aplicación Google encontrada: ${app.name} - $packageName');
        }
        
        // Log detallado para YouTube y Gmail específicamente
        String appNameLower = (app.name ?? '').toLowerCase();
        bool isYouTube = packageName.contains('youtube') || appNameLower.contains('youtube');
        bool isGmail = packageName.contains('gmail') || packageName.contains('mail') || appNameLower.contains('gmail') || appNameLower.contains('mail');
        bool isPlayStore = packageName.contains('vending') || packageName.contains('play') || appNameLower.contains('play') || appNameLower.contains('store');
        
        if (isYouTube || isGmail || isPlayStore) {
          print('\n🔍 PROCESANDO APLICACIÓN OBJETIVO: "${app.name}" - $packageName');
        }
        
        // Permitir aplicaciones de Google esenciales explícitamente
        if (allowedGoogleApps.contains(packageName)) {
          if (isYouTube || isGmail || isPlayStore) {
            print('✅ PERMITIDA EXPLÍCITAMENTE: ${app.name} - $packageName');
          }
          return true;
        }
        
        if (isYouTube || isGmail || isPlayStore) {
          print('⚠️  NO está en allowedGoogleApps: $packageName');
          print('   allowedGoogleApps contiene: ${allowedGoogleApps.where((pkg) => pkg.contains('youtube') || pkg.contains('gmail') || pkg.contains('mail') || pkg.contains('vending')).toList()}');
        }
        
        // Excluir paquetes específicos del sistema
        if (systemPackagesToExclude.any((systemPkg) => packageName.startsWith(systemPkg))) {
          if (isYouTube || isGmail || isPlayStore) {
            print('❌ EXCLUIDA por systemPackagesToExclude: $packageName');
          }
          return false;
        }
        
        // Excluir otros servicios de Google que no son aplicaciones de usuario
        if (packageName.startsWith('com.google.android.gms') ||
            packageName.startsWith('com.google.android.gsf') ||
            packageName.startsWith('com.google.android.tts')) {
          if (isYouTube || isGmail || isPlayStore) {
            print('❌ EXCLUIDA por filtros de servicios Google: $packageName');
          }
          return false;
        }
        
        if (isYouTube || isGmail || isPlayStore) {
          print('✅ PASÓ TODOS LOS FILTROS: ${app.name} - $packageName');
        }
        
        // Permitir todas las demás aplicaciones
        return true;
      }).toList();
      
      // Optimizar iconos usando caché
      for (AppInfo app in validApps) {
        if (app.packageName != null && app.icon != null) {
          AppIconCache.cacheIcon(app.packageName!, app.icon);
        }
      }
      
      // Agregar aplicaciones manuales para YouTube, Gmail y Play Store si no están instaladas o no han sido detectadas
      await _addMissingEssentialApps(validApps, apps);
      
      // Ordenar alfabéticamente
      validApps.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
      
      if (mounted) {
        setState(() {
          _installedApps = validApps;
        });
      }
      
      print('Se cargaron ${_installedApps.length} aplicaciones válidas');
      
      // Debug: Verificar si las aplicaciones específicas están en la lista
      List<String> targetApps = ['youtube', 'gmail', 'play store', 'google photos', 'fotos'];
      for (String target in targetApps) {
        var found = _installedApps.where((app) => 
          app.name?.toLowerCase().contains(target) == true ||
          app.packageName?.toLowerCase().contains(target.replaceAll(' ', '')) == true
        ).toList();
        if (found.isNotEmpty) {
          print('Encontradas aplicaciones para "$target": ${found.map((app) => '${app.name} (${app.packageName})').join(', ')}');
        } else {
          print('NO se encontraron aplicaciones para "$target"');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_installedApps.length} aplicaciones cargadas exitosamente'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error loading installed apps: $e');
      
      if (mounted) {
        setState(() {
          _installedApps = [];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar aplicaciones: ${e.toString()}\nPresiona el botón de recarga para intentar de nuevo'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _loadInstalledApps(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        body: SafeArea(
          bottom: false, // Allow content to extend behind gesture area
          child: Column(
          children: [
            // Emergency Button and Settings Button (Fixed at top)
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showEmergencyDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'EMERGENCIA',
                            style: TextStyle(fontSize: _fontSize * 0.875, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen(fontSize: _fontSize, isDarkMode: _isDarkMode)),
                      ).then((_) => _loadUserPreferences());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: _isDarkMode ? Colors.white : Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == 0 
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : (_isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == 1 
                        ? (_isDarkMode ? Colors.white : Colors.black)
                        : (_isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // PageView for swiping between screens
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _buildMainScreen(),
                  _buildAllAppsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar and Welcome Message
          Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.elderly,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4C93),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '¡Bienvenido $_userName!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // App Grid
          Column(
            children: [
              _buildAppTile(
                'WhatsApp',
                'Aplicación para enviar mensajes a amigos, conocidos o familiares.',
                Icons.chat,
                Colors.green,
                () async => await _launchApp('WhatsApp'),
              ),
              const SizedBox(height: 15),
              _buildAppTile(
                'Cámara',
                'Cámara simplificada solo para tomar fotos/selfies o grabar.',
                Icons.camera_alt,
                Colors.blue,
                () async => await _launchApp('Cámara'),
              ),
              const SizedBox(height: 15),
              _buildAppTile(
                'Contactos',
                'Agrega a un amigo, familiar o conocido.',
                Icons.contacts,
                Colors.orange,
                () async => await _launchApp('Contactos'),
              ),
              const SizedBox(height: 15),
              _buildAppTile(
                'Teléfono',
                'Contacta a tus contactos a través de llamadas',
                Icons.phone,
                Colors.blue,
                () async => await _launchApp('Teléfono'),
              ),
              const SizedBox(height: 15),
              _buildAppTile(
                'Galería',
                'Aquí puedes ver las fotos tomadas con la aplicación cámara.',
                Icons.photo_library,
                Colors.purple,
                () async => await _launchApp('Galería'),
              ),
              const SizedBox(height: 15),
              _buildAppTile(
                '¡Aprende a usarme!',
                'Cursos interactivos de como usar tu AdulTech.',
                Icons.school,
                Colors.teal,
                () async => await _launchApp('Aprende'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAllAppsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Todas las aplicaciones',
                style: TextStyle(
                  fontSize: _fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _loadInstalledApps();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recargando aplicaciones...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A4C93),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_installedApps.isEmpty)
            Column(
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.apps,
                  size: 64,
                  color: _isDarkMode ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 20),
                Text(
                  'Cargando aplicaciones...',
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Presiona el botón de recarga si necesitas actualizar la lista',
                  style: TextStyle(
                    fontSize: _fontSize * 0.875,
                    color: _isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  '${_installedApps.length} aplicaciones encontradas',
                  style: TextStyle(
                    fontSize: _fontSize * 0.875,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _installedApps.length,
                  itemBuilder: (context, index) {
                    final app = _installedApps[index];
                    return _buildInstalledAppTile(app);
                  },
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInstalledAppTile(AppInfo app) {
    return GestureDetector(
      onTap: () => _launchInstalledApp(app),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildAppIcon(app),
            ),
            const SizedBox(height: 8),
            Text(
              app.name ?? 'App',
              style: TextStyle(
                fontSize: _fontSize * 0.75,
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppInfo app) {
    // Usar caché de iconos si está disponible
    if (app.packageName != null) {
      final cachedIcon = AppIconCache.getCachedIcon(app.packageName!);
      if (cachedIcon != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            cachedIcon,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon();
            },
          ),
        );
      }
    }
    
    // Fallback al icono original
    if (app.icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          app.icon!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        ),
      );
    }
    
    return _buildDefaultIcon();
  }
  
  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.android,
      color: Colors.white,
      size: 30,
    );
  }

  Widget _buildAppTile(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _isDarkMode ? Colors.white : Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize * 1.125,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: _fontSize * 0.875,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchApp(String appName) async {
    // Mapeo de nombres de aplicaciones a package names comunes con mayor compatibilidad
    Map<String, List<String>> appPackages = {
      'WhatsApp': [
        'com.whatsapp',
        'com.whatsapp.w4b',
        'com.whatsapp.business'
      ],
      'Cámara': [
        'com.android.camera',
        'com.android.camera2',
        'com.google.android.GoogleCamera',
        'com.sec.android.app.camera',
        'com.samsung.android.camera',
        'com.huawei.camera',
        'com.xiaomi.camera',
        'com.oppo.camera',
        'com.vivo.camera',
        'com.oneplus.camera',
        'com.motorola.camera',
        'com.lge.camera',
        'com.htc.camera',
        'com.sony.camera',
        'org.codeaurora.snapcam',
        'com.mediatek.camera'
      ],
      'Contactos': [
        'com.android.contacts',
        'com.google.android.contacts',
        'com.sec.android.app.contacts',
        'com.samsung.android.contacts',
        'com.huawei.contacts',
        'com.xiaomi.contacts',
        'com.oppo.contacts',
        'com.vivo.contacts',
        'com.oneplus.contacts',
        'com.motorola.contacts',
        'com.lge.contacts',
        'com.htc.contacts',
        'com.sony.contacts',
        'com.miui.contactsbook'
      ],
      'Teléfono': [
        'com.android.dialer',
        'com.google.android.dialer',
        'com.sec.android.app.dialertab',
        'com.samsung.android.dialer',
        'com.huawei.contacts',
        'com.xiaomi.dialer',
        'com.oppo.dialer',
        'com.vivo.dialer',
        'com.oneplus.dialer',
        'com.motorola.dialer',
        'com.lge.phone',
        'com.htc.dialer',
        'com.sony.phone',
        'com.miui.dialer'
      ],
      'Galería': [
        'com.android.gallery3d',
        'com.google.android.apps.photos',
        'com.sec.android.gallery3d',
        'com.samsung.android.gallery3d',
        'com.huawei.photos',
        'com.miui.gallery',
        'com.oppo.gallery3d',
        'com.vivo.gallery',
        'com.oneplus.gallery',
        'com.motorola.gallery',
        'com.lge.gallery3d',
        'com.htc.gallery',
        'com.sony.album',
        'com.coloros.gallery3d'
      ],
      'Aprende': [], // Esta será una funcionalidad especial
    };

    try {
      List<String>? packages = appPackages[appName];
      
      if (packages == null || packages.isEmpty) {
        if (appName == 'Aprende') {
          _openLearningWebsite();
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró configuración para $appName'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Primero intentar con los package names conocidos
      bool appLaunched = false;
      for (String packageName in packages) {
        try {
          print('Intentando abrir $appName con packageName: $packageName');
          bool? launchResult = await InstalledApps.startApp(packageName);
          bool launched = launchResult ?? false;
          
          if (launched) {
            appLaunched = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Abriendo $appName...'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
            break;
          } else {
            print('$appName con $packageName no se pudo abrir (aplicación no encontrada)');
          }
        } catch (e) {
          print('Error al intentar abrir $appName con $packageName: $e');
          continue;
        }
      }
      
      // Si no funcionó, buscar en las aplicaciones instaladas
      if (!appLaunched) {
        appLaunched = await _tryLaunchByAppName(appName);
      }
      
      if (!appLaunched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir $appName. Verifica que esté instalada.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error general al abrir $appName: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir $appName: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isManualApp(AppInfo app) {
    // Verificar si es una de las aplicaciones esenciales que agregamos manualmente
    final essentialPackages = [
      'com.google.android.youtube',
      'com.google.android.gm',
      'com.android.vending',
      'com.android.chrome',
      'com.google.android.apps.maps',
    ];
    return essentialPackages.contains(app.packageName);
  }

  Future<void> _handleManualAppLaunch(AppInfo app) async {
    print('Manejando lanzamiento de aplicación esencial: ${app.name}');
    
    try {
      // Primero intentar abrir la aplicación directamente
      print('Intentando abrir ${app.name} directamente...');
      
      // Obtener todas las aplicaciones instaladas para verificar si existe
      List<AppInfo> allApps = await InstalledApps.getInstalledApps(true, true);
      AppInfo? installedApp = allApps.firstWhere(
        (installedApp) => installedApp.packageName == app.packageName,
        orElse: () => app, // Si no se encuentra, usar la app manual
      );
      
      // Intentar abrir la aplicación
      bool? launchResult = await InstalledApps.startApp(app.packageName!);
      bool launched = launchResult ?? false;
      
      if (launched) {
        print('${app.name} abierta exitosamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Abriendo ${app.name}...'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }
      
      // Si no se pudo abrir, mostrar mensaje y abrir Play Store
      print('${app.name} no está instalada o no se pudo abrir');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${app.name} no está instalada. Abriendo Play Store para instalarla...'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      // Intentar abrir Play Store con el paquete específico
      await _openPlayStoreForApp(app.packageName!);
      
    } catch (e) {
      print('Error al manejar aplicación esencial ${app.name}: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${app.name} no está disponible. Instálala desde Play Store.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openPlayStore(String packageName) async {
    try {
      // Intentar abrir Play Store directamente
      bool? playStoreOpened = await InstalledApps.startApp('com.android.vending');
      
      if (playStoreOpened == true) {
        print('Play Store abierto exitosamente');
        return;
      }
      
      // Si Play Store no se abre, intentar con otros nombres de paquete
      List<String> playStorePackages = [
        'com.google.android.finsky',
        'com.android.vending',
      ];
      
      for (String pkg in playStorePackages) {
        try {
          bool? opened = await InstalledApps.startApp(pkg);
          if (opened == true) {
            print('Play Store abierto con paquete: $pkg');
            return;
          }
        } catch (e) {
          print('No se pudo abrir Play Store con paquete $pkg: $e');
        }
      }
      
      throw Exception('No se pudo abrir Play Store');
      
    } catch (e) {
      print('Error al abrir Play Store: $e');
      throw e;
    }
  }

  Future<void> _openPlayStoreForApp(String packageName) async {
    try {
      // Intentar abrir Play Store con URL específica de la aplicación
      String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
      final Uri uri = Uri.parse(playStoreUrl);
      
      print('Intentando abrir Play Store para $packageName');
      
      // Primero intentar abrir con URL específica
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Play Store abierto con URL específica para $packageName');
        return;
      }
      
      // Si no funciona la URL, abrir Play Store normalmente
      await _openPlayStore(packageName);
      
    } catch (e) {
      print('Error al abrir Play Store para $packageName: $e');
      // Como último recurso, intentar abrir Play Store sin URL específica
      try {
        await _openPlayStore(packageName);
      } catch (e2) {
        print('Error final al abrir Play Store: $e2');
        throw e2;
      }
    }
  }

  Future<void> _launchInstalledApp(AppInfo app) async {
    if (app.packageName?.isEmpty ?? true) {
      _showErrorSnackBar('Error: Información de aplicación inválida');
      return;
    }
    
    try {
      print('Intentando abrir ${app.name} (${app.packageName})');
      
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abriendo ${app.name ?? 'aplicación'}...'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      bool? launchResult = await InstalledApps.startApp(app.packageName!);
      bool launched = launchResult ?? false;
      
      if (!launched) {
        // Si es una aplicación manual (agregada por nosotros), intentar alternativas
        if (_isManualApp(app)) {
          await _handleManualAppLaunch(app);
          return;
        }
        throw Exception('La aplicación no pudo iniciarse. Puede que no esté disponible o tenga permisos restringidos.');
      }
      
      print('Aplicación ${app.name} abierta exitosamente');
      
    } catch (e) {
      print('Error launching app ${app.name}: $e');
      
      // Si es una aplicación manual, intentar alternativas
      if (_isManualApp(app)) {
        await _handleManualAppLaunch(app);
        return;
      }
      
      String errorMessage;
      if (e.toString().contains('not found') || e.toString().contains('not installed')) {
        errorMessage = '${app.name ?? 'La aplicación'} no está instalada o no está disponible';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'No tienes permisos para abrir ${app.name ?? 'esta aplicación'}';
      } else {
        errorMessage = 'Error al abrir ${app.name ?? 'la aplicación'}: ${e.toString()}';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: const Text(
            'EMERGENCIA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            _emergencyContact.isNotEmpty 
                ? '¿Desea llamar a $_emergencyContact?'
                : '¿Desea llamar a servicios de emergencia?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _callEmergency();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
              child: const Text('Llamar'),
            ),
          ],
        );
      },
    );
  }

  void _callEmergency() async {
    String phoneNumber = _emergencyContact.isNotEmpty ? _emergencyContact : '911';
    
    // Limpiar el número de teléfono (remover espacios y caracteres especiales)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Llamando a $phoneNumber...'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede realizar la llamada desde este dispositivo'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error al realizar llamada de emergencia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar la llamada: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openLearningWebsite() async {
    const String learningUrl = 'https://adultech.netlify.app';
    final Uri uri = Uri.parse(learningUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Abre en el navegador predeterminado
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abriendo página de aprendizaje...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede abrir el navegador en este dispositivo'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error al abrir página de aprendizaje: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir la página: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _tryLaunchByAppName(String appName) async {
    try {
      // Obtener todas las aplicaciones instaladas
      List<AppInfo> allApps = await InstalledApps.getInstalledApps(true, true);
      
      // Mapeo de nombres en español a palabras clave en inglés
      Map<String, List<String>> nameKeywords = {
        'Contactos': ['contact', 'contacts', 'people', 'phonebook'],
        'Teléfono': ['phone', 'dialer', 'call', 'calls'],
        'Galería': ['gallery', 'photos', 'pictures', 'images', 'album'],
        'Cámara': ['camera', 'cam'],
        'WhatsApp': ['whatsapp'],
      };
      
      List<String> keywords = nameKeywords[appName] ?? [appName.toLowerCase()];
      
      // Buscar aplicaciones que coincidan con las palabras clave
      for (AppInfo app in allApps) {
        if (app.name != null && app.packageName != null) {
          String appNameLower = app.name!.toLowerCase();
          String packageNameLower = app.packageName!.toLowerCase();
          
          // Verificar si el nombre o package contiene alguna palabra clave
          bool matches = keywords.any((keyword) => 
            appNameLower.contains(keyword) || packageNameLower.contains(keyword)
          );
          
          if (matches) {
            try {
              print('Encontrada aplicación candidata: ${app.name} (${app.packageName})');
              InstalledApps.startApp(app.packageName!);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abriendo ${app.name}...'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
              return true;
            } catch (e) {
              print('Error al abrir ${app.name}: $e');
              continue;
            }
          }
        }
      }
      
      return false;
    } catch (e) {
      print('Error en búsqueda por nombre: $e');
      return false;
    }
  }
}

class SettingsScreen extends StatefulWidget {
  final double fontSize;
  final bool isDarkMode;
  
  const SettingsScreen({super.key, required this.fontSize, required this.isDarkMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _fontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
          backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Configuración',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black, 
              fontSize: _fontSize * 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header con información del usuario
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF6A4C93), const Color(0xFF8E44AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AdulTech Launcher',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _fontSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Personaliza tu experiencia',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: _fontSize * 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Sección Configuración
            _buildSectionHeader('Configuración', Icons.settings),
            const SizedBox(height: 15),
            _buildSettingsTile(
              'Tamaño de texto',
              'Ajusta el tamaño del texto para mejor lectura',
              Icons.text_fields,
              null,
              () => _showTextSizeDialog(),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              'Modo oscuro',
              'Cambia entre tema claro y oscuro',
              Icons.dark_mode,
              null,
              () => _toggleDarkMode(),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              'Lector de pantalla',
              'Abre configuración de accesibilidad para activar TalkBack',
              Icons.record_voice_over,
              false,
              () => _openAccessibilitySettings(),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              'Número de emergencia',
              'Configura número para llamadas de emergencia',
              Icons.emergency,
              null,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyContactsScreen(fontSize: _fontSize, isDarkMode: _isDarkMode)),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              'Acerca de AdulTech',
              'Información sobre la aplicación y versión',
              Icons.info_outline,
              null,
              () => _showAboutDialog(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4C93).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6A4C93),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontSize: _fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String description, IconData icon, bool? hasSwitch, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF6A4C93).withOpacity(0.2), const Color(0xFF8E44AD).withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6A4C93),
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize * 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: _fontSize * 0.85,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasSwitch != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasSwitch ? const Color(0xFF6A4C93) : Colors.grey[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasSwitch ? 'ON' : 'OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4C93).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.construction,
                  color: const Color(0xFF6A4C93),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Próximamente',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontSize: _fontSize * 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'La función "$feature" estará disponible en una próxima actualización. ¡Mantente atento!',
            style: TextStyle(
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontSize: _fontSize * 0.9,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Entendido',
                style: TextStyle(
                  fontSize: _fontSize * 0.9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6A4C93), const Color(0xFF8E44AD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AdulTech Launcher',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontSize: _fontSize * 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: _fontSize * 0.9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Un launcher diseñado especialmente para adultos mayores, con interfaz simple, texto grande y funciones de emergencia.',
                style: TextStyle(
                  color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: _fontSize * 0.9,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4C93).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: const Color(0xFF6A4C93),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Desarrollado con ❤️ para facilitar el uso de la tecnología',
                        style: TextStyle(
                          color: const Color(0xFF6A4C93),
                          fontSize: _fontSize * 0.85,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: _fontSize * 0.9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
              title: Text(
                'Ajustar Texto',
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tamaño actual: ${_getFontSizeLabel(_fontSize)}',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      _buildFontSizeDialogOption('Pequeño', 14.0, setDialogState),
                      const SizedBox(height: 10),
                      _buildFontSizeDialogOption('Mediano', 16.0, setDialogState),
                      const SizedBox(height: 10),
                      _buildFontSizeDialogOption('Grande', 20.0, setDialogState),
                      const SizedBox(height: 10),
                      _buildFontSizeDialogOption('Muy Grande', 24.0, setDialogState),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFontSizeDialogOption(String label, double size, StateSetter setDialogState) {
    bool isSelected = _fontSize == size;
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        setDialogState(() {
          _fontSize = size;
        });
        setState(() {
          _fontSize = size;
        });
        await prefs.setDouble('font_size', size);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6A4C93) 
              : (_isDarkMode ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF6A4C93) : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? Colors.white 
                : (_isDarkMode ? Colors.white : Colors.black),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    switch (size) {
      case 14.0:
        return 'Pequeño';
      case 16.0:
        return 'Mediano';
      case 20.0:
        return 'Grande';
      case 24.0:
        return 'Muy Grande';
      default:
        return 'Personalizado';
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      const AndroidIntent intent = AndroidIntent(
        action: 'android.settings.ACCESSIBILITY_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      print('Error al abrir configuración de accesibilidad: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la configuración de accesibilidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  final double fontSize;
  final bool isDarkMode;
  
  const EmergencyContactsScreen({super.key, required this.fontSize, required this.isDarkMode});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late bool _isDarkMode;
  late double _fontSize;
  
  String _emergencyNumber = '';
  
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _fontSize = widget.fontSize;
    _loadEmergencyNumber();
  }
  
  Future<void> _loadEmergencyNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _emergencyNumber = prefs.getString('emergency_contact') ?? '';
        _phoneController.text = _emergencyNumber;
      });
    } catch (e) {
      print('Error loading emergency number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
          backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Volver',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: _fontSize * 1.25),
          ),
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.emergency,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Número de emergencia',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white : Colors.black,
                                  fontSize: _fontSize * 1.125,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Este número se llamará al presionar el botón de emergencia.',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.grey : Colors.grey[600],
                                  fontSize: _fontSize * 0.875,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Número de teléfono',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: _fontSize * 1.1),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Ej: +56 9 1234 5678',
                        hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        filled: true,
                        fillColor: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveEmergencyNumber,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A4C93),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white, fontSize: _fontSize, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_emergencyNumber.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _clearEmergencyNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.white, fontSize: _fontSize, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Current Number Display
              if (_emergencyNumber.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Número configurado',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: _fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _emergencyNumber,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                          fontSize: _fontSize * 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Este número se llamará al presionar el botón de emergencia en la pantalla principal.',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontSize: _fontSize * 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEmergencyNumber() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showErrorMessage('Por favor, ingrese un número de teléfono');
      return;
    }

    if (!PhoneValidator.isValidPhoneNumber(phone)) {
      _showErrorMessage('Por favor, ingrese un número de teléfono válido\n(7-15 dígitos, puede incluir +, espacios, guiones y paréntesis)');
      return;
    }

    try {
      String formattedPhone = PhoneValidator.formatPhoneNumber(phone);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emergency_contact', formattedPhone);
      
      setState(() {
        _emergencyNumber = formattedPhone;
      });
      
      _phoneController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Número de emergencia guardado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving emergency number: $e');
      _showErrorMessage('Error al guardar número. Por favor, inténtalo de nuevo.');
    }
  }

  void _clearEmergencyNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('emergency_contact');
      
      setState(() {
        _emergencyNumber = '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Número de emergencia eliminado'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error clearing emergency number: $e');
      _showErrorMessage('Error al eliminar número. Por favor, inténtalo de nuevo.');
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
