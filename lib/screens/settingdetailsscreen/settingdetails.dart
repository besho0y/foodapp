import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/shared/colors.dart';

class Settingdetails extends StatelessWidget {
  const Settingdetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Layoutcubit, Layoutstates>(
      builder: (context, state) {
        var cubit = Layoutcubit.get(context);
        bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
            title: Text(
              S.of(context).settings,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).preferences,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.primaryLight,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Theme Section
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          title: S.of(context).theme,
                          icon: Icons.palette_outlined,
                          child: AnimatedToggleSwitch<bool>.rolling(
                            current: isDark,
                            values: const [true, false],
                            onChanged: (value) => cubit.toggletheme(),
                            iconBuilder: (value, size) {
                              return Icon(
                                value ? Icons.dark_mode : Icons.light_mode,
                                color: const Color.fromARGB(255, 74, 26, 15),
                                size: 20.sp,
                              );
                            },
                            styleBuilder: (value) => ToggleStyle(
                              backgroundColor:
                                  value ? AppColors.primaryDark : Colors.white,
                              borderColor: value
                                  ? AppColors.primaryDark.withOpacity(0.8)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            height: 35.h,
                            spacing: 0.0,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        _buildSettingTile(
                          context,
                          title: S.of(context).language,
                          icon: Icons.language,
                          child: AnimatedToggleSwitch<bool>.rolling(
                            current: cubit.isArabic,
                            values: const [true, false],
                            onChanged: (value) => cubit.changeLanguage(),
                            iconBuilder: (value, size) {
                              return Container(
                                width: 35.w,
                                alignment: Alignment.center,
                                child: Text(
                                  value ? 'ع' : 'En',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 74, 26, 15),
                                  ),
                                ),
                              );
                            },
                            styleBuilder: (value) => ToggleStyle(
                              backgroundColor:
                                  isDark ? AppColors.primaryDark : Colors.white,
                              borderColor:
                                  (isDark ? AppColors.primaryDark : Colors.grey)
                                      .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            height: 35.h,
                            spacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Add more sections here...
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : AppColors.primaryLight,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}
