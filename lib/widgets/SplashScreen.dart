import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Icon(Icons.local_hospital, size: 72, color: Colors.blue),
            Image.asset(
                    'assets/icon/app_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
            const SizedBox(height: 24),
            const Text(
              'Prescriptor',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Preparing your workspace…',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
