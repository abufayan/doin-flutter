import 'package:file_picker/file_picker.dart';

abstract class KycEvent {}

class IdentityDocumentSelected extends KycEvent {
  final String type;
  IdentityDocumentSelected(this.type);
}

class BankingDocumentSelected extends KycEvent {
  final String type;
  BankingDocumentSelected(this.type);
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

/// 🔥 SUBMIT EVENT
class SubmitKyc extends KycEvent {}
