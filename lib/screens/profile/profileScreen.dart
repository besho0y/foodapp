import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  late ProfileCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<ProfileCubit>(context);
    cubit.getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = ProfileCubit.get(context);

        // Add loading and error states
        if (state is ProfileLoading) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text("Profile"),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text("Profile"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading profile data"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => cubit.getuserdata(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        // Normal profile display when data is loaded
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
                            onPressed: () =>
                                _showUpdateUserBottomSheet(context),
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
                                cubit.user.name,
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
                          context,
                          icon: Icons.person_outline,
                          label: "Name",
                          value: cubit.user.name,
                        ),
                        _buildInfoField(
                          context,
                          icon: Icons.phone_outlined,
                          label: "Phone",
                          value: cubit.user.phone,
                        ),
                        _buildInfoField(
                          context,
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: cubit.user.email,
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
                              onPressed: () => _showAddressBottomSheet(context),
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
                        // ...cubit.user.address.asMap().entries.map((entry) {
                        //   final index = entry.key;
                        //   final address = entry.value;
                        //   return _buildAddressCard(
                        //     context,
                        //     title: address["title"],
                        //     address: address["address"],
                        //     isDefault: address["isDefault"],
                        //     onEdit: () => _showAddressBottomSheet(
                        //       context,
                        //       index: index,
                        //       title: address["title"],
                        //       address: address["address"],
                        //       isDefault: address["isDefault"],
                        //     ),
                        //     // onDelete: () => _deleteAddress(index),
                        //     // onSetDefault: () => _setDefaultAddress(index),
                        //   );
                        // }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void _updateUserDetails(String name, String email, String phone) {
  //   setState(() {
  //     List<Map<String, dynamic>> oldAddresses = user.address;
  //     user = User(
  //       name: name,
  //       email: email,
  //       phone: phone,
  //       uid: user.uid,
  //     );
  //     // Using reflection to maintain addresses
  //     (user as dynamic).address = oldAddresses;
  //   });
  // }

  // void _addAddress(String title, String address, bool isDefault) {
  //   setState(() {
  //     final updatedAddresses = List<Map<String, dynamic>>.from(user.address);
  //     if (isDefault) {
  //       for (var addr in updatedAddresses) {
  //         addr["isDefault"] = false;
  //       }
  //     }
  //     updatedAddresses.add({
  //       "title": title,
  //       "address": address,
  //       "isDefault": isDefault,
  //       "latitude": 30.0444,
  //       "longitude": 31.2357,
  //     });
  //     // Using reflection to set updated addresses
  //     (user as dynamic).address = updatedAddresses;
  //   });
  // }

  // void _updateAddress(int index, String title, String address, bool isDefault) {
  //   setState(() {
  //     final updatedAddresses = List<Map<String, dynamic>>.from(user.address);
  //     if (isDefault) {
  //       for (var addr in updatedAddresses) {
  //         addr["isDefault"] = false;
  //       }
  //     }
  //     updatedAddresses[index] = {
  //       "title": title,
  //       "address": address,
  //       "isDefault": isDefault,
  //       "latitude": 30.0444,
  //       "longitude": 31.2357,
  //     };
  //     // Using reflection to set updated addresses
  //     (user as dynamic).address = updatedAddresses;
  //   });
  // }

  // void _deleteAddress(int index) {
  //   setState(() {
  //     final updatedAddresses = List<Map<String, dynamic>>.from(user.address);
  //     updatedAddresses.removeAt(index);
  //     // Using reflection to set updated addresses
  //     (user as dynamic).address = updatedAddresses;
  //   });
  // }

  // void _setDefaultAddress(int index) {
  //   setState(() {
  //     final updatedAddresses = List<Map<String, dynamic>>.from(user.address);
  //     for (var i = 0; i < updatedAddresses.length; i++) {
  //       updatedAddresses[i]["isDefault"] = (i == index);
  //     }
  //     // Using reflection to set updated addresses
  //     (user as dynamic).address = updatedAddresses;
  //   });
  // }

  void _showUpdateUserBottomSheet(BuildContext context) {
    var cubit = ProfileCubit.get(context);
    final nameController = TextEditingController(text: cubit.user.name);
    final emailController = TextEditingController(text: cubit.user.email);
    final phoneController = TextEditingController(text: cubit.user.phone);

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
                  // _updateUserDetails(
                  //   nameController.text,
                  //   emailController.text,
                  //   phoneController.text,
                  // );
                  // Navigator.pop(context);
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
  }) {
    final titleController = TextEditingController(text: title);
    final addressController = TextEditingController(text: address);
    bool isDefaultAddress = isDefault ?? false;

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
                    // if (index == null) {
                    //   _addAddress(
                    //     titleController.text,
                    //     addressController.text,
                    //     isDefaultAddress,
                    //   );
                    // } else {
                    //   _updateAddress(
                    //     index,
                    //     titleController.text,
                    //     addressController.text,
                    //     isDefaultAddress,
                    //   );
                    // }
                    Navigator.of(context).pop();
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

  Widget _buildInfoField(
    BuildContext context, {
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

  Widget _buildAddressCard(
    BuildContext context, {
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
