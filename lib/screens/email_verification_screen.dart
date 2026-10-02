import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_services.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String role;

  const EmailVerificationScreen({super.key, required this.role});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();

  bool isChecking = false;
  bool isResending = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Check periodically in case the user verifies
    // the email while this screen is open.
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkVerification() async {
    if (isChecking) return;

    setState(() {
      isChecking = true;
    });

    final bool verified = await _authService.checkEmailVerified();

    if (!mounted) return;

    if (verified) {
      _timer?.cancel();

      await completeRegistration();
      return;
    }

    setState(() {
      isChecking = false;
    });
  }

  Future<void> completeRegistration() async {
    final String? error = await _authService.completeRegistration(
      role: widget.role,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        isChecking = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));

      return;
    }

    // Registration successfully completed.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Registration Complete'),
          content: const Text(
            'Your email has been verified and your account has been created successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    // Go to Login screen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> resendEmail() async {
    if (isResending) return;

    setState(() {
      isResending = true;
    });

    final String? error = await _authService.resendVerificationEmail();

    if (!mounted) return;

    setState(() {
      isResending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Verification email sent again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1600',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.80),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF642F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Verify Your Email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'We have sent a verification link to your email address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Please open the email and click the verification link. Then return to this app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (isChecking)
                        const Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF642F)),
                            SizedBox(height: 12),
                            Text(
                              'Checking verification...',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isChecking ? null : checkVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF642F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'I Have Verified My Email',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: isResending ? null : resendEmail,
                        child: Text(
                          isResending
                              ? 'Sending...'
                              : 'Resend Verification Email',
                          style: const TextStyle(
                            color: Color(0xFFFF642F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'The app will also check automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
