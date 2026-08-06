import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TradingCopyApp());
}

class TradingCopyApp extends StatelessWidget {
  const TradingCopyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antigravity CopyTrader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF58A6FF),
          secondary: Color(0xFF50FA7B),
          surface: Color(0xFF161B22),
          background: Color(0xFF0D1117),
          error: Color(0xFFFF5555),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF161B22),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFC9D1D9)),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Models
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
  });
}

class TradeAlert {
  final String message;
  final String type; // info, success, warning, danger
  final DateTime timestamp;

  TradeAlert({
    required this.message,
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
  int _currentIndex = 0;

  // Licensing State
  String _licenseToken = "ACT-9928-TRDR-X7";
  bool _isLicenseVerified = true;
  String _licenseStatus = "Activa";
  int _licenseDaysLeft = 24;

  // Account State
  double _accountBalance = 10450.25;
  double _floatingPnl = 124.50;

  // API Config State
  String _apiKey = "pk_live_51Nx...8hYt";
  String _apiSecret = "********";
  String _brokerServer = "MetaQuotes-Demo";
  String _accountNumber = "8827394";

  // Simulated Trades Data
  final List<TradeSignal> _activeTrades = [
    TradeSignal(
      id: "1",
      symbol: "EURUSD",
      type: "BUY",
      entryPrice: 1.08540,
      currentPrice: 1.08620,
      sl: 1.08100,
      tp: 1.09200,
      pnl: 80.00,
      time: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    TradeSignal(
      id: "2",
      symbol: "GBPUSD",
      type: "SELL",
      entryPrice: 1.26420,
      currentPrice: 1.26385,
      sl: 1.26900,
      tp: 1.25500,
      pnl: 35.00,
      time: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    TradeSignal(
      id: "3",
      symbol: "XAUUSD",
      type: "BUY",
      entryPrice: 2034.50,
      currentPrice: 2035.45,
      sl: 2025.00,
      tp: 2050.00,
      pnl: 9.50,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  // Simulated Alerts Data
  final List<TradeAlert> _alerts = [
    TradeAlert(
      message: "Operación abierta automáticamente: BUY XAUUSD a 2034.50",
      type: "info",
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    TradeAlert(
      message: "Operación abierta automáticamente: SELL GBPUSD a 1.26420",
      type: "info",
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    TradeAlert(
      message: "Orden EURUSD movida a Break Even (+0.5 pips)",
      type: "success",
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    TradeAlert(
      message: "Operación cerrada: TP tocado en BTCUSD (+240.00 USD)",
      type: "success",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TradeAlert(
      message: "Operación cerrada: SL tocado en USDJPY (-85.00 USD)",
      type: "danger",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  Timer? _priceUpdateTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Simulate real-time PnL / Price fluctuations
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        double newFloatingPnl = 0.0;
        for (var trade in _activeTrades) {
          double change = (_random.nextDouble() - 0.49) * (trade.symbol == "XAUUSD" ? 0.4 : 0.0001);
          trade.currentPrice += change;
          
          // Re-calculate PnL
          if (trade.type == "BUY") {
            trade.pnl = (trade.currentPrice - trade.entryPrice) * (trade.symbol == "XAUUSD" ? 100 : 10000);
          } else {
            trade.pnl = (trade.entryPrice - trade.currentPrice) * (trade.symbol == "XAUUSD" ? 100 : 10000);
          }
          newFloatingPnl += trade.pnl;
        }
        _floatingPnl = newFloatingPnl;
      });
    });
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  void _verifyLicense(String token) {
    setState(() {
      if (token.isNotEmpty && token.length > 5) {
        _licenseToken = token;
        _isLicenseVerified = true;
        _licenseStatus = "Activa";
        _licenseDaysLeft = 30; // resets for demo
        _alerts.insert(
          0,
          TradeAlert(
            message: "Licencia verificada con éxito. Token cargado.",
            type: "success",
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _isLicenseVerified = false;
        _licenseStatus = "Inválida / Vencida";
        _licenseDaysLeft = 0;
      }
    });
  }

  void _saveApiConfig(String apiKey, String secret, String server, String acc) {
    setState(() {
      _apiKey = apiKey;
      _apiSecret = secret.replaceAll(RegExp(r'.'), '*');
      _brokerServer = server;
      _accountNumber = acc;
      _alerts.insert(
        0,
        TradeAlert(
          message: "Credenciales de API y Servidor de Broker actualizados.",
          type: "info",
          timestamp: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Color(0xFF50FA7B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildLicenseScreen(),
      _buildDashboardScreen(),
      _buildAlertsScreen(),
      _buildConfigScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFF50FA7B)),
            const SizedBox(width: 8),
            Text(
              'Antigravity CopyTrader',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isLicenseVerified
                  ? const Color(0xFF50FA7B).withOpacity(0.15)
                  : const Color(0xFFFF5555).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLicenseVerified
                    ? const Color(0xFF50FA7B)
                    : const Color(0xFFFF5555),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: _isLicenseVerified
                      ? const Color(0xFF50FA7B)
                      : const Color(0xFFFF5555),
                ),
                const SizedBox(width: 6),
                Text(
                  _isLicenseVerified ? 'Licencia OK' : 'Sin Licencia',
                  style: TextStyle(
                    color: _isLicenseVerified
                        ? const Color(0xFF50FA7B)
                        : const Color(0xFFFF5555),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF58A6FF),
        unselectedItemColor: const Color(0xFF8B949E),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key_rounded),
            label: 'Licencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Operaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Configurar',
          ),
        ],
      ),
    );
  }

  // --- SCREENS ---

  // 1. License Screen
  Widget _buildLicenseScreen() {
    final tokenController = TextEditingController(text: _licenseToken);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Sistema',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifica tu token de acceso para activar el copiado de señales automático.',
            style: TextStyle(color: Color(0xFF8B949E)),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estado de Licencia:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isLicenseVerified
                              ? const Color(0xFF50FA7B).withOpacity(0.2)
                              : const Color(0xFFFF5555).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _licenseStatus.toUpperCase(),
                          style: TextStyle(
                            color: _isLicenseVerified
                                ? const Color(0xFF50FA7B)
                                : const Color(0xFFFF5555),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFF30363D)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiempo Restante:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _isLicenseVerified ? '$_licenseDaysLeft Días' : 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ingresar Token de Licencia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tokenController,
            decoration: InputDecoration(
              hintText: 'Ej. ACT-XXXX-XXXX-XX',
              fillColor: const Color(0xFF161B22),
              filled: true,
              prefixIcon: const Icon(Icons.key, color: Color(0xFF58A6FF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF58A6FF), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _verifyLicense(tokenController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58A6FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Validar Licencia',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Dashboard Screen (Operations)
  Widget _buildDashboardScreen() {
    return Column(
      children: [
        // Account Status Banner Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2937), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
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
                        'CUENTA CONECTADA',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MT4 Account: $_accountNumber',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF50FA7B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'CONECTADO',
                      style: TextStyle(
                        color: Color(0xFF50FA7B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFF30363D)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance de Cuenta',
                        style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_accountBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'PnL Flotante',
                        style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_floatingPnl >= 0 ? '+' : ''}\$${_floatingPnl.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _floatingPnl >= 0
                              ? const Color(0xFF50FA7B)
                              : const Color(0xFFFF5555),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Live Operations List Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Operaciones en Tiempo Real',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live',
                    style: TextStyle(color: const Color(0xFF58A6FF).withOpacity(0.8), fontSize: 13),
                  ),
                ],
              )
            ],
          ),
        ),

        // Trades List
        Expanded(
          child: _activeTrades.isEmpty
              ? const Center(
                  child: Text(
                    'No hay operaciones abiertas en este momento.',
                    style: TextStyle(color: Color(0xFF8B949E)),
                  ),
                )
              : ListView.builder(
                  itemCount: _activeTrades.length,
                  itemBuilder: (context, index) {
                    final trade = _activeTrades[index];
                    final isBuy = trade.type == "BUY";
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isBuy
                                            ? const Color(0xFF50FA7B).withOpacity(0.2)
                                            : const Color(0xFFFF5555).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        trade.type,
                                        style: TextStyle(
                                          color: isBuy
                                              ? const Color(0xFF50FA7B)
                                              : const Color(0xFFFF5555),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      trade.symbol,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${trade.pnl >= 0 ? '+' : ''}\$${trade.pnl.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: trade.pnl >= 0
                                        ? const Color(0xFF50FA7B)
                                        : const Color(0xFFFF5555),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: Color(0xFF30363D)),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTradeDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }

  // 3. Alerts & History Screen
  Widget _buildAlertsScreen() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        IconData icon = Icons.info_outline;
        Color color = const Color(0xFF58A6FF);

        if (alert.type == "success") {
          icon = Icons.check_circle_outline_rounded;
          color = const Color(0xFF50FA7B);
        } else if (alert.type == "danger") {
          icon = Icons.error_outline_rounded;
          color = const Color(0xFFFF5555);
        }

        return Card(
          child: ListTile(
            leading: Icon(icon, color: color, size: 28),
            title: Text(
              alert.message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}:${alert.timestamp.second.toString().padLeft(2, '0')} - '
              '${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year}',
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
            ),
          ),
        );
      },
    );
  }

  // 4. Broker / API Configuration Screen
  Widget _buildConfigScreen() {
    final apiController = TextEditingController(text: _apiKey);
    final secretController = TextEditingController(text: _apiSecret);
    final serverController = TextEditingController(text: _brokerServer);
    final accountController = TextEditingController(text: _accountNumber);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración del Broker',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configura tus llaves de API y el servidor del broker para enlazar y copiar automáticamente.',
            style: TextStyle(color: Color(0xFF8B949E)),
          ),
          const SizedBox(height: 24),
          const Text('API Key / Token de Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: apiController,
            decoration: _buildInputDecoration('Ingresar API Key', Icons.lock_open),
          ),
          const SizedBox(height: 16),
          const Text('API Secret / Password', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: secretController,
            obscureText: true,
            decoration: _buildInputDecoration('Ingresar Password/Secret', Icons.lock_outline),
          ),
          const SizedBox(height: 16),
          const Text('Servidor de Trading (MT4/MT5)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: serverController,
            decoration: _buildInputDecoration('Ej. MetaQuotes-Demo', Icons.dns_rounded),
          ),
          const SizedBox(height: 16),
          const Text('Número de Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: accountController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration('Ej. 8827394', Icons.account_balance_wallet_rounded),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _saveApiConfig(
                  apiController.text,
                  secretController.text,
                  serverController.text,
                  accountController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50FA7B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar Configuración',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      fillColor: const Color(0xFF161B22),
      filled: true,
      prefixIcon: Icon(icon, color: const Color(0xFF8B949E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF58A6FF), width: 2),
      ),
    );
  }
}
