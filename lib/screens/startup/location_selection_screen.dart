import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String selectedArea = 'Cairo';
  final List<String> areas = ['Cairo', 'Giza'];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome text
              Icon(
                Icons.location_on,
                size: 80.sp,
                color: AppColors.primaryLight,
              ),
              SizedBox(height: 30.h),
              Text(
                'Welcome to Food App',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Text(
                'Please select your location to get started',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.h),

              // Location dropdown
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      width: 2),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCard
                      : Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedArea,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: AppColors.primaryLight),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    items: areas.map((String area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Row(
                          children: [
                            Icon(Icons.location_city,
                                color: AppColors.primaryLight, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(area),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedArea = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: 50.h),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Save the selected area to user profile if logged in
      final profileCubit = ProfileCubit.get(context);
      if (profileCubit.user.uid.isNotEmpty) {
        // Update just the selected area in the profile
        try {
          await profileCubit.updateSelectedArea(selectedArea);
        } catch (e) {
          print('Failed to update user profile: $e');
        }
      }

      // Save location selection preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedArea', selectedArea);
      await prefs.setBool('hasSelectedLocation', true);

      // Navigate to main layout
      if (mounted) {
        navigateAndFinish(context, const Layout());
      }
    } catch (e) {
      print('Error saving location selection: $e');
      // Continue to layout even if saving fails
      if (mounted) {
        navigateAndFinish(context, const Layout());
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}
