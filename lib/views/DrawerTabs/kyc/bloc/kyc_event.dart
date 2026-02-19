import 'package:file_picker/file_picker.dart';

abstract class KycEvent {}

class GetKycData extends KycEvent {}


class IdentityDocumentSelected extends KycEvent {
  final String value;
  IdentityDocumentSelected(this.value);
}

class BankingDocumentSelected extends KycEvent {
  final String value;
  BankingDocumentSelected(this.value);
}

class IdentityFrontPicked extends KycEvent {
  final PlatformFile file;
  IdentityFrontPicked(this.file);
}

class IdentityBackPicked extends KycEvent {
  final PlatformFile file;
  IdentityBackPicked(this.file);
}

class BankDocumentPicked extends KycEvent {
  final PlatformFile file;
  BankDocumentPicked(this.file);
}

class SubmitKyc extends KycEvent {}
