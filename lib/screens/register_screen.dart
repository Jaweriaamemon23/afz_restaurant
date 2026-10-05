import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String selectedRole = 'Customer';

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final List<String> roles = [
    'Customer',
    'Restaurant Admin',
    'Kitchen Staff',
    'Delivery Driver',
  ];

  Future<void> register() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error = await _authService.registerUser(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: selectedRole,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Firebase Authentication account has been created
    // and verification email has been sent.
    //
    // Firestore has NOT been created yet.

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationScreen(role: selectedRole),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF642F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: Color(0xFFFF642F)),
              SizedBox(width: 10),
              Expanded(child: Text('Check Your Email')),
            ],
          ),
          content: const Text(
            'Your account has been created successfully. '
            'A verification email has been sent to your email address. '
            'Please open the email and click the verification link before logging in.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Go to Login',
                style: TextStyle(
                  color: Color(0xFFFF642F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1600',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Logo
                        Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF642F),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Center(
                          child: Text(
                            'Join AFZ Restaurant',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Full Name
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Confirm Password
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          textInputAction: TextInputAction.next,
                          decoration: inputDecoration(
                            hint: 'Confirm your password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Account Type
                        const Text(
                          'Account Type',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 7),

                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: inputDecoration(
                            hint: 'Select account type',
                            icon: Icons.account_circle_outlined,
                          ),
                          items: roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),

                        const SizedBox(height: 28),

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF642F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFFFF642F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFFF642F)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF642F), width: 1.5),
      ),
    );
  }
}
