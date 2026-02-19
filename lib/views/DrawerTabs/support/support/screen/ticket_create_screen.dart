import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:doin_fx/views/DrawerTabs/support/support/bloc/support_bloc.dart';
import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class TicketCreateScreen extends StatefulWidget {
  const TicketCreateScreen({super.key, required this.ticketType});

  final String ticketType;

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  final TextEditingController descriptionCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 🔄 Rebuild UI when description changes so counter updates
    descriptionCtrl.addListener(() => setState(() {}));
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // optional compression
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportBloc, SupportState>(
      listener: (BuildContext context, state) {
        if (state is SupportError) {
          showSnackbar(context, state.message, success: false);
        }
        if (state is SupportSuccess) {
          showSnackbar(context, state.message, success: true);
          // Navigator.pop(context); // Go back to TicketTypeScreen (OLD)

          // Go back to HelpCenterScreen (New)
          context.router.popUntil((route) {
            return route.settings.name == HelpCenterRoute.name;
          });

          context.read<SupportBloc>().add(LoadTickets());
        }
      },
      builder: (BuildContext context, state) {
        final isLoading = state is SupportLoading;

        return Scaffold(
          appBar: AppBar(leading: const BackButton(), title: const Text('Help Center')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== HEADER =====
                const Text(
                  'Kindly Provide\nDetails',
                  style: TextStyle(
                    fontSize: 32, // exact large header feel
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== INFO BOX =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'Please fill out the form, and our support team will review your request. '
                    'We’ll get back to you shortly. Submitting this form helps us resolve '
                    'your concerns faster and ensures you receive the assistance you need.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),

                const SizedBox(height: 24),

                /// ===== DESCRIPTION =====
                const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                          // autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: descriptionCtrl,
                          maxLines: 6,
                          maxLength: 5000,
                          inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                          decoration: const InputDecoration(
                            hintText: 'Kindly provide more information on your request.',
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${descriptionCtrl.text.length} / 5000',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ===== DROPZONE =====
                InkWell(
                  onTap: _pickImage,
                  child: DottedBorder(
                    color: Colors.orange,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: SizedBox(
                      height: 160, // ✅ FIX: bounded height
                      width: double.infinity,
                      child: _selectedImage == null
                          // ───────── EMPTY STATE ─────────
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Provide files in JPG or PDF format,\nmaximum size 10 MB.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            )
                          // ───────── IMAGE PREVIEW ─────────
                          : Stack(
                              fit: StackFit.expand, // ✅ important
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover, // ✅ no infinite size
                                  ),
                                ),

                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedImage = null);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// ===== CONFIRM BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;

                            context.read<SupportBloc>().add(
                              CreateTicketPressed(
                                description: descriptionCtrl.text,
                                subject: widget.ticketType,
                                imagePath: _selectedImage?.path ?? '',
                              ),
                            );
                          },
                    child: isLoading
                        ? AppLoaders.buttonLoader()
                        : const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ===== BACK BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE8D2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
