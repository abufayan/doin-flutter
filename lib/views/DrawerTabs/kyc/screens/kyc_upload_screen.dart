import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_bloc.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_event.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class KycUploadScreen extends StatelessWidget {
  const KycUploadScreen({super.key});

  Future<void> _pickFile(
    BuildContext context,
    void Function(PlatformFile) onPicked,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      // allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      onPicked(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KycBloc(),
      child: Scaffold(
        appBar: AppBar(leading: const BackButton(), title: const Text('KYC')),
        body: BlocConsumer<KycBloc, KycState>(
          listener: (context, state) {
            if (state is KycUploadSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              // context.router.replace(const NextRoute());
            }

            if (state is KycUploadFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            // 🔄 Uploading state
            if (state is KycUploading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 🧾 Form state
            if (state is KycFormState) {
              return _buildForm(context, state);
            }

            // fallback (should not happen)
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // FORM UI
  // ----------------------------------------------------------------

  Widget _buildForm(BuildContext context, KycFormState state) {
    final bloc = context.read<KycBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Your Documents',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // ================= IDENTITY =================
          Row(
            children: [
              Image.asset(
                'assets/images/kyc/check.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => Icon(Icons.task_alt, size: 22),
              ),
              const Text(
                'Provide Identity Document',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Document Type'),
              Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              // labelText: 'Document Type *',
              filled: true,
              fillColor: Colors.grey.shade200,
              // grey background
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            // dropdown list background
            icon: const Icon(Icons.keyboard_arrow_down),
            initialValue: state.identityType,
            items: const [
              'Aadhaar Card',
              'Driver’s License',
              'PAN Card',
              'Voter Card',
              'Passport',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) {
                bloc.add(IdentityDocumentSelected(v));
              }
            },
          ),

          if (state.identityType != null) ...[
            const SizedBox(height: 16),
            _uploadBox(
              label: 'Front Side',
              file: state.idFront,
              onTap: () =>
                  _pickFile(context, (f) => bloc.add(IdentityFrontPicked(f))),
            ),
            _uploadBox(
              label: 'Back Side',
              file: state.idBack,
              onTap: () => _pickFile(context, (f) {
                bloc.add(IdentityBackPicked(f));
              }),
            ),
          ],

          const SizedBox(height: 24),

          // ================= BANK =================
          Row(
            children: [
              Image.asset(
                'assets/images/kyc/check.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => Icon(Icons.task_alt, size: 22),
              ),
              const Text(
                'Provide Banking Document',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              Text('Document Type'),
              Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down),
            value: state.bankType,
            items: const [
              'Bank Statement',
              'Bank Passbook Front Page',
              'Bank Document',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) {
                bloc.add(BankingDocumentSelected(v));
              }
            },
          ),

          if (state.bankType != null) ...[
            const SizedBox(height: 16),
            _uploadBox(
              label: 'Front Side',
              file: state.bankFile,
              onTap: () =>
                  _pickFile(context, (f) => bloc.add(BankDocumentPicked(f))),
            ),
          ],

          const SizedBox(height: 100),

          // ================= NEXT =================
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    // state.isValid
                    //     ?
                    () {
                      bloc.add(SubmitKyc());
                    },
                // : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Next', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                'All data is encrypted for security purpose',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // UPLOAD BOX
  // ----------------------------------------------------------------

  Widget _uploadBox({
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.cloud_upload),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file != null
                    ? file.name
                    : '$label\nChoose or drag and drop (maximum size 6 MB)',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
