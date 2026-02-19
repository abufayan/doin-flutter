import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  String _password = '';
  String _confirmPassword = '';
  String _otp = '';
  bool otpVerified = false;

  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is OtpForgotPasswordError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is OtpForgotPasswordSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          otpVerified = true;
        }

        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Replace all routes with login route
          context.router.replaceAll([LoginRoute()]);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Doin FX'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set a new account password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // const SizedBox(height: 6),
                    // const Text(
                    //   'Create a new password to secure your account.',
                    //   style: TextStyle(color: Colors.grey),
                    // ),
                    const SizedBox(height: 24),

                    /// OTP
                    const Text('Enter OTP'),
                    const SizedBox(height: 6),
                    IgnorePointer(
                      ignoring: otpVerified,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _otp = v!.trim(),
                        onChanged: (v) => _otp = v.trim(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'OTP is required';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    IgnorePointer(
                      ignoring: otpVerified,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFFF9800,
                              ), // your brand orange
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                ForgotPasswordSubmitted(
                                  email: widget.email,
                                  code: _otp,
                                ),
                              );
                            },
                            child: const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const SizedBox(height: 16),

                    /// PASSWORD
                    const Text('Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: obscure,
                      onChanged: (v) => _password = v,
                      validator: _passwordValidator,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => obscure = !obscure);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const _PasswordRule('8 to 15 characters'),
                    const _PasswordRule(
                      'At least 1 upper and 1 lower case letter',
                    ),
                    const _PasswordRule('At least 1 number'),
                    const _PasswordRule('At least 1 special character'),

                    const SizedBox(height: 16),

                    /// CONFIRM PASSWORD
                    const Text('Confirm Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: obscure,
                      onChanged: (v) => _confirmPassword = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (v != _password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// CONTINUE
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: loading || otpVerified == false
                            ? null
                            : () {
                                final form = _formKey.currentState!;
                                if (!form.validate()) return;

                                form.save();

                                if (_password != _confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                context.read<AuthBloc>().add(
                                  ResetPasswordRequested(
                                    email: widget.email, // from flow
                                    otp: _otp,
                                    password: _password,
                                    confirmPassword: _confirmPassword,
                                  ),
                                );
                              },
                        child: loading
                            ? AppLoaders.buttonLoader()
                            : const Text(
                                'Continue',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔐 PASSWORD VALIDATOR
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8 || value.length > 15) {
      return 'Password must be 8–15 characters long';
    }

    if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return 'Must contain upper & lower case letters';
    }

    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Must contain at least 1 number';
    }

    if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
      return 'Must contain at least 1 special character';
    }

    return null;
  }
}

/// 🔹 Password rule UI
class _PasswordRule extends StatelessWidget {
  final String text;
  const _PasswordRule(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
