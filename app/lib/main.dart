import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/invoices_provider.dart';
import 'providers/revenue_provider.dart';
import 'providers/stores_provider.dart';
import 'services/api_service.dart';
import 'services/http_api_service.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/taxeasy_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  final apiBaseUrl =
      envUrl.isNotEmpty ? envUrl : 'http://localhost:3000';
  final api = HttpApiService(baseUrl: apiBaseUrl);
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => StoresProvider(api)),
        ChangeNotifierProvider(create: (_) => ProductsProvider(api)),
        ChangeNotifierProvider(create: (_) => InvoicesProvider(api)),
        ChangeNotifierProvider(create: (_) => RevenueProvider(api)),
      ],
      child: const TaxEasyApp(),
    ),
  );
}

class TaxEasyApp extends StatelessWidget {
  const TaxEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThueDonGian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: TaxEasyColors.primary,
          onPrimary: TaxEasyColors.surface,
          primaryContainer: TaxEasyColors.primaryContainer,
          onPrimaryContainer: Color(0xFFEEEFFF),
          secondary: Color(0xFF00668A),
          onSecondary: TaxEasyColors.surface,
          secondaryContainer: TaxEasyColors.secondary,
          onSecondaryContainer: Color(0xFF004D6A),
          tertiary: Color(0xFF4D556B),
          onTertiary: TaxEasyColors.surface,
          tertiaryContainer: Color(0xFF656D84),
          onTertiaryContainer: Color(0xFFEEF0FF),
          error: TaxEasyColors.error,
          onError: TaxEasyColors.surface,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF93000A),
          surface: TaxEasyColors.surface,
          onSurface: TaxEasyColors.textPrimary,
          onSurfaceVariant: TaxEasyColors.textSecondary,
          outline: TaxEasyColors.outline,
          outlineVariant: TaxEasyColors.outlineVariant,
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF213145),
          onInverseSurface: Color(0xFFEAF1FF),
          inversePrimary: Color(0xFFB4C5FF),
          surfaceTint: Color(0xFF0053DB),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: TaxEasyColors.background,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: TaxEasyColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TaxEasyRadii.card)),
            side: BorderSide(color: TaxEasyColors.outlineVariant, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: TaxEasyColors.surface,
          foregroundColor: TaxEasyColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Color(0x14000000),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: TaxEasyColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TaxEasyColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: TaxEasyColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: TaxEasyColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: TaxEasyColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: TaxEasyColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: TaxEasyColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: TaxEasyColors.surface,
          selectedColor: TaxEasyColors.primaryContainer,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          side: const BorderSide(color: TaxEasyColors.outlineVariant),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    setState(() => _showOnboarding = !done);
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    // Chờ kiểm tra onboarding flag (SharedPreferences) — AuthProvider tự xử lý riêng
    if (_showOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Đang restore session từ token đã lưu → spinner
    if (status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Đã đăng nhập → vào thẳng HomeScreen, bỏ qua onboarding
    if (status == AuthStatus.authenticated) {
      return const HomeScreen();
    }

    // Chưa đăng nhập — lần đầu cài app → Onboarding
    if (_showOnboarding!) {
      return OnboardingScreen(
        onDone: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_done', true);
          if (mounted) setState(() => _showOnboarding = false);
        },
      );
    }

    return const WelcomeScreen();
  }
}
