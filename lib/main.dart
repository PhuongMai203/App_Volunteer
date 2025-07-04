import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';

import 'app_view.dart';
import 'chat/chatbot/gemini_api.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Khởi tạo các service cơ bản
  await _initializeCoreServices();

  final userRepository = FirebaseUserRepo();

  runApp(
    RepositoryProvider<UserRepository>.value(
      value: userRepository,
      child: EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en'), Locale('ja')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        startLocale: const Locale('vi'),
        child: MyApp(userRepository: userRepository),
      ),
    ),
  );

  // KHỞI TẠO CÁC DỊCH VỤ NẶNG SAU KHI ỨNG DỤNG ĐÃ CHẠY
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _initializeHeavyServices();
  });
}

Future<void> _initializeCoreServices() async {
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  await _configureAppCheck();
}

Future<void> _initializeHeavyServices() async {
  try {
    await FirebaseAuth.instance.setLanguageCode("vi");
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      await listModels();
    }
  } on SocketException catch (_) {
    debugPrint('⚠️ No internet connection. Skipping Gemini initialization');
  } catch (e) {
    debugPrint('❌ Error initializing heavy services: $e');
  }
}

Future<void> _configureAppCheck() async {
  try {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    int attempt = 0;
    const maxAttempts = 3;

    while (attempt < maxAttempts) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: isProduction
              ? AndroidProvider.playIntegrity
              : AndroidProvider.debug,
          appleProvider: isProduction
              ? AppleProvider.appAttest
              : AppleProvider.debug,
        );
        final token = await FirebaseAppCheck.instance.getToken(true);
        if (token != null) {
          debugPrint('✅ App Check activated successfully. Token: $token');
        }

      } catch (e) {
        debugPrint('⚠️ App Check activation attempt ${attempt + 1} failed: $e');
        attempt++;
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    // FALLBACK SAU KHI THỬ 3 LẦN
    debugPrint('🔄 Using debug provider as fallback');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

  } catch (e, stack) {
    debugPrint('❌ Critical App Check error: $e');
    debugPrint('Stack trace: $stack');
  }
}
