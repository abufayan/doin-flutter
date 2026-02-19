// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_event.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/bloc/kyc_state.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/datamodel/kyc_model.dart';
import 'package:file_picker/file_picker.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  static const int _maxFileSize = 6 * 1024 * 1024; // 6 MB
  // final Dio _dio = Dio();

  KycBloc() : super(const KycFormState()) {
    on<GetKycData>(getKycData);
    on<IdentityDocumentSelected>(_onIdentitySelected);
    on<BankingDocumentSelected>(_onBankSelected);
    on<IdentityFrontPicked>(_onIdFrontPicked);
    on<IdentityBackPicked>(_onIdBackPicked);
    on<BankDocumentPicked>(_onBankPicked);
    on<SubmitKyc>(_onSubmit);
  }

  void _onIdentitySelected(
    IdentityDocumentSelected event,
    Emitter<KycState> emit,
  ) {
    emit((state as KycFormState).copyWith(identityType: event.value));
  }

  void _onBankSelected(BankingDocumentSelected event, Emitter<KycState> emit) {
    emit((state as KycFormState).copyWith(bankType: event.value));
  }

  void _onIdFrontPicked(IdentityFrontPicked event, Emitter<KycState> emit) {
    _validateFile(event.file, emit, (s) => s.copyWith(idFront: event.file));
  }

  void _onIdBackPicked(IdentityBackPicked event, Emitter<KycState> emit) {
    _validateFile(event.file, emit, (s) => s.copyWith(idBack: event.file));
  }

  void _onBankPicked(BankDocumentPicked event, Emitter<KycState> emit) {
    _validateFile(event.file, emit, (s) => s.copyWith(bankFile: event.file));
  }

  void _validateFile(
    PlatformFile file,
    Emitter<KycState> emit,
    KycFormState Function(KycFormState) update,
  ) {
    if (file.size > _maxFileSize) {
      emit(KycUploadFailure('File size must be less than 6 MB'));
      emit(state); // return to form state
      return;
    }

    emit(update(state as KycFormState));
  }

  Future<void> _onSubmit(SubmitKyc event, Emitter<KycState> emit) async {
    final previousState = state as KycFormState;

    if (!previousState.isValid) {
      emit(KycUploadFailure('Please upload all required documents'));
      emit(previousState);
      return;
    }

    emit(previousState.copyWith(isSubmitting: true));

    try {
      final myAccount = getIt<MyAccountService>();

      if (myAccount.user == null) {
        emit(KycUploadFailure('User not authenticated'));
        emit(previousState.copyWith(isSubmitting: false));
        return;
      }

      final k = previousState.kyc;
      final canUp1 = k == null || KycResponse.canUpload(k.photo_id_1_status);
      final canUp2 = k == null || KycResponse.canUpload(k.photo_id_2_status);
      final canUp3 = k == null || KycResponse.canUpload(k.photo_id_3_status);

      final map = <String, dynamic>{'user_id': myAccount.user!.userId};

      if (previousState.identityType != null) {
        map['photo_id_1_document_type'] = previousState.identityType;
        map['photo_id_2_document_type'] = previousState.identityType;
      }

      if (previousState.bankType != null) {
        map['photo_id_3_document_type'] = previousState.bankType;
      }

      if (canUp1 &&
          previousState.idFront != null &&
          previousState.idFront!.path != null) {
        map['photo_id_1'] = await MultipartFile.fromFile(
          previousState.idFront!.path!,
        );
      }

      if (canUp2 &&
          previousState.idBack != null &&
          previousState.idBack!.path != null) {
        map['photo_id_2'] = await MultipartFile.fromFile(
          previousState.idBack!.path!,
        );
      }

      if (canUp3 &&
          previousState.bankFile != null &&
          previousState.bankFile!.path != null) {
        map['photo_id_3'] = await MultipartFile.fromFile(
          previousState.bankFile!.path!,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await dio.post(baseUrl + kycSubmit, data: formData);

      emit(
        KycUploadSuccess(
          response.data['message'] ?? 'KYC submitted successfully',
        ),
      );

      emit(previousState.copyWith(isSubmitting: false)); // restore UI
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>)
          ? data['message']?.toString() ?? 'Failed to submit KYC'
          : 'Failed to submit KYC';
      emit(KycUploadFailure(message));
      emit(previousState.copyWith(isSubmitting: false)); // 👈 restore form
    } catch (_) {
      emit(KycUploadFailure('Failed to submit KYC'));
      emit(previousState.copyWith(isSubmitting: false)); // 👈 restore form
    }
  }

  FutureOr<void> getKycData(GetKycData event, Emitter<KycState> emit) async {
    emit(const KycFormState(isInitialLoading: true));

    final myAccount = getIt<MyAccountService>();

    if (myAccount.user == null) {
      emit(KycUploadFailure('User not authenticated'));
      emit(const KycFormState(isInitialLoading: false));
      return;
    }

    try {
      final response = await dio.get(
        '$baseUrl$kycVerified${myAccount.user!.userId}',
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        final kyc = KycResponse.fromJson(data.first);
        emit(KycFormState(kyc: kyc, isInitialLoading: false));
      } else {
        emit(KycUploadFailure('No KYC data found'));
        emit(const KycFormState(isInitialLoading: false));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>)
          ? data['message']?.toString() ?? 'Error loading KYC data'
          : 'Error loading KYC data';
      emit(KycUploadFailure(message));
      emit(const KycFormState(isInitialLoading: false));
    } catch (_) {
      emit(KycUploadFailure('Error loading KYC data'));
      emit(const KycFormState(isInitialLoading: false));
    }
  }
}
