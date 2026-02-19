// kyc_state.dart
import 'package:doin_fx/views/DrawerTabs/kyc/datamodel/kyc_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class KycState {
  const KycState();
}

class KycFormState extends KycState {
  final String? identityType;
  final String? bankType;
  final PlatformFile? idFront;
  final PlatformFile? idBack;
  final PlatformFile? bankFile;
  final KycResponse? kyc;
  final bool isInitialLoading;
  final bool isSubmitting;

  const KycFormState({
    this.identityType,
    this.bankType,
    this.idFront,
    this.idBack,
    this.bankFile,
    this.kyc,
    this.isInitialLoading = false,
    this.isSubmitting = false,
  });

  /// Slots 1 & 2 need identityType; slot 3 needs bankType.
  /// Each slot: either locked (pending/approved) or we have a local file.
  /// We must have at least one file to submit.
  bool get isValid {
    final k = kyc;
    final canUp1 = k == null || KycResponse.canUpload(k.photo_id_1_status);
    final canUp2 = k == null || KycResponse.canUpload(k.photo_id_2_status);
    final canUp3 = k == null || KycResponse.canUpload(k.photo_id_3_status);

    final slot1Ok = !canUp1 || idFront != null;
    final slot2Ok = !canUp2 || idBack != null;
    final slot3Ok = !canUp3 || bankFile != null;

    final needsIdentity = canUp1 || canUp2;
    final needsBank = canUp3;

    final hasSomethingToSubmit =
        (canUp1 && idFront != null) ||
        (canUp2 && idBack != null) ||
        (canUp3 && bankFile != null);

    return slot1Ok &&
        slot2Ok &&
        slot3Ok &&
        hasSomethingToSubmit &&
        (!needsIdentity || identityType != null) &&
        (!needsBank || bankType != null);
  }

  KycFormState copyWith({
    String? identityType,
    String? bankType,
    PlatformFile? idFront,
    PlatformFile? idBack,
    PlatformFile? bankFile,
    KycResponse? kyc,
    bool? isInitialLoading,
    bool? isSubmitting,
  }) {
    return KycFormState(
      identityType: identityType ?? this.identityType,
      bankType: bankType ?? this.bankType,
      idFront: idFront ?? this.idFront,
      idBack: idBack ?? this.idBack,
      bankFile: bankFile ?? this.bankFile,
      kyc: kyc ?? this.kyc,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final class KyccActionState extends KycState {}

class KycUploading extends KycState {}

final class KycUploadSuccess extends KyccActionState {
  final String message;
  KycUploadSuccess(this.message);
}

final class KycUploadFailure extends KyccActionState {
  final String message;
  KycUploadFailure(this.message);
}
