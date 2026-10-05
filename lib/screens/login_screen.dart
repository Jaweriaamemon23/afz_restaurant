import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_services.dart';
import 'customers/customer_home_screen.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerHomeScreen(isGuest: true),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // Check email
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
      return;
    }

    // Check password
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login through AuthService
      final Map<String, dynamic>? userData = await _authService.loginUser(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Login failed
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to login. Please check your email and password.',
            ),
          ),
        );
        return;
      }

      // Get role from Firestore
      final String role = userData['role']?.toString().trim() ?? '';

      // ========================================================
      // CUSTOMER
      // ========================================================

      if (role == 'Customer') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerHomeScreen(isGuest: false),
          ),
          (route) => false,
        );

        return;
      }

      // ========================================================
      // RESTAURANT ADMIN
      // ========================================================

      if (role == 'Restaurant Admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          (route) => false,
        );

        return;
      }

      // ========================================================
      // KITCHEN STAFF
      // ========================================================

      if (role == 'Kitchen Staff') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kitchen dashboard will be connected later.'),
          ),
        );

        return;
      }

      // ========================================================
      // DELIVERY DRIVER
      // ========================================================

      if (role == 'Delivery Driver') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver dashboard will be connected later.'),
          ),
        );

        return;
      }

      // ========================================================
      // UNKNOWN ROLE
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role.isEmpty
                ? 'No account role was found.'
                : 'Unknown account role: $role',
          ),
        ),
      );
    }
    // ============================================================
    // FIREBASE AUTH ERROR
    // ============================================================
    on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    // ============================================================
    // OTHER ERROR
    // ============================================================
    catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1600',
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.42),
                  Colors.black.withOpacity(0.72),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==================================================
                        // AFZ LOGO
                        // ==================================================
                        Center(
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF642F),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF642F,
                                  ).withOpacity(0.30),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'AFZ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // TITLE
                        // ==================================================
                        const Text(
                          'Welcome to AFZ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // EMAIL
                        // ==================================================
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // PASSWORD
                        // ==================================================
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // FORGOT PASSWORD
                        // ==================================================
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFFFF642F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF642F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // OR DIVIDER
                        // ==================================================
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade500),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade500),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // CONTINUE AS GUEST
                        // ==================================================
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _continueAsGuest,
                            icon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFFFF642F),
                            ),
                            label: const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: Color(0xFFFF642F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF642F)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // CREATE ACCOUNT
                        // ==================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Color(0xFFFF642F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ==================================================
                        // GUEST INFORMATION
                        // ==================================================
                        Text(
                          'Guests can browse the restaurant. '
                          'Login is required to place an order.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
