import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TradingCopyApp());
}

class TradingCopyApp extends StatelessWidget {
  const TradingCopyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sniper Money EA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF060B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF0D131C),
          background: const Color(0xFF060B0E),
          error: Color(0xFFFF4D4D),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF0D131C),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF8B949E)),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Models
class AppUser {
  final String name;
  final String email;
  final String username;
  final String password;
  final String role; // 'admin' or 'user'
  String? licenseToken;
  bool isLicenseActive;
  DateTime? licenseExpiry;

  AppUser({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.role,
    this.licenseToken,
    this.isLicenseActive = false,
    this.licenseExpiry,
  });
}

class TradeSignal {
  final String id;
  final String symbol;
  final String type; // BUY or SELL
  final double entryPrice;
  double currentPrice;
  final double sl;
  final double tp;
  double pnl;
  final DateTime time;
  List<double> priceHistory;

  TradeSignal({
    required this.id,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.currentPrice,
    required this.sl,
    required this.tp,
    required this.pnl,
    required this.time,
    required this.priceHistory,
  });
}

class ClosedTrade {
  final String symbol;
  final String type; // BUY or SELL
  final double entryPrice;
  final double closePrice;
  final double sl;
  final double tp;
  final double pnl;
  final DateTime closeTime;

  ClosedTrade({
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.closePrice,
    required this.sl,
    required this.tp,
    required this.pnl,
    required this.closeTime,
  });
}

class TradeAlert {
  final String message;
  final String category; // 'Operaciones', 'Sistema', 'Errores'
  final String type; // 'info', 'success', 'danger'
  final DateTime timestamp;

  TradeAlert({
    required this.message,
    required this.category,
    required this.type,
    required this.timestamp,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Authentication State
  AppUser? _currentUser;
  
  // --- PERSISTENT TEXT EDITING CONTROLLERS (FIXES TEXT ERASING BUG) ---
  final TextEditingController _loginUserCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();
  
  // Admin panel controllers
  final TextEditingController _adminNameCtrl = TextEditingController();
  final TextEditingController _adminEmailCtrl = TextEditingController();
  final TextEditingController _adminUserCtrl = TextEditingController();
  final TextEditingController _adminPassCtrl = TextEditingController();
  
  // User license screen controller
  final TextEditingController _licenseTokenCtrl = TextEditingController();

  // Broker configuration controllers
  final TextEditingController _apiApiKeyCtrl = TextEditingController();
  final TextEditingController _apiSecretCtrl = TextEditingController();
  final TextEditingController _apiServerCtrl = TextEditingController();
  final TextEditingController _apiAccountCtrl = TextEditingController();

  // Simulated Database of Users
  final List<AppUser> _usersList = [
    AppUser(
      name: "Administrador",
      email: "admin@sniper.com",
      username: "admin",
      password: "12345678",
      role: "admin",
      isLicenseActive: true,
    ),
    AppUser(
      name: "Cliente Demo",
      email: "cliente@demo.com",
      username: "cliente",
      password: "12345678",
      role: "user",
      isLicenseActive: false,
    ),
  ];

  // Global Generated Licenses list
  final List<String> _generatedLicenses = [
    "SNIPER-88A9-99B2-X1",
    "SNIPER-44C1-22E4-F7",
  ];

  // Navigation indices for user / admin
  int _currentIndex = 0;

  // Tab state inside Operations
  bool _showActiveTrades = true;

  // Account State
  double _accountBalance = 10450.25;
  double _floatingPnl = 229.44;
  String _accountNumber = "8827394";

  // API Config State
  String _apiKey = "pk_live_51Nx...8hYt";
  String _apiSecret = "••••••••••••";
  String _brokerServer = "MetaQuotes-Demo";
  bool _obscureApiSecret = true;

  // Horizontal Filter Category for Alerts
  String _selectedAlertFilter = "Todas";

  // Simulated Trades Data
  final List<TradeSignal> _activeTrades = [
    TradeSignal(
      id: "1",
      symbol: "EURUSD",
      type: "BUY",
      entryPrice: 1.08540,
      currentPrice: 1.08673,
      sl: 1.08100,
      tp: 1.09200,
      pnl: 13.34,
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      priceHistory: [1.0854, 1.0857, 1.0852, 1.0861, 1.0865, 1.0862, 1.0867],
    ),
    TradeSignal(
      id: "2",
      symbol: "GBPUSD",
      type: "SELL",
      entryPrice: 1.26420,
      currentPrice: 1.26400,
      sl: 1.26900,
      tp: 1.25500,
      pnl: 1.97,
      time: DateTime.now().subtract(const Duration(minutes: 12)),
      priceHistory: [1.2642, 1.2645, 1.2648, 1.2644, 1.2641, 1.2643, 1.2640],
    ),
    TradeSignal(
      id: "3",
      symbol: "XAUUSD",
      type: "BUY",
      entryPrice: 2034.50,
      currentPrice: 2036.64,
      sl: 2025.00,
      tp: 2050.00,
      pnl: 214.14,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      priceHistory: [2034.5, 2034.2, 2035.1, 2034.9, 2035.8, 2036.2, 2036.64],
    ),
  ];

  // Simulated Closed Trades Data
  final List<ClosedTrade> _closedTrades = [
    ClosedTrade(
      symbol: "BTCUSD",
      type: "BUY",
      entryPrice: 62450.00,
      closePrice: 62690.00,
      sl: 61900.00,
      tp: 62690.00,
      pnl: 240.00,
      closeTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ClosedTrade(
      symbol: "USDJPY",
      type: "SELL",
      entryPrice: 150.45,
      closePrice: 150.62,
      sl: 150.62,
      tp: 150.10,
      pnl: -85.00,
      closeTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ClosedTrade(
      symbol: "EURUSD",
      type: "SELL",
      entryPrice: 1.08720,
      closePrice: 1.08610,
      sl: 1.09100,
      tp: 1.08500,
      pnl: 110.00,
      closeTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ClosedTrade(
      symbol: "GBPUSD",
      type: "BUY",
      entryPrice: 1.26100,
      closePrice: 1.25950,
      sl: 1.25950,
      tp: 1.26700,
      pnl: -45.00,
      closeTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
  ];

  // Simulated Alerts Data
  final List<TradeAlert> _alerts = [
    TradeAlert(
      message: "Operación abierta automáticamente:\nBUY XAUUSD a 2034.50",
      category: "Operaciones",
      type: "info",
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    TradeAlert(
      message: "Operación abierta automáticamente:\nSELL GBPUSD a 1.26420",
      category: "Operaciones",
      type: "info",
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    TradeAlert(
      message: "Orden EURUSD movida a Break Even (+0.5 pips)",
      category: "Sistema",
      type: "success",
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    TradeAlert(
      message: "TP alcanzado en BTCUSD\n(+240.00 USD)",
      category: "Sistema",
      type: "success",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TradeAlert(
      message: "SL alcanzado en USDJPY\n(-85.00 USD)",
      category: "Errores",
      type: "danger",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  Timer? _priceUpdateTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize config controllers text
    _apiApiKeyCtrl.text = _apiKey;
    _apiSecretCtrl.text = _apiSecret;
    _apiServerCtrl.text = _brokerServer;
    _apiAccountCtrl.text = _accountNumber;

    // Simulate real-time PnL / Price fluctuations & update sparklines
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        double newFloatingPnl = 0.0;
        for (var trade in _activeTrades) {
          double change = (_random.nextDouble() - 0.49) * (trade.symbol == "XAUUSD" ? 0.35 : 0.00008);
          trade.currentPrice += change;
          
          // Re-calculate PnL
          if (trade.type == "BUY") {
            trade.pnl = (trade.currentPrice - trade.entryPrice) * (trade.symbol == "XAUUSD" ? 100 : 10000);
          } else {
            trade.pnl = (trade.entryPrice - trade.currentPrice) * (trade.symbol == "XAUUSD" ? 100 : 10000);
          }
          newFloatingPnl += trade.pnl;

          // Append to history for sparkline
          trade.priceHistory.add(trade.currentPrice);
          if (trade.priceHistory.length > 10) {
            trade.priceHistory.removeAt(0);
          }
        }
        _floatingPnl = newFloatingPnl;
      });
    });
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    
    // Dispose all controllers
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    _licenseTokenCtrl.dispose();
    _apiApiKeyCtrl.dispose();
    _apiSecretCtrl.dispose();
    _apiServerCtrl.dispose();
    _apiAccountCtrl.dispose();
    
    super.dispose();
  }

  // --- BUSINESS LOGIC ACTIONS ---

  void _login() {
    final usernameInput = _loginUserCtrl.text.trim();
    final passwordInput = _loginPassCtrl.text;

    AppUser? foundUser;
    for (var user in _usersList) {
      if (user.username.toLowerCase() == usernameInput.toLowerCase() &&
          user.password == passwordInput) {
        foundUser = user;
        break;
      }
    }

    if (foundUser != null) {
      setState(() {
        _currentUser = foundUser;
        _currentIndex = 0;
        _loginUserCtrl.clear();
        _loginPassCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesión iniciada como: ${foundUser.name}'),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
          backgroundColor: Color(0xFFFF4D4D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _logout() {
    setState(() {
      _currentUser = null;
      _currentIndex = 0;
    });
  }

  void _verifyLicense(String token) {
    if (_currentUser == null) return;
    
    // Check if the token is in the list of generated licenses
    if (_generatedLicenses.contains(token.trim())) {
      setState(() {
        _currentUser!.licenseToken = token.trim();
        _currentUser!.isLicenseActive = true;
        _currentUser!.licenseExpiry = DateTime.now().add(const Duration(days: 30));
        
        _alerts.insert(
          0,
          TradeAlert(
            message: "El usuario '${_currentUser!.username}' activó la licencia:\n$token",
            category: "Sistema",
            type: "success",
            timestamp: DateTime.now(),
          ),
        );
      });
      _licenseTokenCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Licencia activada con éxito para ${_currentUser!.name}'),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Licencia no válida o no encontrada en el sistema'),
          backgroundColor: Color(0xFFFF4D4D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _generateLicenseToken() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String part1 = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    String part2 = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    String part3 = List.generate(2, (index) => chars[random.nextInt(chars.length)]).join();
    
    final token = "SNIPER-$part1-$part2-$part3";
    setState(() {
      _generatedLicenses.insert(0, token);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nueva licencia generada: $token'),
        backgroundColor: const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createNewUser(String name, String email, String username, String password) {
    if (name.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor rellene todos los campos'),
          backgroundColor: Color(0xFFFF4D4D),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if username already exists
    if (_usersList.any((u) => u.username.toLowerCase() == username.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de usuario ya existe'),
          backgroundColor: Color(0xFFFF4D4D),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _usersList.add(AppUser(
        name: name,
        email: email,
        username: username,
        password: password,
        role: "user",
        isLicenseActive: false,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario "$username" creado exitosamente'),
        backgroundColor: const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveApiConfig(String apiKey, String secret, String server, String acc) {
    setState(() {
      _apiKey = apiKey;
      _apiSecret = secret;
      _brokerServer = server;
      _accountNumber = acc;
      _alerts.insert(
        0,
        TradeAlert(
          message: "Credenciales de API y Servidor de Broker actualizados.",
          category: "Sistema",
          type: "success",
          timestamp: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- USER DETAILS DIALOG (POPUP DETAILS WINDOW ON LIST CLICK) ---
  void _showUserDetailsDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final hasActive = user.role == 'admin' || user.isLicenseActive;
        return AlertDialog(
          backgroundColor: const Color(0xFF0D131C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(
                user.role == 'admin' ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                color: const Color(0xFF00E676),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Detalles de Usuario',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nombre', user.name),
              _buildDetailRow('Correo', user.email),
              _buildDetailRow('Usuario', '@${user.username}'),
              _buildDetailRow('Contraseña', user.password),
              _buildDetailRow('Rol', user.role == 'admin' ? 'Administrador' : 'Usuario Regular'),
              const Divider(color: Color(0xFF1E293B), height: 24),
              _buildDetailRow(
                'Estado Licencia',
                user.role == 'admin'
                    ? 'No requiere (Admin)'
                    : (user.isLicenseActive ? 'ACTIVA' : 'INACTIVA'),
                valueColor: hasActive ? const Color(0xFF00E676) : const Color(0xFFFF4D4D),
              ),
              if (user.role != 'admin' && user.isLicenseActive) ...[
                const SizedBox(height: 6),
                _buildDetailRow('Token Licencia', user.licenseToken ?? 'N/A'),
                _buildDetailRow(
                  'Expiración',
                  user.licenseExpiry != null
                      ? '${user.licenseExpiry!.day}/${user.licenseExpiry!.month}/${user.licenseExpiry!.year}'
                      : 'N/A',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CERRAR',
                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI SCREENS BUILDERS ---

  @override
  Widget build(BuildContext context) {
    // If not logged in, return the Login Screen
    if (_currentUser == null) {
      return _buildLoginScreen();
    }

    final isAdmin = _currentUser!.role == 'admin';

    final List<Widget> adminScreens = [
      _buildAdminPanelScreen(),
      _buildAdminLicensesScreen(),
      _buildDashboardScreen(),
      _buildConfigScreen(),
    ];

    final List<Widget> userScreens = [
      _buildLicenseScreen(),
      _buildDashboardScreen(),
      _buildAlertsScreen(),
      _buildConfigScreen(),
    ];

    final currentScreen = isAdmin ? adminScreens[_currentIndex] : userScreens[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.gps_fixed, color: Color(0xFF00E676), size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'SNIPER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'MONEY EA',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF060B0E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 20),
            onPressed: _logout,
            tooltip: "Cerrar Sesión",
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D131C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1E293B),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 3.5,
                  backgroundColor: (isAdmin || _currentUser!.isLicenseActive)
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF4D4D),
                ),
                const SizedBox(width: 6),
                Text(
                  (isAdmin || _currentUser!.isLicenseActive) ? 'Licencia OK' : 'Sin Licencia',
                  style: TextStyle(
                    color: (isAdmin || _currentUser!.isLicenseActive)
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF4D4D),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E293B), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF060B0E),
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: isAdmin
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_alt_outlined),
                    label: 'Usuarios',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.vpn_key_outlined),
                    label: 'Licencias',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.tune_rounded),
                    label: 'Operaciones',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Configurar',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flash_on_rounded),
                    label: 'Licencia',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.tune_rounded),
                    label: 'Operaciones',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_none_rounded),
                    label: 'Alertas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Configurar',
                  ),
                ],
        ),
      ),
    );
  }

  // --- LOGIN SCREEN ---
  Widget _buildLoginScreen() {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFF00E676), size: 72),
                const SizedBox(height: 16),
                const Text(
                  'SNIPER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 1.0,
                  ),
                ),
                const Text(
                  'MONEY EA',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingresa tus credenciales para acceder al sistema.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _loginUserCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _buildInputDecoration('Nombre de usuario', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _loginPassCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _buildInputDecoration('Contraseña', Icons.lock_outline),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LOCK METHOD FOR REGULAR USERS ---
  Widget _runLockedPanelWrapper(Widget panel) {
    final isLocked = _currentUser!.role == 'user' && !_currentUser!.isLicenseActive;
    if (isLocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4D).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFFF4D4D),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Debes validar una licencia activa para acceder a este panel. Dirígete a la pestaña "Licencia" e introduce tu token.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return panel;
  }

  // License Screen
  Widget _buildLicenseScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de Licencia',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Verifica tu token de acceso para activar el copiado de señales automático.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D131C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _currentUser!.isLicenseActive
                    ? const Color(0xFF00E676).withOpacity(0.3)
                    : const Color(0xFFFF4D4D).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentUser!.isLicenseActive
                        ? const Color(0xFF00E676).withOpacity(0.1)
                        : const Color(0xFFFF4D4D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentUser!.isLicenseActive ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
                    color: _currentUser!.isLicenseActive
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF4D4D),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser!.isLicenseActive ? "LICENCIA ACTIVA" : "SIN LICENCIA",
                        style: TextStyle(
                          color: _currentUser!.isLicenseActive
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFF4D4D),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentUser!.isLicenseActive
                            ? 'Válida por 30 días.'
                            : 'Debes introducir una licencia del Administrador.',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_currentUser!.isLicenseActive) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D131C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiempo Restante',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '24 DÍAS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Token activo: ${_currentUser!.licenseToken ?? "Ninguno"}',
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Ingresar Token de Licencia',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _licenseTokenCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              fillColor: const Color(0xFF0D131C),
              filled: true,
              hintText: "SNIPER-XXXX-XXXX-XX",
              prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF00E676)),
              suffixIcon: _currentUser!.isLicenseActive
                  ? const Icon(Icons.check_circle, color: Color(0xFF00E676))
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => _verifyLicense(_licenseTokenCtrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'ACTIVAR LICENCIA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF00E676), size: 18),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ADMINISTRATOR MANAGEMENT PANELS ---

  // Admin Panel 1: Create and View Users
  Widget _buildAdminPanelScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Usuarios',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crea nuevos usuarios del sistema Sniper Money EA.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          
          // Form Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0D131C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crear Nuevo Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _adminNameCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: _buildInputDecoration('Nombre Completo', Icons.person_outline),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _adminEmailCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: _buildInputDecoration('Correo Electrónico', Icons.email_outlined),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _adminUserCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: _buildInputDecoration('Nombre de Usuario', Icons.alternate_email),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _adminPassCtrl,
                  obscureText: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: _buildInputDecoration('Contraseña', Icons.lock_outline),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      _createNewUser(
                        _adminNameCtrl.text.trim(),
                        _adminEmailCtrl.text.trim(),
                        _adminUserCtrl.text.trim(),
                        _adminPassCtrl.text,
                      );
                      _adminNameCtrl.clear();
                      _adminEmailCtrl.clear();
                      _adminUserCtrl.clear();
                      _adminPassCtrl.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('CREAR USUARIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Usuarios Registrados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Toca un usuario para ver detalles', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 12),
          
          // User List in DB
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _usersList.length,
            itemBuilder: (context, index) {
              final user = _usersList[index];
              final hasActive = user.role == 'admin' || user.isLicenseActive;
              return GestureDetector(
                onTap: () => _showUserDetailsDialog(user),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D131C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: hasActive ? const Color(0xFF00E676).withOpacity(0.12) : const Color(0xFFFF4D4D).withOpacity(0.12),
                        child: Icon(
                          user.role == 'admin' ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                          color: hasActive ? const Color(0xFF00E676) : const Color(0xFFFF4D4D),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('@${user.username} • ${user.email}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasActive ? const Color(0xFF00E676).withOpacity(0.15) : const Color(0xFFFF4D4D).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role == 'admin' ? 'ADMIN' : (user.isLicenseActive ? 'ACTIVA' : 'INACTIVA'),
                          style: TextStyle(
                            color: hasActive ? const Color(0xFF00E676) : const Color(0xFFFF4D4D),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Admin Panel 2: License Generation & Status Checking
  Widget _buildAdminLicensesScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generador de Licencias',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Genera tokens aleatorios válidos para el registro de clientes.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _generateLicenseToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'GENERAR LICENCIA ALEATORIA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF00E676), size: 16),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Licencias Activas en el Sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 12),
          _generatedLicenses.isEmpty
              ? const Center(child: Text('No hay licencias generadas aún.', style: TextStyle(color: Color(0xFF64748B))))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _generatedLicenses.length,
                  itemBuilder: (context, index) {
                    final license = _generatedLicenses[index];
                    
                    AppUser? userUsing;
                    for (var u in _usersList) {
                      if (u.licenseToken == license) {
                        userUsing = u;
                        break;
                      }
                    }
                    
                    final isUsed = userUsing != null;

                    return GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: license));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Licencia copiada al portapapeles: $license'),
                            backgroundColor: const Color(0xFF00E676),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D131C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.key, color: Color(0xFF00E676), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    license,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isUsed ? 'Activada por: ${userUsing.name} (@${userUsing.username})' : 'Disponible para activación (Toca para copiar)',
                                    style: TextStyle(
                                      color: isUsed ? const Color(0xFF00E676) : const Color(0xFF64748B),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUsed ? const Color(0xFF00E676).withOpacity(0.12) : const Color(0xFF64748B).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isUsed ? 'USADA' : 'LIBRE',
                                style: TextStyle(
                                  color: isUsed ? const Color(0xFF00E676) : const Color(0xFF64748B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- OPERATIONS DASHBOARD ---
  Widget _buildDashboardScreen() {
    return _runLockedPanelWrapper(Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0D131C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuenta Conectada',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MT4 Account: $_accountNumber',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'CONECTADO',
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFF1E293B)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00E676), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Balance de Cuenta',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_accountBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 0.8,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.analytics_outlined, color: Color(0xFF00E676), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'PnL Flotante',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_floatingPnl >= 0 ? '+' : ''}\$${_floatingPnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _floatingPnl >= 0
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFF4D4D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0D131C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showActiveTrades = true),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _showActiveTrades ? const Color(0xFF00E676) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Activas',
                        style: TextStyle(
                          color: _showActiveTrades ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showActiveTrades = false),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_showActiveTrades ? const Color(0xFF00E676) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cerradas',
                        style: TextStyle(
                          color: !_showActiveTrades ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showActiveTrades ? 'Operaciones en Tiempo Real' : 'Historial de Operaciones Cerradas',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _showActiveTrades
                  ? Row(
                      children: const [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF00E676),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: const [
                        Icon(Icons.history_rounded, color: Color(0xFF64748B), size: 13),
                        SizedBox(width: 6),
                        Text(
                          'HISTORIAL',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Expanded(
          child: _showActiveTrades
              ? _buildActiveTradesList()
              : _buildClosedTradesList(),
        ),
      ]));
  }

  Widget _buildActiveTradesList() {
    if (_activeTrades.isEmpty) {
      return const Center(
        child: Text(
          'No hay operaciones abiertas en este momento.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    return ListView.builder(
      itemCount: _activeTrades.length,
      itemBuilder: (context, index) {
        final trade = _activeTrades[index];
        final isBuy = trade.type == "BUY";
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D131C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBuy
                          ? const Color(0xFF00E676).withOpacity(0.12)
                          : const Color(0xFFFF4D4D).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trade.type,
                      style: TextStyle(
                        color: isBuy
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF4D4D),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trade.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 55,
                    height: 24,
                    child: CustomPaint(
                      painter: SparklinePainter(
                        data: trade.priceHistory,
                        color: trade.pnl >= 0
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF4D4D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${trade.pnl >= 0 ? '+' : ''}\$${trade.pnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: trade.pnl >= 0
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF4D4D),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFF1E293B)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTradeDetailColumn('Entry Price', trade.entryPrice.toStringAsFixed(trade.symbol == "XAUUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('Current Price', trade.currentPrice.toStringAsFixed(trade.symbol == "XAUUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('S/L', trade.sl.toStringAsFixed(trade.symbol == "XAUUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('T/P', trade.tp.toStringAsFixed(trade.symbol == "XAUUSD" ? 2 : 5)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClosedTradesList() {
    if (_closedTrades.isEmpty) {
      return const Center(
        child: Text(
          'No hay operaciones cerradas registradas.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    return ListView.builder(
      itemCount: _closedTrades.length,
      itemBuilder: (context, index) {
        final trade = _closedTrades[index];
        final isBuy = trade.type == "BUY";
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D131C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBuy
                          ? const Color(0xFF00E676).withOpacity(0.08)
                          : const Color(0xFFFF4D4D).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trade.type,
                      style: TextStyle(
                        color: isBuy
                            ? const Color(0xFF00E676).withOpacity(0.8)
                            : const Color(0xFFFF4D4D).withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trade.symbol,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trade.pnl >= 0 ? '+' : ''}\$${trade.pnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: trade.pnl >= 0
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF4D4D),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFF1E293B)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTradeDetailColumn('Entry Price', trade.entryPrice.toStringAsFixed(trade.symbol == "XAUUSD" || trade.symbol == "BTCUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('Close Price', trade.closePrice.toStringAsFixed(trade.symbol == "XAUUSD" || trade.symbol == "BTCUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('S/L', trade.sl.toStringAsFixed(trade.symbol == "XAUUSD" || trade.symbol == "BTCUSD" ? 2 : 5)),
                  _buildTradeDetailColumn('T/P', trade.tp.toStringAsFixed(trade.symbol == "XAUUSD" || trade.symbol == "BTCUSD" ? 2 : 5)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Cerrado: ${trade.closeTime.hour.toString().padLeft(2, '0')}:${trade.closeTime.minute.toString().padLeft(2, '0')} - '
                    '${trade.closeTime.day}/${trade.closeTime.month}/${trade.closeTime.year}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTradeDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  // --- ALERTS SCREEN ---
  Widget _buildAlertsScreen() {
    return _runLockedPanelWrapper(Builder(
      builder: (context) {
        final filteredAlerts = _selectedAlertFilter == "Todas"
            ? _alerts
            : _alerts.where((alert) => alert.category == _selectedAlertFilter).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.notifications_active_outlined, color: Color(0xFF00E676), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Alertas del Sistema',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: ["Todas", "Operaciones", "Sistema", "Errores"].map((filter) {
                  final isSelected = _selectedAlertFilter == filter;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF00E676),
                      backgroundColor: const Color(0xFF0D131C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF1E293B),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedAlertFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredAlerts.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay alertas en esta categoría.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = filteredAlerts[index];
                        IconData icon = Icons.info_outline;
                        Color color = const Color(0xFF00E676);

                        if (alert.message.contains("BUY")) {
                          icon = Icons.arrow_upward_rounded;
                          color = const Color(0xFF00E676);
                        } else if (alert.message.contains("SELL")) {
                          icon = Icons.arrow_downward_rounded;
                          color = const Color(0xFFFF4D4D);
                        } else if (alert.message.contains("Break Even")) {
                          icon = Icons.check_circle_outline_rounded;
                          color = const Color(0xFF00E676);
                        } else if (alert.message.contains("TP alcanzado")) {
                          icon = Icons.track_changes_outlined;
                          color = const Color(0xFF00E676);
                        } else if (alert.message.contains("SL alcanzado")) {
                          icon = Icons.cancel_outlined;
                          color = const Color(0xFFFF4D4D);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D131C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1E293B), width: 0.8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.message,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}:${alert.timestamp.second.toString().padLeft(2, '0')}  •  '
                                      '${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year}',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }
    ));
  }

  // --- CONFIG SCREEN ---
  Widget _buildConfigScreen() {
    return _runLockedPanelWrapper(Builder(
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración del Broker',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Configura tus llaves de API y el servidor del broker para enlazar y copiar automáticamente.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),
              const Text('API Key / Token de Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _apiApiKeyCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration('Ingresar API Key', Icons.lock_open),
              ),
              const SizedBox(height: 16),
              const Text('API Secret / Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _apiSecretCtrl,
                obscureText: _obscureApiSecret,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(
                  'Ingresar Password/Secret',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureApiSecret ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureApiSecret = !_obscureApiSecret;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Servidor de Trading (MT4/MT5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _apiServerCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(
                  'Ej. MetaQuotes-Demo',
                  Icons.dns_rounded,
                  suffix: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Número de Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _apiAccountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration('Ej. 8827394', Icons.person_outline),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveApiConfig(
                      _apiApiKeyCtrl.text,
                      _apiSecretCtrl.text,
                      _apiServerCtrl.text,
                      _apiAccountCtrl.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Text(
                        'GUARDAR CONFIGURACIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Color(0xFF00E676), size: 18),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    ));
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      fillColor: const Color(0xFF0D131C),
      filled: true,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
    );
  }
}

// Sparkline Custom Painter
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);

    double minVal = data.reduce(min);
    double maxVal = data.reduce(max);
    double valRange = maxVal - minVal;
    if (valRange == 0) valRange = 1.0;

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - ((data[i] - minVal) / valRange * size.height);
      
      if (y < 2) y = 2;
      if (y > size.height - 2) y = size.height - 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
