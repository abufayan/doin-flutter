import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/widgets/password_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _lengthValid = false;
  bool _caseValid = false;
  bool _numberValid = false;
  bool _specialCharValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      _lengthValid = password.length >= 8 && password.length <= 15;
      _caseValid =
          RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password);
      _numberValid = RegExp(r'\d').hasMatch(password);
      _specialCharValid =
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  bool get _isPasswordValid =>
      _lengthValid &&
      _caseValid &&
      _numberValid &&
      _specialCharValid;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          FocusManager.instance.primaryFocus?.unfocus();

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.router.push(const WhatsAppNumberRoute());
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  /// Logo
                  Center(
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFFF9F1D),
                          child: Text(
                            'D',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Doin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9F1D),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
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
                        text: 'Welcome to ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Doin FX',
                            style: TextStyle(
                              color: Color(0xFFFF9F1D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Set Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  /// Password
                  PasswordField(
                    'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }, 
                    label: 'Password',
                  ),

                  const SizedBox(height: 12),

                  /// Validation rules
                  _ValidationRow(
                    text: '8 to 15 characters',
                    isValid: _lengthValid,
                  ),
                  _ValidationRow(
                    text: 'At least 1 upper and 1 lower case letter',
                    isValid: _caseValid,
                  ),
                  _ValidationRow(
                    text: 'At least 1 number',
                    isValid: _numberValid,
                  ),
                  _ValidationRow(
                    text: 'At least 1 special character',
                    isValid: _specialCharValid,
                  ),

                  const SizedBox(height: 16),

                  /// Confirm password
                  PasswordField(
                    'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    }, label: 'Confirm Password',
                  ),

                  const Spacer(),

                  /// Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final password =
                            _passwordController.text.trim();
                        final confirmPassword =
                            _confirmPasswordController.text.trim();

                        if (!_isPasswordValid) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Password does not meet requirements'),
                            ),
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                            ),
                          );
                          return;
                        }

                        context.read<AuthBloc>().add(
                              PasswordSubmitted(
                                password: password,
                                confirmPasssword: confirmPassword,
                              ),
                            );
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reusable validation row widget
class _ValidationRow extends StatelessWidget {
  final String text;
  final bool isValid;

  const _ValidationRow({
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
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
