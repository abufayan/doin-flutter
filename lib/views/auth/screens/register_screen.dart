import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../bloc/auth_bloc.dart';
// import '../../../core/routes/app_router.gr.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) => current is AuthActionState,
  listener: (context, state) {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (state is OtpSentSuccessfully) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.router.push(
          OtpRoute(email: emailCtrl.text.trim()),
        );
      });
    }

    if (state is AuthFailure) {
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
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('User Name', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'salman.K',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Email ID', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  FormBuilderTextField(
                    name: 'email',
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'salman.k@gmail.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(), 
                    ]),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  // TextField(
                  //   controller: emailCtrl,
                  //   decoration: InputDecoration(
                  //     prefixIcon: const Icon(Icons.email_outlined),
                  //     hintText: 'salman.k@gmail.com',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                              RegisterSubmitted(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                              ),
                            ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
