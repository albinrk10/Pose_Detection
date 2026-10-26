import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PoseDetectionApp());
}

class PoseDetectionApp extends StatelessWidget {
  const PoseDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
    );
  }
}
