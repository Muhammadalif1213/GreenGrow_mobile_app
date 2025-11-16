import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen_update.dart';
import 'package:provider/provider.dart';
import 'package:greengrow_app/core/providers/auth_provider.dart';
import 'package:greengrow_app/core/providers/notification_provider.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';
import 'package:greengrow_app/data/repositories/auth_repository_impl.dart';
import 'package:greengrow_app/data/repositories/location_repository.dart';
import 'package:greengrow_app/data/repositories/notification_repository.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:greengrow_app/presentation/pages/auth/login_screen.dart';
import 'package:greengrow_app/presentation/pages/auth/register_screen.dart';
import 'package:greengrow_app/presentation/pages/admin/admin_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/notification/notification_screen.dart';
import 'package:greengrow_app/presentation/pages/advance/splash_screen.dart';
import 'package:greengrow_app/presentation/pages/advance/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authProvider = AuthProvider();
  await authProvider.loadStoredData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationRepository(
              Dio(),
              const FlutterSecureStorage(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi notifikasi (FCM + local notification)
    NotificationService.initialize(context);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>(
          create: (context) => Dio(),
        ),
        RepositoryProvider<FlutterSecureStorage>(
          create: (context) => const FlutterSecureStorage(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            dio: context.read<Dio>(),
            secureStorage: context.read<FlutterSecureStorage>(),
          ),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) => NotificationRepository(
            context.read<Dio>(),
            context.read<FlutterSecureStorage>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'GreenGrow',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/splash', // Change initial route to splash screen
          routes: {
            '/splash': (context) =>
                const SplashScreen(), // Add splash screen route
            '/welcome': (context) => const WelcomePage(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/farmer-dashboard': (context) => const FarmerDashboardScreenUpdate(),
            '/notifications': (context) => const NotificationScreen(),
          },
        ),
      ),
    );
  }
}
