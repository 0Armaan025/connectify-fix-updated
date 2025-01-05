import 'dart:async';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:flutter/material.dart';

class UserBlockedPage extends StatefulWidget {
  const UserBlockedPage({Key? key}) : super(key: key);

  @override
  State<UserBlockedPage> createState() => _UserBlockedPageState();
}

class _UserBlockedPageState extends State<UserBlockedPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startListeningForUnblock();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _startListeningForUnblock() {
    bool isUnblocked = false;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final user = await AuthController().getCurrentUser(context);
        if (user != null) {
          isUnblocked = true;
        }
      } catch (e) {}

      if (isUnblocked) {
        timer.cancel(); // Stop the timer
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(
        context, '/'); // Replace '/home' with your home route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Restricted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You are blocked, hehe.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your account has been blocked by Armaan. pretty pwease say him sorry on WA to regain access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
