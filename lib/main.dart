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
  int _currentIndex = 0;

  // Licensing State
  String _licenseToken = "ACT-9928-TRDR-X7";
  bool _isLicenseVerified = true;
  String _licenseStatus = "Licencia Activa";
  int _licenseDaysLeft = 24;

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
    super.dispose();
  }

  void _verifyLicense(String token) {
    setState(() {
      if (token.isNotEmpty && token.length > 5) {
        _licenseToken = token;
        _isLicenseVerified = true;
        _licenseStatus = "Licencia Activa";
        _licenseDaysLeft = 24; // demo constant
        _alerts.insert(
          0,
          TradeAlert(
            message: "Licencia verificada con éxito. Token cargado.",
            category: "Sistema",
            type: "success",
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _isLicenseVerified = false;
        _licenseStatus = "Licencia Vencida";
        _licenseDaysLeft = 0;
      }
    });
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  backgroundColor: _isLicenseVerified
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF4D4D),
                ),
                const SizedBox(width: 6),
                Text(
                  _isLicenseVerified ? 'Licencia OK' : 'Sin Licencia',
                  style: TextStyle(
                    color: _isLicenseVerified
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF4D4D),
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
          items: const [
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

  // --- SCREENS REDESIGN ---

  // 1. License Screen
  Widget _buildLicenseScreen() {
    final tokenController = TextEditingController(text: _licenseToken);

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
          
          // License Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D131C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isLicenseVerified
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
                    color: _isLicenseVerified
                        ? const Color(0xFF00E676).withOpacity(0.1)
                        : const Color(0xFFFF4D4D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isLicenseVerified ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
                    color: _isLicenseVerified
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
                        _licenseStatus.toUpperCase(),
                        style: TextStyle(
                          color: _isLicenseVerified
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFF4D4D),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sistema funcionando correctamente',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Remaining Time Card
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
                Text(
                  _isLicenseVerified ? '$_licenseDaysLeft DÍAS' : 'EXPIRADA',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Expira el: 06 / 09 / 2026',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Token de Licencia',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          
          // Token input field
          TextField(
            controller: tokenController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              fillColor: const Color(0xFF0D131C),
              filled: true,
              prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF00E676)),
              suffixIcon: _isLicenseVerified
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
          
          // Validation Button (Premium Green Gradient)
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
              onPressed: () => _verifyLicense(tokenController.text),
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
                    'VALIDAR LICENCIA',
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

  // 2. Dashboard Screen (Operations)
  Widget _buildDashboardScreen() {
    return Column(
      children: [
        // Connected Account Header Card
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

        // Live Title Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Operaciones en Tiempo Real',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 3,
                    backgroundColor: Color(0xFF00E676),
                  ),
                  const SizedBox(width: 6),
                  const Text(
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
            ],
          ),
        ),

        // Trades List
        Expanded(
          child: _activeTrades.isEmpty
              ? const Center(
                  child: Text(
                    'No hay operaciones abiertas en este momento.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              : ListView.builder(
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
                              
                              // Sparkline Widget
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

  // 3. Alerts & History Screen
  Widget _buildAlertsScreen() {
    // Filter logic
    final filteredAlerts = _selectedAlertFilter == "Todas"
        ? _alerts
        : _alerts.where((alert) => alert.category == _selectedAlertFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
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

        // Horizontal filter pills
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

        // Alerts List
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

                    // Map icon and color to mimic screenshot design
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

  // 4. Broker / API Configuration Screen
  Widget _buildConfigScreen() {
    final apiController = TextEditingController(text: _apiKey);
    final secretController = TextEditingController(text: _apiSecret);
    final serverController = TextEditingController(text: _brokerServer);
    final accountController = TextEditingController(text: _accountNumber);

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
          
          // API Key field
          const Text('API Key / Token de Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: apiController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _buildInputDecoration('Ingresar API Key', Icons.lock_open),
          ),
          const SizedBox(height: 16),
          
          // API Secret field with visibility toggle
          const Text('API Secret / Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: secretController,
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
          
          // Trading Server dropdown-like input
          const Text('Servidor de Trading (MT4/MT5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: serverController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _buildInputDecoration(
              'Ej. MetaQuotes-Demo',
              Icons.dns_rounded,
              suffix: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 16),
          
          // Account Number
          const Text('Número de Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: accountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _buildInputDecoration('Ej. 8827394', Icons.person_outline),
          ),
          const SizedBox(height: 32),
          
          // Save Button (Premium Green Gradient with Checkmark)
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
                  apiController.text,
                  secretController.text,
                  serverController.text,
                  accountController.text,
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
      // Normalize values between 0.0 and size.height
      double y = size.height - ((data[i] - minVal) / valRange * size.height);
      
      // Ensure border padding
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
