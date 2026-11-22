
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
  );

  await Supabase.initialize(
    url: 'https://euoaxvfwbuzxzuyehyoj.supabase.co',
    publishableKey: 'sb_publishable_vsUC0vJmhML-OtnNwl5HBA_YE86LdMC',
    accessToken: () async {
      return firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
    },
  );

  runApp(const StudyAI());
}

class StudyAI extends StatelessWidget {
  const StudyAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyAI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1020),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B78FF),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
