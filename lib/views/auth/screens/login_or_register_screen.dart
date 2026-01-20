import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class LoginOrRegisterScreen extends StatefulWidget {
  const LoginOrRegisterScreen({super.key});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen> {
  int counter = 0;

  void increment() {
    setState(() => counter++);
  }

  @override
  void initState() {
    super.initState();
    // Check auth status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
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
        
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        
        // If session is restored, navigate to dashboard
        if (state is SessionRestored) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.router.replaceAll([const HomeRoute()]);
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9800),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'D',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Doin',
                        style: TextStyle(
                          fontSize: 22,
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
                  const SizedBox(height: 48),
                  RichText(
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
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.person_outline,
                          text: 'Open a free account',
                          onTap: () => context.router.push(const RegisterRoute()),
                        ),
                        Divider(height: 1, color: Colors.grey.shade400),
                        _ActionTile(
                          icon: Icons.login,
                          text: 'Login to Doin',
                          onTap: () => context.router.push(LoginRoute()),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.orange, size: 14),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Trusted by traders focused on growing their wealth with confidence.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
