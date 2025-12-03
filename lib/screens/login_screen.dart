import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../repos/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MoodDiary',
                            style: GoogleFonts.jua(
                              fontSize: 48,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Start your journey with us',
                            style: GoogleFonts.jua(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 50, height: 40),

                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        width: 340,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Login',
                                style: GoogleFonts.jua(
                                  fontSize: 26,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: GoogleFonts.jua(),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.jua(),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    (value == null || value.length < 6) ? 'At least 6 characters' : null,
                              ),
                              const SizedBox(height: 24),

                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          setState(() {
                                            _isLoading = true;
                                            _message = null;
                                          });
                                          try {
                                            await _authRepo.signIn(
                                              email: _emailController.text,
                                              password: _passwordController.text,
                                            );
                                            await analytics.logLogin(loginMethod: 'email');
                                            setState(() {
                                              _message = 'Login Successful';
                                              _isError = false; 
                                            });
                                            Navigator.pushReplacementNamed(context, '/home');
                                          } catch (e) {
                                            setState(() {
                                              _message = e.toString();
                                              _isError = true; 
                                            });
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Login',
                                          style: GoogleFonts.jua(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),

                              const SizedBox(height: 12),

                              if (_message != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    _message!,
                                    style: GoogleFonts.jua(
                                      color: _isError ? Colors.red : Colors.green,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    setState(() => _isLoading = true);
                                    try {
                                      await _authRepo.signUp(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                      setState(() {
                                        _message = 'SignUp Successful';
                                        _isError = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _message = e.toString();
                                        _isError = true;
                                      });
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                  child: const Text('Sign Up'),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}