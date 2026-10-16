import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_services.dart';

import 'customers/customer_home_screen.dart';

import 'register_screen.dart';

import 'admin/admin_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  static const String _savedEmailsKey = 'saved_login_emails';

  static const String _savedEmailKey = 'last_login_email';

  List<String> _savedEmails = [];

  List<String> _emailSuggestions = [];

  bool _showEmailSuggestions = false;

  bool _obscurePassword = true;

  bool _isLoading = false;

  // Load previously used email addresses for suggestions.

  @override
  void initState() {
    super.initState();

    _loadSavedEmails();
  }

  Future<void> _loadSavedEmails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEmails = prefs.getStringList(_savedEmailsKey) ?? [];

      final lastEmail = prefs.getString(_savedEmailKey);

      if (lastEmail != null &&
          lastEmail.trim().isNotEmpty &&
          !savedEmails.contains(lastEmail.trim())) {
        savedEmails.insert(0, lastEmail.trim());
      }

      if (!mounted) return;

      setState(() {
        _savedEmails = savedEmails;
      });
    } catch (e) {
      print('Could not load saved emails: $e');
    }
  }

  void _updateEmailSuggestions(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (_savedEmails.isEmpty) {
        _emailSuggestions = [];

        _showEmailSuggestions = false;

        return;
      }

      _emailSuggestions = _savedEmails
          .where((email) => email.toLowerCase().contains(query))
          .toList();

      _showEmailSuggestions = _emailSuggestions.isNotEmpty;
    });
  }

  // Remember valid email addresses locally so they can be suggested later.
  // Passwords are never stored.
  Future<void> _rememberEmailWhileTyping(String value) async {
    final email = value.trim();

    // Save only when the text looks like a complete email address.
    final isValidEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!isValidEmail) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final emails = prefs.getStringList(_savedEmailsKey) ?? <String>[];

      // Avoid saving the same address more than once (case-insensitive).
      final alreadySaved = emails.any(
        (savedEmail) => savedEmail.toLowerCase() == email.toLowerCase(),
      );

      if (alreadySaved) return;

      emails.insert(0, email);
      if (emails.length > 10) {
        emails.removeRange(10, emails.length);
      }

      await prefs.setStringList(_savedEmailsKey, emails);
      await prefs.setString(_savedEmailKey, email);

      if (!mounted) return;
      setState(() {
        _savedEmails = emails;
        _emailSuggestions = emails
            .where(
              (savedEmail) =>
                  savedEmail.toLowerCase().contains(email.toLowerCase()),
            )
            .toList();
        _showEmailSuggestions = _emailSuggestions.isNotEmpty;
      });
    } catch (e) {
      print('Could not remember typed email: $e');
    }
  }

  // Called whenever the email field changes.
  void _onEmailChanged(String value) {
    _updateEmailSuggestions(value);
    _rememberEmailWhileTyping(value);
  }

  void _selectEmail(String email) {
    setState(() {
      _emailController.text = email;

      _emailController.selection = TextSelection.collapsed(
        offset: email.length,
      );

      _showEmailSuggestions = false;

      _emailSuggestions = [];
    });
  }

  // Save each successfully used email, keeping the newest first.

  Future<void> _saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final normalizedEmail = email.trim();

      final emails = prefs.getStringList(_savedEmailsKey) ?? [];

      emails.removeWhere(
        (savedEmail) =>
            savedEmail.toLowerCase() == normalizedEmail.toLowerCase(),
      );

      emails.insert(0, normalizedEmail);

      // Keep the list manageable.

      if (emails.length > 10) {
        emails.removeRange(10, emails.length);
      }

      await prefs.setStringList(_savedEmailsKey, emails);

      await prefs.setString(_savedEmailKey, normalizedEmail);

      if (mounted) {
        setState(() {
          _savedEmails = emails;

          _showEmailSuggestions = false;

          _emailSuggestions = [];
        });
      }
    } catch (e) {
      print('Could not save email: $e');
    }
  }

  // Continue as guest.

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,

      MaterialPageRoute(
        builder: (context) => const CustomerHomeScreen(isGuest: true),
      ),
    );
  }

  // Login.

  Future<void> _login() async {
    final String email = _emailController.text.trim();

    final String password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email.')));

      return;
    }

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
      final Map<String, dynamic>? userData = await _authService.loginUser(
        email: email,

        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Login failed.

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

      // Save email after successful authentication.

      await _saveEmail(email);

      if (!mounted) return;

      // Get the user's role from Firestore.

      final String role = userData['role']?.toString().trim() ?? '';

      // CUSTOMER.

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

      // RESTAURANT ADMIN.

      if (role == 'Restaurant Admin') {
        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),

          (route) => false,
        );

        return;
      }

      // KITCHEN STAFF.

      if (role == 'Kitchen Staff') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kitchen dashboard will be connected later.'),
          ),
        );

        return;
      }

      // DELIVERY DRIVER.

      if (role == 'Delivery Driver') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver dashboard will be connected later.'),
          ),
        );

        return;
      }

      // UNKNOWN ROLE.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role.isEmpty
                ? 'No account role was found.'
                : 'Unknown account role: $role',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      print('Login error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,

        children: [
          // Background image.
          Image.network(
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1600',

            fit: BoxFit.cover,
          ),

          // Dark overlay.
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
                        // AFZ LOGO.
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

                        // TITLE.
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

                        // EMAIL.
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

                          autofillHints: const [AutofillHints.email],

                          onChanged: _onEmailChanged,

                          onTap: () {
                            if (_savedEmails.isNotEmpty) {
                              _updateEmailSuggestions(_emailController.text);
                            }
                          },

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

                        if (_showEmailSuggestions &&
                            _emailSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6),

                            constraints: const BoxConstraints(maxHeight: 180),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(color: Colors.grey.shade300),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),

                                  blurRadius: 8,

                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),

                            child: ListView.separated(
                              shrinkWrap: true,

                              padding: EdgeInsets.zero,

                              itemCount: _emailSuggestions.length,

                              separatorBuilder: (context, index) => Divider(
                                height: 1,

                                color: Colors.grey.shade200,
                              ),

                              itemBuilder: (context, index) {
                                final email = _emailSuggestions[index];

                                return ListTile(
                                  dense: true,

                                  leading: const Icon(
                                    Icons.email_outlined,

                                    color: Color(0xFFFF642F),
                                  ),

                                  title: Text(
                                    email,

                                    style: const TextStyle(fontSize: 14),
                                  ),

                                  onTap: () => _selectEmail(email),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 18),

                        // PASSWORD.
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

                          autofillHints: const [AutofillHints.password],

                          onSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },

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

                        // FORGOT PASSWORD.
                        Align(
                          alignment: Alignment.centerRight,

                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
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

                        // LOGIN BUTTON.
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

                        // OR DIVIDER.
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

                        // CONTINUE AS GUEST.
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

                        // CREATE ACCOUNT.
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

                        // GUEST INFORMATION.
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
