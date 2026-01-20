import 'package:meta/meta.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}
