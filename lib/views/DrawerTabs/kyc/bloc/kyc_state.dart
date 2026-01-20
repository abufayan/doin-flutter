import 'package:file_picker/file_picker.dart';

abstract class KycState {
  const KycState();
}

/// Initial / editing state
class KycFormState extends KycState {
  final String? identityType;
  final String? bankType;
  final PlatformFile? idFront;
  final PlatformFile? idBack;
  final PlatformFile? bankFile;

  const KycFormState({
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

  KycFormState copyWith({
    String? identityType,
    String? bankType,
    PlatformFile? idFront,
    PlatformFile? idBack,
    PlatformFile? bankFile,
  }) {
    return KycFormState(
      identityType: identityType ?? this.identityType,
      bankType: bankType ?? this.bankType,
      idFront: idFront ?? this.idFront,
      idBack: idBack ?? this.idBack,
      bankFile: bankFile ?? this.bankFile,
    );
  }
}

/// While uploading to API
class KycUploading extends KycState {}

/// Upload success
class KycUploadSuccess extends KycState {
  final String message;
  const KycUploadSuccess(this.message);
}

/// Upload failed
class KycUploadFailure extends KycState {
  final String message;
  const KycUploadFailure(this.message);
}
