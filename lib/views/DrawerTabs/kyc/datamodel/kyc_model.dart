import 'package:file_picker/file_picker.dart';

class KycModel {
  final String? identityType;
  final String? bankType;
  final PlatformFile? idFront;
  final PlatformFile? idBack;
  final PlatformFile? bankFile;

  const KycModel({
    this.identityType,
    this.bankType,
    this.idFront,
    this.idBack,
    this.bankFile,
  });

  bool get isValid =>
      identityType != null &&
          idFront != null &&
          idBack != null &&
          bankType != null &&
          bankFile != null;

  KycModel copyWith({
    String? identityType,
    String? bankType,
    PlatformFile? idFront,
    PlatformFile? idBack,
    PlatformFile? bankFile,
  }) {
    return KycModel(
      identityType: identityType ?? this.identityType,
      bankType: bankType ?? this.bankType,
      idFront: idFront ?? this.idFront,
      idBack: idBack ?? this.idBack,
      bankFile: bankFile ?? this.bankFile,
    );
  }
}
