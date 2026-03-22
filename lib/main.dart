import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'views/common/landing_view.dart';
import 'view_models/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Temporary seed for Admin account
  await _createAdminSeed();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MakanJeApp(),
    ),
  );
}

class MakanJeApp extends StatelessWidget {
  const MakanJeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makan Je',
      theme: AppTheme.lightTheme,
      home: const LandingView(), // Root is now the Landing Page
    );
  }
}

Future<void> _createAdminSeed() async {
  try {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    
    try {
      await auth.signInWithEmailAndPassword(email: 'admin@gmail.com', password: 'admin123');
      debugPrint('SEED: Admin account already exists.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        UserCredential uc = await auth.createUserWithEmailAndPassword(
          email: 'admin@gmail.com', 
          password: 'admin123',
        );
        await db.collection('users').doc(uc.user!.uid).set({
          'email': 'admin@gmail.com',
          'role': 'manager',
        });
        debugPrint('SEED: Successfully created admin@gmail.com account!');
      } else {
        debugPrint('SEED Firebase Auth Error: \${e.message}');
      }
    }
  } catch (e) {
    debugPrint('SEED Error: \$e');
  }
}
