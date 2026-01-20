// ignore_for_file: avoid_print

import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

@RoutePage()
class WhatsAppNumberScreen extends StatefulWidget {
  const WhatsAppNumberScreen({super.key});

  @override
  State<WhatsAppNumberScreen> createState() => _WhatsAppNumberScreenState();
}

class _WhatsAppNumberScreenState extends State<WhatsAppNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isAgreed = true;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is UserRegisteredSuccessfully || current is AuthFailure;
      },
      listener: (context, state) {
        if (state is UserRegisteredSuccessfully) {
          FocusManager.instance.primaryFocus?.unfocus();
          
          // Navigate immediately to login and pass the message
          // The snackbar will be shown on the login screen instead
          Future.microtask(() {
            if (mounted) {
              // ignore: use_build_context_synchronously
              context.router.replaceAll([LoginRoute(message: state.message)]);
            }
          });
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              elevation: 6.0,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'WhatsApp Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IntlPhoneField(
                    key: const ValueKey('whatsapp_phone_field'),
                    autovalidateMode: AutovalidateMode.disabled,
                    disableLengthCheck: true,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFF7941D),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    languageCode: "en",
                    onChanged: (phone) {
                      if (!mounted) return;
                    },
                    onCountryChanged: (country) {
                      if (!mounted) return;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _isAgreed,
                          activeColor: Colors.black,
                          onChanged: (value) {
                            if (!mounted) return;
                            setState(() {
                              _isAgreed = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'I agree to the ',
                        style: TextStyle(fontSize: 15),
                      ),
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFF7941D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (!_isAgreed) return;
                              context.read<AuthBloc>().add(
                                WhatsAppNumberSubmitted(
                                  whatsappNumber: _phoneController.text,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
