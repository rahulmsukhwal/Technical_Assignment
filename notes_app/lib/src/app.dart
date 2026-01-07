import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/auth_page.dart';
import 'features/notes/notes_controller.dart';
import 'features/notes/notes_page.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo.shade500,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Obx(() {
        final authController = Get.find<AuthController>();
        final user = authController.user;
        
        // Check if user is authenticated and email is verified
        if (user != null && user.emailVerified) {
          // Initialize notes controller once when user is authenticated
          if (!Get.isRegistered<NotesController>()) {
            Get.put(NotesController(), permanent: true);
          }
          return const NotesPage();
        }
        
        // If user is authenticated but email is not verified, sign them out
        if (user != null && !user.emailVerified) {
          // Sign out unverified users
          authController.signOut();
        }
        
        return const AuthPage();
      }),
    );
  }
}
