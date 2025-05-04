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
  return TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    enabled: isClickable,
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
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null
          ? IconButton(
              onPressed: () {
                if (suffixPressed != null) {
                  suffixPressed();
                }
              },
              icon: Icon(suffixIcon),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    ),
  );
}
