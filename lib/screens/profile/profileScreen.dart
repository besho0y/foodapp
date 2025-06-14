import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/user.dart';
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
              title: Text(S.of(context).profile),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(S.of(context).profile),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16.h),
                  const Text("Error loading profile data"),
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
                          S.of(context).PersonalInformation,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoField(
                          context,
                          icon: Icons.person_outline,
                          label: S.of(context).Name,
                          value: cubit.user.name,
                        ),
                        _buildInfoField(
                          context,
                          icon: Icons.phone_outlined,
                          label: S.of(context).Phone,
                          value: cubit.user.phone,
                        ),
                        _buildInfoField(
                          context,
                          icon: Icons.email_outlined,
                          label: S.of(context).Email,
                          value: cubit.user.email,
                        ),

                        // Addresses Section
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).Address,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  _showAddAddressBottomSheet(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Address Cards
                        cubit.user.addresses.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.location_off,
                                        size: 40, color: Colors.grey),
                                    SizedBox(height: 10.h),
                                    Text(S.of(context).Naddresses),
                                    SizedBox(height: 10.h),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showAddAddressBottomSheet(context),
                                      child: Text(S.of(context).AddAddress),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cubit.user.addresses.length,
                                itemBuilder: (context, index) {
                                  final address = cubit.user.addresses[index];
                                  return _buildAddressCard(
                                    context,
                                    address: address,
                                    isDefault: address.isDefault,
                                    index: index,
                                  );
                                },
                              ),

                        // Account Actions (Delete Account and Logout)
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showDeleteAccountConfirmation(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              S.of(context).delete_account,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildInfoField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required Address address,
    required bool isDefault,
    required int index,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                SizedBox(width: 8.w),
                Text(
                  address.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10.w),
                if (isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      S.of(context).default1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAddressBottomSheet(context, index, address);
                    } else if (value == S.of(context).delete) {
                      _showDeleteAddressConfirmation(context, index);
                    } else if (value == S.of(context).default1) {
                      ProfileCubit.get(context).setDefaultAddress(index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          SizedBox(width: 8.w),
                          Text(S.of(context).Edit),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      PopupMenuItem(
                        value: S.of(context).default1,
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle),
                            SizedBox(width: 8.w),
                            Text(S.of(context).Setdefaultaddress),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: S.of(context).delete,
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text(S.of(context).delete,
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 32.w),
              child: Text(
                address.address,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    bool isDefault = false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).add_address,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: titleController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).AddressTitle,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.home, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: addressController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).FullAddress,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon: Icon(Icons.location_on,
                    color: Theme.of(context).primaryColor),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12.h),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: Text(S.of(context).Setdefaultaddress),
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).Pleasefill)),
                    );
                    return;
                  }

                  final address = Address(
                    title: titleController.text.trim(),
                    address: addressController.text.trim(),
                    isDefault: isDefault,
                  );

                  ProfileCubit.get(context).addAddress(address);
                  Navigator.pop(context);
                },
                child: Text(S.of(context).SaveAddress),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showEditAddressBottomSheet(
    BuildContext context,
    int index,
    Address address,
  ) {
    final titleController = TextEditingController(text: address.title);
    final addressController = TextEditingController(text: address.address);
    bool isDefault = address.isDefault;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).EditAddress,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: titleController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).AddressTitle,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.home, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: addressController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).FullAddress,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon: Icon(Icons.location_on,
                    color: Theme.of(context).primaryColor),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12.h),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: Text(S.of(context).Setdefaultaddress),
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).Pleasefill)),
                    );
                    return;
                  }

                  final updatedAddress = Address(
                    title: titleController.text.trim(),
                    address: addressController.text.trim(),
                    isDefault: isDefault,
                  );

                  ProfileCubit.get(context)
                      .updateAddress(index, updatedAddress);
                  Navigator.pop(context);
                },
                child: Text(S.of(context).UpdateAddress),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteAddressConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).DeleteAddress),
        content: Text(S.of(context).suredeleteaddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).Cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileCubit.get(context).deleteAddress(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _showUpdateUserBottomSheet(BuildContext context) {
    var cubit = ProfileCubit.get(context);
    final nameController = TextEditingController(text: cubit.user.name);
    final emailController = TextEditingController(text: cubit.user.email);
    final phoneController = TextEditingController(text: cubit.user.phone);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).UpdateProfile,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: nameController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).Name,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: emailController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).Email,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.email, color: Theme.of(context).primaryColor),
              ),
              enabled: false, // Email cannot be changed
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: phoneController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: S.of(context).Phone,
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.grey.shade50,
                prefixIcon:
                    Icon(Icons.phone, color: Theme.of(context).primaryColor),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).Pleasefill)),
                    );
                    return;
                  }

                  // Validate phone number
                  if (phoneController.text.trim().length != 11) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).phoneverfy)),
                    );
                    return;
                  }

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Update profile
                  await ProfileCubit.get(context).updateUserProfile(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                  );

                  // Close loading indicator
                  Navigator.of(context).pop();

                  // Close bottom sheet
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).Profileupdatedsuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(S.of(context).UpdateProfile),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete_account),
        content: Text(
          S.of(context).Areyoudeleteaccount,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).Cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show an additional confirmation with password for security
              _showFinalDeleteConfirmation(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).FinalConfirmation),
        content: Text(
          S.of(context).Thiswillpermanentlydeleteyouraccount,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).Cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileCubit.get(context).deleteAccount(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).YesDeleteMyAccount),
          ),
        ],
      ),
    );
  }
}
