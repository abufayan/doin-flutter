import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.email});

  final String email;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthActionState && previous != current,
      listener: (context, state) {
        if (!mounted) return;

        // Clear any existing snackbars
        // ScaffoldMessenger.of(context).clearSnackBars();

        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          FocusManager.instance.primaryFocus?.unfocus();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.router.push(SetPasswordRoute());
          });
        } else if (state is AuthFailure) {
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
                children: [
                  const SizedBox(height: 40),
                  Column(
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
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 40),
                  const Text(
                    'Enter Confirmation Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A 4-digit code was sent to\npraveenarjunan8@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate( 
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 48,
                        height: 48,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1) {
                              // Move to next box
                              if (index < _focusNodes.length - 1) {
                                _focusNodes[index + 1].requestFocus();
                              } else {
                                _focusNodes[index].unfocus(); // Last box
                              }
                            } else if (value.isEmpty && index > 0) {
                              // Backspace → previous box
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
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
                                OtpSubmitted(
                                  code: _otpControllers.map((c) => c.text).join(),
                                  email: widget.email
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
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
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
                                OtpSubmitted(
                                  email: widget.email,
                                  code: _otpControllers.map((c) => c.text).join(),
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
                              'Continue',
                              style: TextStyle(
                                fontSize: 15,
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
