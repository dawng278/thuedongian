import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/invoices_provider.dart';
import 'providers/revenue_provider.dart';
import 'services/api_service.dart';
import 'services/http_api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final api = HttpApiService(baseUrl: 'http://localhost:3000');
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
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
      title: 'TaxEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF004AC6),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF2563EB),
          onPrimaryContainer: Color(0xFFEEEFFF),
          secondary: Color(0xFF00668A),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFF40C2FD),
          onSecondaryContainer: Color(0xFF004D6A),
          tertiary: Color(0xFF4D556B),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFF656D84),
          onTertiaryContainer: Color(0xFFEEF0FF),
          error: Color(0xFFBA1A1A),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF93000A),
          surface: Color(0xFFF8F9FF),
          onSurface: Color(0xFF0B1C30),
          onSurfaceVariant: Color(0xFF434655),
          outline: Color(0xFF737686),
          outlineVariant: Color(0xFFC3C6D7),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF213145),
          onInverseSurface: Color(0xFFEAF1FF),
          inversePrimary: Color(0xFFB4C5FF),
          surfaceTint: Color(0xFF0053DB),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFC3C6D7), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF0B1C30),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Color(0x14000000),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF004AC6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF004AC6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          selectedColor: const Color(0xFF2563EB),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFFC3C6D7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => const HomeScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}
