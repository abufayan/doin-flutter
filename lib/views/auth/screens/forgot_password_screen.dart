import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => 
        current is AuthActionState && previous != current,
      listener: (context, state) {
        if (!mounted) return;
        
        // Clear any existing snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
        
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9800),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'D',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Doin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const Text(
                          'Mobi 1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 22),
                        children: [
                          TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Doin FX',
                            style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Email ID',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'praveenarjunan8@gmail.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => context.read<AuthBloc>().add(
                                    ForgotPasswordSubmitted(
                                      emailCtrl.text.trim(),
                                    ),
                                  ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
