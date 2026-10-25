import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:test_1/views/pose_detection_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0Xff273338),
      minimumSize: Size(size.width * 0.85, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
    return Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.15,
              ),
              Container(
                alignment: Alignment.center,
                width: size.width * 0.7,
                height: size.width * 0.7,
                child: Lottie.asset(
                  'assets/push-up-animation.json',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Contador de flexiones',
                style: TextStyle(
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2),
              ),
              Container(
                width: size.width * 0.7,
                child: Text(
                  'Tu compañero ideal para tu rutina de ejercicios',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, letterSpacing: -1.1),
                ),
              ),
              Spacer(),
              ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PoseDetectorView(),)
                  );
                },
                child: Text('¡Empezar ahora!'),
              ),
              SizedBox(
                height: size.height * 0.03,
              )
            ],
          ),
        ));
  }
}
