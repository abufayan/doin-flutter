import 'package:flutter_bloc/flutter_bloc.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  KycBloc() : super(const KycFormState()) {
    on<IdentityDocumentSelected>(_onIdentitySelected);
    on<BankingDocumentSelected>(_onBankSelected);
    on<IdentityFrontPicked>(_onIdFrontPicked);
    on<IdentityBackPicked>(_onIdBackPicked);
    on<BankDocumentPicked>(_onBankFilePicked);
    on<SubmitKyc>(_onSubmit);
  }

  void _onIdentitySelected(
      IdentityDocumentSelected e, Emitter<KycState> emit) {
    final s = state as KycFormState;
    emit(s.copyWith(identityType: e.type));
  }

  void _onBankSelected(
      BankingDocumentSelected e, Emitter<KycState> emit) {
    final s = state as KycFormState;
    emit(s.copyWith(bankType: e.type));
  }

  void _onIdFrontPicked(
      IdentityFrontPicked e, Emitter<KycState> emit) {
    final s = state as KycFormState;
    emit(s.copyWith(idFront: e.file));
  }

  void _onIdBackPicked(
      IdentityBackPicked e, Emitter<KycState> emit) {
    final s = state as KycFormState;
    emit(s.copyWith(idBack: e.file));
  }

  void _onBankFilePicked(
      BankDocumentPicked e, Emitter<KycState> emit) {
    final s = state as KycFormState;
    emit(s.copyWith(bankFile: e.file));
  }

  Future<void> _onSubmit(SubmitKyc e, Emitter<KycState> emit) async {
    final s = state as KycFormState;

    if (!s.isValid) {
      emit(const KycUploadFailure('Please upload all required documents'));
      emit(s); // return to form
      return;
    }

    emit(KycUploading());

    try {
      // TODO: API call here
      await Future.delayed(const Duration(seconds: 2));

      emit(const KycUploadSuccess(
        'Documents uploaded successfully',
      ));
    } catch (err) {
      emit(const KycUploadFailure(
        'Failed to upload documents',
      ));
      emit(s); // back to form
    }
  }
}
