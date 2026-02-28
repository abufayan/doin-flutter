import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:doin_fx/widgets/doin_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  final String? message;

  const LoginScreen({super.key, this.message});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'mukeshmr2004@gmail.com');
  final _passwordCtrl = TextEditingController(text: 'Mukesh@123');
  bool obscureText = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Show snackbar if message is passed from previous screen
    if (widget.message != null && widget.message!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.message!),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            elevation: 6.0,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthActionState,
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), duration: const Duration(seconds: 2), backgroundColor: Colors.green),
          );
          // Navigate to home after brief delay to show snackbar
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.router.replaceAll([const HomeRoute()]);
            }
          });
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), duration: const Duration(seconds: 3), backgroundColor: Colors.red),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Row(mainAxisAlignment: .center, children: [DoinDesign()]),
                  const SizedBox(height: 100),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: 'Welcome Back !',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Login to continue to your account.',
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 40),
                  const Text('User Email', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'Enter Your Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: obscureText,

                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off),

                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => context.router.safePush(const RegisterRoute()),
                        child: const Text(
                          'Register Now',
                          style: TextStyle(fontSize: 12, color: Color(0xFFFF9800), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 250),
                  // Spacer(flex: 2,),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => context.read<AuthBloc>().add(
                              LoginSubmitted(email: _emailCtrl.text.trim(), password: _passwordCtrl.text),
                            ),
                      child: isLoading
                          ? AppLoaders.buttonLoader()
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        context.router.safePush(const ForgotPasswordRoute());
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 13, color: Color(0xFFFF9800), fontWeight: FontWeight.w500),
                      ),
                    ),
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
