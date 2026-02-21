import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/widgets/doin_design.dart';
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
  bool _agreedToMarketing = false;
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.push(
              OtpRoute(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              ),
            );
          });
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      DoinDesign(),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Text(
                      'Let’s get you registered!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.3,
                        color: Colors.black,
                      ),
                    )
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Poppins'),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          context.router.push(LoginRoute());
                        },
                        child: const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Poppins'),
                      ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                  // const Text('User Name', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'User Name',
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
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    //  FormBuilderValidators.match(
                    //     RegExp(r'^[\w-\.]+@([\w-]+\.)+com$'),
                    //     errorText: 'Only .com emails allowed',
                    //     ),
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
                  const SizedBox(height: 100),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2), // adjust 1–3 if needed
                        child: Checkbox(
                          value: _agreedToMarketing,
                          activeColor: const Color(0xFFFF9800),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) {
                            setState(() {
                              _agreedToMarketing = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'I agree to receive marketing communications and allow the use of my personal data for marketing optimization and personalized advertising. I understand that I can withdraw my consent at any time.',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
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
                      onPressed: isLoading || !_agreedToMarketing
                          ? null
                          : () => context.read<AuthBloc>().add(
                              RegisterSubmitted(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                              ),
                            ),
                      child: isLoading
                          ? AppLoaders.buttonLoader()
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
                  Text(
                    'By registering, I confirm that I have read, understood, and accepted the Company’s Legal Documents and Privacy Policy. I also acknowledge that I may receive newsletters, company updates, and product-related communications.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
