import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:doin_fx/core/apis.dart';
import 'package:doin_fx/setup.dart';
import 'package:doin_fx/views/DrawerTabs/profile/datamodel/profile_model.dart';
import 'package:doin_fx/views/DrawerTabs/profile/profile_helper.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  Map<String, dynamic> initialValue = {};

  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {});
    on<LoadProfileEvent>(getProfileEvent);
    on<OnSubmit>(onSubmit);
  }

  FutureOr<void> getProfileEvent(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await dio.get(baseUrl + getProfileDetails);

      final parsed = ProfileResponse.fromJson(response.data);

      if (parsed.status == "success") {
        ProfileModel profile = parsed.data!;

        initialValue = {
          'id': '${profile.id}',
          // ID is usually not null
          'username': profile.username ?? '',
          'email': profile.email ?? '',
          'whatsapp_number': profile.whatsappNumber ?? '',
          'nationality': profile.nationality ?? '',
          'country': profile.country ?? '',
          'address': profile.address ?? '',
          'city': profile.city ?? '',

          'date_of_birth': parseDateOfBirth(profile.dateOfBirth),

          'employment_status': cleanDropdownValue(profile.employmentStatus),

          'source_of_income': cleanDropdownValue(profile.sourceOfIncome),

          'trading_experience': normalizeTradingExperience(
            profile.tradingExperience,
          ),

          'income_range': mapIncomeRangeFromBackend(profile.incomeRange),

          'occupation': cleanDropdownValue(profile.occupation),

          'referred_by_id': formatReferral(profile.referredById?.toString()),
          // Handle nullable int
          'profile_completed': profile.profileCompleted,
        };
        emit(
          ProfileLoaded(message: parsed.message, initialValue: initialValue),
        );
      }
    } catch (e) {
      final message = (e is DioException && e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Failed to load profile'
          : 'Failed to load profile';
      emit(ProfileFailure(message));
    }
  }

  FutureOr<void> onSubmit(OnSubmit event, Emitter<ProfileState> emit) async {
    // emit(ProfileLoading());

    try {
      final raw = Map<String, dynamic>.from(event.formData);

      // 🔥 convert income_range BEFORE sending
      if (raw['income_range'] != null) {
        raw['income_range'] = mapIncomeRangeToBackend(
          raw['income_range'] as String,
        );
      }

      final payload = raw.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, DateFormat('yyyy-MM-dd').format(value));
        }
        if (value == '') {
          return MapEntry(key, null);
        }
        return MapEntry(key, value);
      });

      final response = await dio.put(baseUrl + updateProfile, data: payload);

      // Case 1: Backend returned JSON
      if (response.data is Map<String, dynamic>) {
        final parsed = SimpleResponse.fromJson(response.data);

        if (parsed.status == "success") {
          emit(ProfileUpdated(message: parsed.message));
          return;
        }

        emit(ProfileFailure(parsed.message));
        return;
      }

      // Case 2: Backend returned no body (200 / 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(ProfileUpdated(message: 'Profile updated successfully'));
        return;
      }

      emit(ProfileFailure('Unexpected response from server'));
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']?.toString() ?? 'Update failed'
          : 'Update failed';
      emit(ProfileFailure(message));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
