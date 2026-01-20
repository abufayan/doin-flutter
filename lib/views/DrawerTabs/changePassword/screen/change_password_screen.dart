import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/change_password_bloc.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controllers
  final oldPasswordCtrl = TextEditingController();

  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

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
      create: (context) => ChangePasswordBloc(),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Change Password'),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                const SizedBox(height: 12),



                const SizedBox(height: 24),

                /// OTP
                _label('Old Password'),
                _input(
                  controller: oldPasswordCtrl,
                  obscure: !showPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),

                const SizedBox(height: 24),

                /// Password
                _label('New Password'),
                _input(
                  controller: newPasswordCtrl,
                  obscure: !showPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),

                const SizedBox(height: 8),

                /// Password rules
                _rule('8 to 15 characters'),
                _rule('At least 1 upper and 1 lower case letter'),
                _rule('At least 1 number'),

                const SizedBox(height: 20),

                /// Confirm password
                _label('Confirm Password'),
                _input(
                  controller: confirmPasswordCtrl,
                  obscure: !showConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(
                                () =>
                            showConfirmPassword = !showConfirmPassword),
                  ),
                ),

                const SizedBox(height: 30),

                /// Next button
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // validate + submit
                      },
                      child: const Text('Next', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// Support info
                const Divider(),

                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.circleQuestion, size: 14),
                    const SizedBox(width: 8),
                    const Text(
                      'Connect anytime and get instant support.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'WhatsApp: +44 7488 848671',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: FaIcon(
                        FontAwesomeIcons.envelope,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mail: contact@rirafx.com',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _rule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
