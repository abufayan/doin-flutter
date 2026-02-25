import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/datamodel/contact_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';

import '../bloc/change_password_bloc.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _hasMinLength(String value) => value.length >= 8 && value.length <= 15;

  bool _hasUpperAndLower(String value) => RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value);

  bool _hasNumber(String value) => RegExp(r'(?=.*[0-9])').hasMatch(value);

  bool _hasSpecialChar(String value) => RegExp(r'(?=.*[!@#\$&*~%^()_\-+=<>?/{}|])').hasMatch(value);

  bool _isPasswordValid(String value) =>
      _hasMinLength(value) && _hasUpperAndLower(value) && _hasNumber(value) && _hasSpecialChar(value);

  // Controllers
  final oldPasswordCtrl = TextEditingController();

  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    newPasswordCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    oldPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordBloc()..add(LoadData()),
      child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        // buildWhen: (previous, current) => current is! ActionState,
        // listenWhen: (previous, current) => current is ActionState,
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            // Clear fields
            oldPasswordCtrl.clear();
            newPasswordCtrl.clear();
            confirmPasswordCtrl.clear();
            setState(() => errorMessage = null);

            // Clear token and logout
            Future.delayed(const Duration(seconds: 1), () async {
              await TokenStorageService.clearTokens();
              // Trigger logout event
              if (context.mounted) {
                context.read<AuthBloc>().add(LogoutRequested());
              }
            });
          } else if (state is ChangePasswordError) {
            setState(() => errorMessage = state.message);
          } else if (state is PasswordMismatchError) {
            setState(() => errorMessage = state.message);
          } else if (state is ChangePasswordLoading) {
            setState(() => errorMessage = null);
          }
        },
        builder: (BuildContext context, ChangePasswordState state) {
          ContactData? contactData;

          if (state is ChangePasswordLoading) {
            return Scaffold(
              body: Center(
                child: AppLoaders.loadingIndicator(),
              ),
            );
          }

          if (state is ChangePasswordLoaded) {
            contactData = state.contactData;
          }

          return Scaffold(
            appBar: AppBar(leading: const BackButton(), title: const Text('Change Password'), centerTitle: false),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Error message display
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// Old Password
                    _label('Old Password'),
                    _input(
                      controller: oldPasswordCtrl,
                      obscure: !showOldPassword,
                      suffix: IconButton(
                        icon: Icon(showOldPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => showOldPassword = !showOldPassword),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// New Password
                    _label('New Password'),
                    _input(
                      controller: newPasswordCtrl,
                      obscure: !showNewPassword,
                      suffix: IconButton(
                        icon: Icon(showNewPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => showNewPassword = !showNewPassword),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Password rules
                    _rule('8 to 15 characters', _hasMinLength(newPasswordCtrl.text)),
                    _rule('At least 1 upper and 1 lower case letter', _hasUpperAndLower(newPasswordCtrl.text)),
                    _rule('At least 1 number', _hasNumber(newPasswordCtrl.text)),
                    _rule('At least 1 special character', _hasSpecialChar(newPasswordCtrl.text)),

                    const SizedBox(height: 20),

                    /// Confirm password
                    _label('Confirm Password'),
                    _input(
                      controller: confirmPasswordCtrl,
                      obscure: !showConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Submit button
                    BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ChangePasswordLoading;

                        return Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 120,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                final password = newPasswordCtrl.text.trim();

                                if (!_isPasswordValid(password)) {
                                  setState(() {
                                    errorMessage = "Password does not meet required criteria.";
                                  });
                                  return;
                                }

                                if (confirmPasswordCtrl.text.trim() != password) {
                                  setState(() {
                                    errorMessage = "Passwords do not match.";
                                  });
                                  return;
                                }

                                context.read<ChangePasswordBloc>().add(
                                  ChangePasswordSubmitted(
                                    oldPassword: oldPasswordCtrl.text.trim(),
                                    newPassword: password,
                                    confirmPassword: confirmPasswordCtrl.text.trim(),
                                  ),
                                );
                              },
                              child: isLoading
                                  ? AppLoaders.buttonLoader()
                                  : const Text('Next', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    /// Support info
                    const Divider(),

                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.circleQuestion, size: 20),
                        const SizedBox(width: 8),
                        const Text('Connect anytime and get instant support.', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'WhatsApp: ${contactData?.whatsappNumber ?? '+00 1234567890'}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: FaIcon(FontAwesomeIcons.envelope, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text('Mail: ${contactData?.email ?? 'contact@doinfx.com'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _input({
    required TextEditingController controller,
    bool obscure = false,
    bool readOnly = false,
    TextInputType keyboard = TextInputType.text,
    Widget? prefix,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _rule(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.cancel, size: 14, color: isValid ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, color: isValid ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
