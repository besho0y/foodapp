import 'package:foodapp/models/user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {}

class AddressAdded extends ProfileState {}

class AddressUpdated extends ProfileState {}

class AddressDeleted extends ProfileState {}

class ProfileLogoutSuccess extends ProfileState {}

class ProfileAccountDeleted extends ProfileState {}
