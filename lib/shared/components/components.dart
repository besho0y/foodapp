import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget defaultTextField({
  required TextEditingController controller,
  required TextInputType type,
  String? label,
  String? hint,
  IconData? prefixIcon,
  IconData? suffixIcon,
  Function? suffixPressed,
  bool isPassword = false,
  String? Function(String?)? validate,
  Function? onSubmit,
  Function? onChange,
  Function? onTap,
  bool isClickable = true,
}) {
  return Builder(builder: (context) {
    final themeColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      cursorColor: themeColor,
      onFieldSubmitted: (s) {
        if (onSubmit != null) {
          onSubmit(s);
        }
      },
      onChanged: (s) {
        if (onChange != null) {
          onChange(s);
        }
      },
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: themeColor),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: themeColor) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: () {
                  if (suffixPressed != null) {
                    suffixPressed();
                  }
                },
                icon: Icon(suffixIcon, color: themeColor),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
      ),
    );
  });
}
