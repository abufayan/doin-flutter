import 'package:meta/meta.dart';

@immutable
sealed class ProfileEvent {}

final class LoadProfile extends ProfileEvent {}
