import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/DrawerTabs/profile/bloc/profile_bloc.dart';
import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _savedInitialValue = {};

  void _submit(BuildContext context) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      context.read<ProfileBloc>().add(
        OnSubmit(formData: _formKey.currentState!.value),
      );
    }
  }

  final labelStyle = const TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

  final valueStyle = const TextStyle(fontSize: 14, color: Colors.black);

  final hintStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey.shade500,
    fontStyle: FontStyle.italic,
  );

  InputDecoration _decoration({String? errorText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorText: errorText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            showSnackbar(context, state.message, success: true);
          }
          if (state is ProfileFailure) {
            showSnackbar(context, state.error, success: false);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return AppLoaders.loadingIndicator();
          }

          if (state is ProfileLoaded) {
            _savedInitialValue = state.initialValue;
          }

          final bool isLocked =
              _savedInitialValue.isNotEmpty &&
              _savedInitialValue['profile_completed'] == 1;

          final bool isReferralLocked =
              _savedInitialValue.isNotEmpty &&
              (_savedInitialValue['referred_by_id'] != null &&
                  _savedInitialValue['referred_by_id'].toString().isNotEmpty);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.white,
            ),
            body: SafeArea(
              child: FormBuilder(
                key: _formKey,
                initialValue: state is ProfileLoaded ? state.initialValue : {},
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange,
                          child: Text(
                            state is ProfileLoaded &&
                                    (state.initialValue['username']
                                            ?.toString()
                                            .isNotEmpty ??
                                        false)
                                ? state.initialValue['username']
                                      .toString()[0]
                                      .toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _textField('id', 'Account ID', readOnly: true),
                      _textField('username', 'Name', readOnly: true),
                      _textField('email', 'Email Address', readOnly: true),
                      _textField(
                        'whatsapp_number',
                        'WhatsApp Number',
                        readOnly: true,
                      ),

                      const SizedBox(height: 14),
                      Text('Date of Birth', style: labelStyle),
                      const SizedBox(height: 6),
                      FormBuilderDateTimePicker(
                        enabled: !isLocked,
                        name: 'date_of_birth',
                        inputType: InputType.date,
                        format: DateFormat('dd/MM/yyyy'),
                        decoration: _decoration(),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'DOB is required',
                          ),
                        ]),
                      ),

                      _textField(
                        'nationality',
                        'Nationality',
                        readOnly: isLocked ? true : false,
                      ),
                      _textField(
                        'country',
                        'Country of Residence',
                        readOnly: isLocked ? true : false,
                      ),
                      _textField(
                        'address',
                        'Address',
                        readOnly: isLocked ? true : false,
                      ),
                      _textField(
                        'city',
                        'City',
                        readOnly: isLocked ? true : false,
                      ),

                      _dropdown(
                        name: 'employment_status',
                        label: 'Employment Status',
                        hint: 'Select employment status',
                        items: const [
                          'Employed',
                          'Self-employed',
                          'Employed (Part Time)',
                          'Unemployed',
                          'Marketing / PR',
                          'Student',
                          'Retired',
                        ],
                        locked: isLocked,
                      ),

                      _dropdown(
                        name: 'source_of_income',
                        label: 'Source of Income',
                        hint: 'Select source of income',
                        items: const [
                          'Savings',
                          'Employment / Business Proceeds',
                          'Rent',
                          'Borrowed Fund / Loan',
                          'Pension',
                          'Inheritance',
                        ],
                        locked: isLocked,
                      ),

                      _dropdown(
                        name: 'trading_experience',
                        label: 'Trading Experience',
                        hint: 'Select trading experience',
                        items: const [
                          'Yes, I have less than 1 year of trading experience',
                          'Yes, I have 1+ years of trading experience',
                          'Yes, I have 2+ years of trading experience',
                          'Yes, I have 4+ years of trading experience',
                          'No, I have no trading experience',
                        ],
                        locked: isLocked,
                      ),

                      _dropdown(
                        name: 'income_range',
                        label: 'Annual Income',
                        hint: 'Select annual income',
                        items: const [
                          'UNDER_20K',
                          '20K_50K',
                          '50K_100K',
                          '100K_200K',
                          'MORE_THAN_200K',
                        ],
                        displayMap: const {
                          'UNDER_20K': '\$0 - \$20,000',
                          '20K_50K': '\$20,000 - \$50,000',
                          '50K_100K': '\$50,000 - \$100,000',
                          '100K_200K': '\$100,000 - \$200,000',
                          'MORE_THAN_200K': 'More than \$200,000',
                        },
                        locked: isLocked,
                      ),

                      _dropdown(
                        name: 'occupation',
                        label: 'Occupation',
                        hint: 'Select occupation',
                        items: const [
                          'Accountancy',
                          'Admin / Secretarial',
                          'Agriculture',
                          'Catering / Hospitality',
                          'Marketing / PR',
                          'Education',
                          'Engineering',
                          'Healthcare',
                          'HR',
                          'IT',
                          'Others',
                        ],
                        locked: isLocked,
                      ),

                      _textField(
                        'referred_by_id',
                        'Referral Code (Optional)',
                        required: false,
                        readOnly: isReferralLocked ? true : false,
                      ),

                      const SizedBox(height: 24),

                      if (!isLocked || !isReferralLocked)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'All data is encrypted for security purpose',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
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

  Widget _textField(
    String name,
    String label, {
    bool readOnly = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 6),
          FormBuilderTextField(
            name: name,
            readOnly: readOnly,
            validator: required ? FormBuilderValidators.required() : null,
            decoration: _decoration(),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String name,
    required String label,
    required String hint,
    required List<String> items,
    Map<String, String>? displayMap,
    required bool locked,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormBuilderField<String>(
        name: name,
        validator: locked ? null : FormBuilderValidators.required(),
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: field.value,
                isExpanded: true,
                //
                hint: Text(hint, style: hintStyle),
                decoration: _decoration(errorText: field.errorText),
                items: items
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(displayMap?[v] ?? v),
                      ),
                    )
                    .toList(),
                onChanged: locked ? null : field.didChange,
              ),
            ],
          );
        },
      ),
    );
  }
}
