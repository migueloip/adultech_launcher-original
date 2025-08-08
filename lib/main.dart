import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
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
                      child: const Text('Anterior'),
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
                    child: Text(_currentStep == 3 ? 'Finalizar' : 'Siguiente'),
                  ),
                ],
              ),
            ],
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
            fontSize: 24,
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
                          fontSize: 18,
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
                          fontSize: 18,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Tamaño de letra',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Selecciona el tamaño de letra que prefieras',
          style: TextStyle(
            fontSize: 16,
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
      ],
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Cómo te llamas?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Este nombre aparecerá en tu pantalla de bienvenida',
          style: TextStyle(
            fontSize: 16,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _nameController,
          style: TextStyle(
            fontSize: 20,
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
      ],
    );
  }

  Widget _buildEmergencyContactStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Contacto de emergencia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Este número se llamará cuando presiones el botón de emergencia',
          style: TextStyle(
            fontSize: 16,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _emergencyContactController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: 20,
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
      ],
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
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa tu nombre');
      return;
    }
    
    if (_emergencyContactController.text.trim().isEmpty) {
      _showErrorDialog('Por favor, ingresa un contacto de emergencia');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('initial_setup_completed', true);
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('emergency_contact', _emergencyContactController.text.trim());

    if (mounted) {
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (context) => const LauncherScreen()),
       );
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
    _loadInstalledApps();
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

  Future<void> _loadInstalledApps() async {
    try {
      print('Cargando aplicaciones instaladas...');
      List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
      
      // Lista de paquetes del sistema que queremos excluir
      Set<String> systemPackagesToExclude = {
        'com.android.systemui',
        'com.android.settings',
        'com.android.launcher',
        'com.android.inputmethod',
        'com.android.keychain',
        'com.android.providers',
        'com.android.server',
        'com.google.android.gms',
        'com.google.android.gsf',
        'com.google.android.setupwizard',
        'com.google.android.partnersetup',
        'com.google.android.configupdater',
        'com.google.android.syncadapters',
        'com.google.android.backuptransport',
        'com.google.android.feedback',
        'com.google.android.onetimeinitializer',
        'com.google.android.ext.services',
        'com.google.android.webview',
        'com.google.android.tts',
        'com.google.android.packageinstaller'
      };
      
      // Filtrar aplicaciones válidas
      List<AppInfo> validApps = apps.where((app) {
        if (app.name == null || app.name!.isEmpty || 
            app.packageName == null || app.packageName!.isEmpty) {
          return false;
        }
        
        String packageName = app.packageName!;
        
        // Excluir paquetes específicos del sistema
        if (systemPackagesToExclude.any((systemPkg) => packageName.startsWith(systemPkg))) {
          return false;
        }
        
        // Excluir aplicaciones del sistema Android básico
        if (packageName.startsWith('com.android.') && 
            !packageName.contains('camera') && 
            !packageName.contains('contacts') && 
            !packageName.contains('dialer') && 
            !packageName.contains('gallery')) {
          return false;
        }
        
        // Permitir aplicaciones de Google útiles
        return true;
      }).toList();
      
      // Ordenar alfabéticamente
      validApps.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
      
      setState(() {
        _installedApps = validApps;
      });
      
      print('Se cargaron ${_installedApps.length} aplicaciones válidas');
    } catch (e) {
      print('Error loading installed apps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar aplicaciones: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: SafeArea(
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
          // Voice Assistant Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4C93),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fontSize * 1.125,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
              child: app.icon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        app.icon!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.android,
                      color: Colors.white,
                      size: 30,
                    ),
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
          InstalledApps.startApp(packageName);
          appLaunched = true;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Abriendo $appName...'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          break;
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

  void _launchInstalledApp(AppInfo app) {
    try {
      // Verificar que el packageName no sea null o vacío
      if (app.packageName == null || app.packageName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: No se puede abrir ${app.name ?? 'la aplicación'} - Información de paquete no disponible'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Intentando abrir aplicación: ${app.name} con packageName: ${app.packageName}');
      
      InstalledApps.startApp(app.packageName!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo ${app.name ?? 'aplicación'}...'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al abrir aplicación ${app.name}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir ${app.name ?? 'la aplicación'}: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Ajustes',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: _fontSize * 1.25),
          ),
        ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            // Settings Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Accesibilidad',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize * 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsTile(
                    'Lector de pantalla',
                    'Objeto, texto o botón será leído en voz alta al... leer más',
                    Icons.visibility,
                    false,
                    () {},
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsTile(
                    'Ajustar Texto',
                    'Cambia el tamaño del texto.',
                    Icons.text_fields,
                    null,
                    () => _showTextSizeDialog(),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Configurar launcher',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize * 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsTile(
                    'Contactos de emergencia',
                    'Agrega un contacto para llamar con el botón del inicio.',
                    Icons.emergency,
                    null,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmergencyContactsScreen(fontSize: _fontSize, isDarkMode: _isDarkMode)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsTile(
                    'Alternar modo 🌟',
                    'Cambia entre modo claro o oscuro esto cambia... leer más',
                    Icons.brightness_6,
                    null,
                    () => _toggleDarkMode(),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsTile(
                    'Conectar familiar',
                    'Ajusta al familiar que podrá conectarse a... leer más',
                    Icons.family_restroom,
                    null,
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String description, IconData icon, bool? hasSwitch, VoidCallback onTap) {
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
                color: _isDarkMode ? Colors.grey[700] : Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
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
                      fontSize: _fontSize,
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
            if (hasSwitch != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: hasSwitch ? const Color(0xFF6A4C93) : Colors.grey[600],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  hasSwitch ? 'Activar' : 'Desactivar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4C93),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Acceder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
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
}

class EmergencyContactsScreen extends StatefulWidget {
  final double fontSize;
  final bool isDarkMode;
  
  const EmergencyContactsScreen({super.key, required this.fontSize, required this.isDarkMode});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late bool _isDarkMode;
  late double _fontSize;
  
  final List<Map<String, String>> _contacts = [
    {'name': 'Familiar', 'phone': '+56 9 1234 5678', 'description': 'Se llamará a este familiar al presionar el botón del inicio.'},
    {'name': 'Familiar', 'phone': '+56 9 5679 1234', 'description': 'Se llamará a este familiar al presionar el botón del inicio.'},
    {'name': 'Familiar', 'phone': '+56 9 3456 1278', 'description': 'Se llamará a este familiar al presionar el botón del inicio.'},
  ];

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
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Add Contact Section
            Container(
              margin: const EdgeInsets.all(20),
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
                          color: _isDarkMode ? Colors.grey[700] : Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_add,
                          color: _isDarkMode ? Colors.white : Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contacto de emergencia',
                              style: TextStyle(
                                color: _isDarkMode ? Colors.white : Colors.black,
                                fontSize: _fontSize * 1.125,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Agrega a un contacto para llamar con el botón del inicio.',
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
                  const SizedBox(height: 20),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: _fontSize),
                    decoration: InputDecoration(
                      hintText: 'Ingrese un nombre',
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      filled: true,
                      fillColor: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Número',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: _fontSize * 0.875,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _phoneController,
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: _fontSize),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Ej +56 9 1934 4592',
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      filled: true,
                      fillColor: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4C93),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Agregar',
                        style: TextStyle(color: Colors.white, fontSize: _fontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contacts List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Agregados',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontSize: _fontSize * 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
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
                            color: _isDarkMode ? Colors.grey[700] : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: _isDarkMode ? Colors.white : Colors.black,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['name']!,
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.white : Colors.black,
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                contact['description']!,
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: _fontSize * 0.75,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Número • ${contact['phone']!}',
                                style: TextStyle(
                                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: _fontSize * 0.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A4C93),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        _contacts.add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'description': 'Se llamará a este familiar al presionar el botón del inicio.',
        });
      });
      _nameController.clear();
      _phoneController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacto agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
