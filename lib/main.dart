import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/services/church_service.dart';
import 'core/services/notification_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Pré-charger les 33K églises en background pendant que l'app démarre
  ChurchService().warmUpBundle();
  runApp(const CathoApp());
}

class CathoApp extends StatelessWidget {
  const CathoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refuge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light, // app toujours en mode sombre custom
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Halo doré centré
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primary.withValues(alpha: 0.22),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo teinté or
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.45),
                        blurRadius: 52,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppTheme.primary.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.65),
                        ], stops: const [0.15, 1.0]),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.32),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            AppTheme.primary,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/logo.webp',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Refuge',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
