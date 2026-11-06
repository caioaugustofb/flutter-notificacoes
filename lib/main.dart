import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sem options: no Android le a configuracao do google-services.json.
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  final service = NotificationService.instance;
  await service.init();

  runApp(const AgendaApp());

  WidgetsBinding.instance.addPostFrameCallback(
    (_) => service.tratarAberturaInicial(),
  );
}

class AgendaApp extends StatelessWidget {
  const AgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Tech Belém',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.instance.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
