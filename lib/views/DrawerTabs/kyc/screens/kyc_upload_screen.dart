import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_bloc.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_event.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_state.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/datamodel/kyc_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  Future<void> _pickFile(
    BuildContext context,
    void Function(PlatformFile) onPicked,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      onPicked(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => KycBloc()..add(GetKycData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
            leading: const BackButton(),
            title: const Text('KYC'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(
              height: 4,
              color: const Color(0xFFFFE3C6), //your yellow/orange
            ),
          ),
        ),


        body: BlocConsumer<KycBloc, KycState>(
          buildWhen: (previous, current) => current is! KyccActionState,
          listenWhen: (previous, current) => current is KyccActionState,
          listener: (context, state) {
            if (state is KycUploadSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<KycBloc>().add(GetKycData());
            }

            if (state is KycUploadFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is KycFormState) {
              if (state.isInitialLoading) {
                return AppLoaders.loadingIndicator();
              }
              return _buildForm(context, state);
            }

            // Fallback for when state is only KyccActionState or other
            return AppLoaders.loadingIndicator();
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  Widget _buildForm(BuildContext context, KycFormState state) {
    final bloc = context.read<KycBloc>();

    final kyc = state.kyc;

    final bool isIdentityLocked =
        kyc != null &&
        KycResponse.isLocked(kyc.photo_id_1_status) &&
        KycResponse.isLocked(kyc.photo_id_2_status);

    final bool isBankLocked =
        kyc != null && KycResponse.isLocked(kyc.photo_id_3_status);

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
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.task_alt, size: 22),
              ),
              const SizedBox(width: 6),
              const Text(
                'Provide Identity Document',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('Document Type'),
              Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: isIdentityLocked
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
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
            initialValue: state.identityType,
            items: const [
              DropdownMenuItem(
                value: 'aadhaar card',
                child: Text('Aadhaar Card'),
              ),
              DropdownMenuItem(
                value: 'driving license',
                child: Text("Driver's License"),
              ),
              DropdownMenuItem(value: 'pan card', child: Text('PAN Card')),
              DropdownMenuItem(value: 'voter id', child: Text('Voter ID Card')),
              DropdownMenuItem(value: 'passport', child: Text('Passport')),
            ],
            onChanged: isIdentityLocked
                ? null
                : (v) {
                    if (v != null) {
                      bloc.add(IdentityDocumentSelected(v));
                    }
                  },
          ),

          if (state.identityType != null ||
              state.kyc?.photo_id_1_status != null ||
              state.kyc?.photo_id_2_status != null) ...[
            const SizedBox(height: 16),
            _uploadBox(
              label: 'Front Side',
              file: state.idFront,
              status: state.kyc?.photo_id_1_status,
              onTap: () =>
                  _pickFile(context, (f) => bloc.add(IdentityFrontPicked(f))),
              isSubmitting: state.isSubmitting,
            ),
            _uploadBox(
              label: 'Back Side',
              file: state.idBack,
              status: state.kyc?.photo_id_2_status,
              onTap: () =>
                  _pickFile(context, (f) => bloc.add(IdentityBackPicked(f))),
              isSubmitting: state.isSubmitting,
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
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.task_alt, size: 22),
              ),
              const SizedBox(width: 6),
              const Text(
                'Provide Banking Document',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Row(
            children: const [
              Text('Document Type'),
              Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: isBankLocked
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
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
            initialValue: state.bankType,
            items: const [
              'Bank Statement',
              'Bank Passbook Front Page',
              'Bank Document',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: isBankLocked
                ? null
                : (v) {
                    if (v != null) {
                      bloc.add(BankingDocumentSelected(v));
                    }
                  },
          ),

          if (state.bankType != null ||
              state.kyc?.photo_id_3_status != null) ...[
            const SizedBox(height: 16),
            _uploadBox(
              label: 'Front Side',
              file: state.bankFile,
              status: state.kyc?.photo_id_3_status,
              onTap: () =>
                  _pickFile(context, (f) => bloc.add(BankDocumentPicked(f))),
              isSubmitting: state.isSubmitting,
            ),
          ],

          const SizedBox(height: 100),

          // ================= NEXT =================
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (state.isValid && !state.isSubmitting)
                  ? () => bloc.add(SubmitKyc())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: state.isSubmitting
                  ? AppLoaders.buttonLoader()
                  : const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.verified_user, size: 16, color: Colors.blue),
              SecureShieldIcon(size: 16),
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
  static const String _maxFileSizeText = 'Maximum size: 6 MB';

  Widget _uploadBox({
    required String label,
    required PlatformFile? file,
    required String? status,
    required bool isSubmitting,
    required VoidCallback onTap,
  }) {
    final canUpload = KycResponse.canUpload(status);
    final normalizedStatus = status?.trim().toLowerCase();
    final isPending = normalizedStatus == 'pending';
    final isApproved = normalizedStatus == 'approved';
    final isRejected = normalizedStatus == 'rejected';
    final isNotSubmitted = status == null;
    final hasLocalFile = file != null;

    Color borderColor;
    Color bgColor;
    if (isApproved) {
      borderColor = Colors.green;
      bgColor = Colors.green.shade50;
    } else if (isPending) {
      borderColor = Colors.orange.shade300;
      bgColor = Colors.orange.shade50;
    } else if (isRejected) {
      borderColor = Colors.red;
      bgColor = Colors.red.shade50;
    } else {
      borderColor = Colors.orange;
      bgColor = const Color(0xFFFFF3E6);
    }

    return GestureDetector(
      onTap: canUpload ? onTap : null,
      child: Opacity(
        opacity: canUpload ? 1 : 0.7,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: canUpload
                          ? Colors.orange.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSubmitting && hasLocalFile
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppLoaders.buttonLoader(
                              color: Colors.orange,
                            ),
                          )
                        : Icon(
                            hasLocalFile
                                ? Icons.insert_drive_file
                                : Icons.cloud_upload,
                            color: canUpload ? Colors.orange : Colors.grey,
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasLocalFile)
                          Text(
                            file.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (isNotSubmitted)
                          Text(
                            'Choose or drag and drop ($_maxFileSizeText)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          )
                        else if (isPending)
                          Text(
                            'Under review – check back later',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          )
                        else if (isRejected)
                          Text(
                            'Upload a new file to replace ($_maxFileSizeText)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          )
                        else if (isApproved)
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isNotSubmitted
                          ? Colors.grey.shade400
                          : isPending
                          ? Colors.orange
                          : isApproved
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      KycResponse.statusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';

class SecureShieldIcon extends StatelessWidget {
  final double size;

  const SecureShieldIcon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = const Color(0xFF4F6FAF); // darker blue

    final innerPaint = Paint()
      ..color = const Color(0xFF6EC1E4); // lighter blue

    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width * 0.85, size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.lineTo(0, size.height * 0.25);
    path.close();

    canvas.drawPath(path, outerPaint);

    final innerPath = Path();
    innerPath.moveTo(size.width * 0.5, size.height * 0.1);
    innerPath.lineTo(size.width * 0.9, size.height * 0.3);
    innerPath.lineTo(size.width * 0.75, size.height * 0.9);
    innerPath.lineTo(size.width * 0.25, size.height * 0.9);
    innerPath.lineTo(size.width * 0.1, size.height * 0.3);
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);

    // Checkmark
    final checkPath = Path();
    checkPath.moveTo(size.width * 0.3, size.height * 0.55);
    checkPath.lineTo(size.width * 0.45, size.height * 0.7);
    checkPath.lineTo(size.width * 0.7, size.height * 0.4);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

