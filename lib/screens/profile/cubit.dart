import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/profile/states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial()) {
    _loadUserData();
  }

  void _loadUserData() {
    // Initialize with mock data for now
    final mockUser = User(
      name: "John Doe",
      email: "john.doe@example.com",
      phone: 1234567890,
      address: [
        {
          "title": "Home",
          "address": "123 Main Street, Cairo, Egypt",
          "isDefault": true,
          "latitude": 30.0444,
          "longitude": 31.2357,
        },
        {
          "title": "Work",
          "address": "456 Business Ave, Cairo, Egypt",
          "isDefault": false,
          "latitude": 30.0444,
          "longitude": 31.2357,
        },
      ],
    );
    emit(ProfileLoaded(mockUser));
  }

  static ProfileCubit get(context) => BlocProvider.of(context);

  void updateUserDetails(String name, String email, String phone) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedUser = User(
          name: name,
          email: email,
          phone: int.parse(phone),
          address: currentState.user.address,
        );
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError("Failed to update user details"));
        emit(currentState); // Revert to previous state
      }
    }
  }

  void addAddress(
    String title,
    String address,
    bool isDefault, {
    double? latitude,
    double? longitude,
  }) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedAddresses = List.from(currentState.user.address);
        if (isDefault) {
          for (var addr in updatedAddresses) {
            addr["isDefault"] = false;
          }
        }
        updatedAddresses.add({
          "title": title,
          "address": address,
          "isDefault": isDefault,
          "latitude": latitude,
          "longitude": longitude,
        });

        final updatedUser = User(
          name: currentState.user.name,
          email: currentState.user.email,
          phone: currentState.user.phone,
          address: updatedAddresses,
        );
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError("Failed to add address"));
        emit(currentState); // Revert to previous state
      }
    }
  }

  void updateAddress(
    int index,
    String title,
    String address,
    bool isDefault, {
    double? latitude,
    double? longitude,
  }) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedAddresses = List.from(currentState.user.address);
        if (isDefault) {
          for (var addr in updatedAddresses) {
            addr["isDefault"] = false;
          }
        }

        // Update the address with all fields including location
        updatedAddresses[index] = {
          "title": title,
          "address": address,
          "isDefault": isDefault,
          "latitude": latitude,
          "longitude": longitude,
        };

        final updatedUser = User(
          name: currentState.user.name,
          email: currentState.user.email,
          phone: currentState.user.phone,
          address: updatedAddresses,
        );

        // Emit the updated state
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError("Failed to update address"));
        emit(currentState); // Revert to previous state
      }
    }
  }

  void deleteAddress(int index) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedAddresses = List.from(currentState.user.address);
        updatedAddresses.removeAt(index);

        final updatedUser = User(
          name: currentState.user.name,
          email: currentState.user.email,
          phone: currentState.user.phone,
          address: updatedAddresses,
        );
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError("Failed to delete address"));
        emit(currentState); // Revert to previous state
      }
    }
  }

  void setDefaultAddress(int index) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedAddresses = List.from(currentState.user.address);
        for (var i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i]["isDefault"] = (i == index);
        }

        final updatedUser = User(
          name: currentState.user.name,
          email: currentState.user.email,
          phone: currentState.user.phone,
          address: updatedAddresses,
        );
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError("Failed to set default address"));
        emit(currentState); // Revert to previous state
      }
    }
  }
}
