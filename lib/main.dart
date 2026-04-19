import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/main_layout/ui/main_screen.dart';
import 'features/split_bill/logic/groups_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيز للـ Web والمنصات التانية
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY", // هاتها من Firebase Console -> Project Settings
        appId: "YOUR_APP_ID",   // هاتها من Firebase Console
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_PROJECT_ID.appspot.com",
      ),
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MasroufyApp());
}

class MasroufyApp extends StatelessWidget {
  const MasroufyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupsCubit(),
      child: MaterialApp(
        title: 'Masroufy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF085652)),
        ),
        home: const MainScreen(),
      ),
    );
  }
}