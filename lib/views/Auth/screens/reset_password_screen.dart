import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/widgets/doin_design.dart';
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

  bool get _hasValidLength =>
      _password.length >= 8 && _password.length <= 15;

  bool get _hasUpperAndLower =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_password);

  bool get _hasNumber =>
      RegExp(r'(?=.*\d)').hasMatch(_password);

  bool get _hasSpecialChar =>
      RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(_password);

  String _password = '';
  String _confirmPassword = '';
  String _otp = '';
  bool otpVerified = false;

  bool obscure = true;
  bool obscureConfirm = true;

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
         
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                    mainAxisAlignment: .center,
                    children: [
                      DoinDesign(),
                    ],
                  ),

                  SizedBox(height: 25,),

                    const Text(
                      'Set a new account password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 35),
                    const Text(
                      'Reset your password',
                      style: TextStyle(
                         fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),

                    Text('Create a new password to secure your account.', style: TextStyle(fontWeight: .w300)),

                    const SizedBox(height: 25), 


                    /// OTP
                    const Text('Enter Your OTP', style: TextStyle(fontWeight: .bold),),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
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
                    const Text('Password', style: TextStyle(fontWeight: .bold),),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: obscure,
                      onChanged: (v) {
                        setState(() {
                          _password = v;
                        });
                      },
                      validator: _passwordValidator,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
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
                    _PasswordRule(
                      text: '8 to 15 characters',
                      isValid: _hasValidLength,
                    ),
                    _PasswordRule(
                      text: 'At least 1 upper and 1 lower case letter',
                      isValid: _hasUpperAndLower,
                    ),
                    _PasswordRule(
                      text: 'At least 1 number',
                      isValid: _hasNumber,
                    ),
                    _PasswordRule(
                      text: 'At least 1 special character',
                      isValid: _hasSpecialChar,
                    ),

                    const SizedBox(height: 30),

                    /// CONFIRM PASSWORD
                    const Text(
                      'Confirm Password',
                      style: TextStyle(fontWeight: .bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                    
                      obscureText: obscureConfirm,
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
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)) 
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => obscureConfirm = !obscureConfirm);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 85),

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
  final bool isValid;

  const _PasswordRule({
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.check_circle_outline,
            size: 16,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
