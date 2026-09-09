import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_constants.dart';
import 'core/app_theme.dart';
import 'core/services/notification services/notification_service.dart';

import 'features/admin/auth/bloc/adminauth_bloc.dart';
import 'features/admin/dashboard/bloc/dashboard_bloc.dart';

import 'features/user/auth/bloc/auth_bloc.dart';
import 'features/user/home/bloc/home_bloc.dart';
import 'features/user/profile/bloc/profile_bloc.dart';

import 'features/splash/screen/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await NotificationService.initialize();
  NotificationService.listenForTokenRefresh();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminAuthBloc(),
        ),
        BlocProvider(
          create: (_) => AdminBusBloc(),
        ),


        BlocProvider(
          create: (_) => UserAuthBloc(),
        ),
        BlocProvider(
          create: (_) => HomeBloc(),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}