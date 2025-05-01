import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = ProfileCubit.get(context);
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            return SafeArea(
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        height: 200.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.r),
                            bottomRight: Radius.circular(30.r),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10.h,
                              left: 10.w,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10.h,
                              right: 10.w,
                              child: IconButton(
                                onPressed: () => _showUpdateUserBottomSheet(
                                  context,
                                  user,
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50.r,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 50.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // User Information
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            _buildInfoField(
                              icon: Icons.person_outline,
                              label: "Name",
                              value: user.name,
                            ),
                            _buildInfoField(
                              icon: Icons.phone_outlined,
                              label: "Phone",
                              value: user.phone.toString(),
                            ),
                            _buildInfoField(
                              icon: Icons.email_outlined,
                              label: "Email",
                              value: user.email,
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Saved Addresses",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showAddressBottomSheet(context),
                                  icon: Icon(
                                    Icons.add,
                                    size: 20.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    "Add New",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            ...user.address.asMap().entries.map((entry) {
                              final index = entry.key;
                              final address = entry.value;
                              return _buildAddressCard(
                                title: address["title"],
                                address: address["address"],
                                isDefault: address["isDefault"],
                                onEdit: () => _showAddressBottomSheet(
                                  context,
                                  index: index,
                                  title: address["title"],
                                  address: address["address"],
                                  isDefault: address["isDefault"],
                                  latitude: address["latitude"],
                                  longitude: address["longitude"],
                                ),
                                onDelete: () => cubit.deleteAddress(index),
                                onSetDefault: () =>
                                    cubit.setDefaultAddress(index),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUpdateUserBottomSheet(BuildContext context, User user) {
    final cubit = ProfileCubit.get(context);
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Update Profile",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cubit.updateUserDetails(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text("Update Profile"),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showAddressBottomSheet(
    BuildContext context, {
    int? index,
    String? title,
    String? address,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    final cubit = ProfileCubit.get(context);
    final titleController = TextEditingController(text: title);
    final addressController = TextEditingController(text: address);
    bool isDefaultAddress = isDefault ?? false;
    LatLng? selectedLocation =
        (index != null && latitude != null && longitude != null)
            ? LatLng(latitude, longitude)
            : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                index == null ? "Add New Address" : "Edit Address",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title (e.g., Home, Work)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10.h),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedLocation = null;
                  });
                },
                icon: Icon(Icons.location_on),
                label: Text(selectedLocation == null
                    ? "Select Location"
                    : "Location Selected"),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(30.0444, 31.2357), // Default to Cairo
                          zoom: 15,
                        ),
                        markers: selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('selected_location'),
                                  position: selectedLocation!,
                                ),
                              }
                            : {},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                        onTap: (LatLng position) async {
                          setState(() {
                            selectedLocation = position;
                          });

                          // Get address from coordinates
                          try {
                            final List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                              position.latitude,
                              position.longitude,
                            );

                            if (placemarks.isNotEmpty) {
                              final Placemark place = placemarks[0];
                              final String address =
                                  '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
                              addressController.text = address;
                            }
                          } catch (e) {
                            print('Error getting address: $e');
                          }
                        },
                      ),
                      if (selectedLocation != null)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: FloatingActionButton.small(
                            onPressed: () {
                              launchUrl(Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${selectedLocation!.latitude},${selectedLocation!.longitude}',
                              ));
                            },
                            child: const Icon(Icons.open_in_new),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Checkbox(
                    value: isDefaultAddress,
                    onChanged: (value) {
                      setState(() {
                        isDefaultAddress = value ?? false;
                      });
                    },
                  ),
                  Text("Set as default address"),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (index == null) {
                      cubit.addAddress(
                        titleController.text,
                        addressController.text,
                        isDefaultAddress,
                        latitude: selectedLocation?.latitude,
                        longitude: selectedLocation?.longitude,
                      );
                    } else {
                      cubit.updateAddress(
                        index,
                        titleController.text,
                        addressController.text,
                        isDefaultAddress,
                        latitude: selectedLocation?.latitude,
                        longitude: selectedLocation?.longitude,
                      );
                    }
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    index == null ? "Add Address" : "Update Address",
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 5.h),
              Text(
                value,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    required bool isDefault,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onSetDefault,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Text(
                      "Default",
                      style: TextStyle(color: Colors.green, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              address,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: Text(
                      "Set as Default",
                      style: TextStyle(color: Colors.green, fontSize: 12.sp),
                    ),
                  ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 20.sp),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 20.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
