import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/screens/auth_screen.dart';
import 'package:thyna_core/screens/main_screen.dart';
import 'package:thyna_core/utils/logger.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      binds: [Bind.put(MainController())],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF037EF3), brightness: Brightness.light),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      defaultTransition: Transition.cupertino,
      logWriterCallback: (text, {isError = false}) async {
        debugPrint("[DEBUG] $text\n");
        await Logger.log(text);
      },
      getPages: [
        GetPage(
          name: "/main",
          page: () => const MainScreen(),
        ),
        GetPage(
          name: "/auth",
          page: () => const AuthScreen(),
        ),
      ],
      initialRoute: "/auth",
    );
  }
}
