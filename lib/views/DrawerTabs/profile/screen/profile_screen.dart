import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/DrawerTabs/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      /// 🔥 ALL VALUES HERE
      debugPrint(values.toString());

      // Example:
      // values['name']
      // values['email']
      // values['country']
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = getIt<MyAccountService>().user;
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: FormBuilder(
                initialValue: {
                  'account_id': '${user?.userId}',
                  'name': '${user?.username}',
                  'email': '${user?.email}',
                },
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      /// Avatar
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        child: Text(
                          'P',
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _field(
                          'account_id',
                          'Account ID',
                          // initialValue: '1564892',
                          enabled: true,
                          isReadOnly: true
                      ),

                      _field('name', 'Name', isReadOnly: true),

                      _field(
                          'email',
                          'Email Address',
                          keyboard: TextInputType.emailAddress,
                          isReadOnly: true
                      ),

                      _field(
                        'whatsapp',
                        'WhatsApp Number',
                        keyboard: TextInputType.phone,
                      ),

                      _field('dob', 'Date of Birth'),
                      _field('nationality', 'Nationality'),
                      _field('country', 'Country of Residence'),
                      _field('address', 'Address'),
                      _field('city', 'City'),
                      _field('employment', 'Employment Status'),
                      _field('income_source', 'Source of Income'),
                      _field('savings', 'Savings / Investments'),
                      _field('annual_income', 'Annual Income'),
                      _field('occupation', 'Occupation'),

                      _field(
                          'referral', 'Referral Code (Optional)', required: false),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text('Submit', style: TextStyle(color: Colors
                              .white)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user, size: 16, color: Colors.grey),
                          SizedBox(width: 6),
                          Text(
                            'All data is encrypted for security purpose',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      },
),
    );
  }

  /// Reusable FormBuilder field
  Widget _field(String name,
      String label, {
        String? initialValue,
        bool enabled = true,
        bool required = false,
        bool isReadOnly = false,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          FormBuilderTextField(
            name: name,
            initialValue: initialValue,

            // 👇 THIS is the key change
            enabled: true,
            readOnly: isReadOnly,
            // true for Account ID, Email etc.

            keyboardType: keyboard,

            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),

            cursorColor: Colors.black,

            validator: required ? FormBuilderValidators.required() : null,

            decoration: InputDecoration(
              filled: true,
              // fillColor: Colors.grey.shade200,
              // fillColor: Colors.grey.shade400,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
