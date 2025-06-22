import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/colors.dart';

Widget defaultTextFormField({
  required String label,
  required IconData prefix,
  required TextEditingController controller,
  required String? Function(String?) validator,
  required context,
  IconData? suffix,
  TextInputType inputType = TextInputType.text,
  VoidCallback? suffixPressed,
  bool isPassword = false,
  bool readOnly = false,
  String? hintText,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextFormField(
    style: TextStyle(
      color: isDarkMode ? AppColors.darkText : Colors.black,
    ),
    cursorColor: isDarkMode ? Colors.white : AppColors.primaryLight,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle:
          TextStyle(color: isDarkMode ? Colors.white : AppColors.primaryLight),
      prefixIcon: Icon(prefix,
          color: isDarkMode ? Colors.white : AppColors.primaryLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isDarkMode ? Colors.white : AppColors.primaryLight,
            width: 2.0),
      ),
      filled: true,
      fillColor: isDarkMode ? AppColors.darkCard : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      suffixIcon: suffix != null
          ? IconButton(
              onPressed: suffixPressed,
              icon: Icon(suffix,
                  color: isDarkMode ? Colors.white : AppColors.primaryLight),
            )
          : null,
    ),
    controller: controller,
    keyboardType: inputType,
    validator: validator,
    readOnly: readOnly,
    obscureText: isPassword,
  );
}

Widget defaultbutton({
  double width = double.infinity,
  required String text,
  required VoidCallback function,
  required context,
}) {
  return Container(
    width: width,
    color: AppColors.primaryLight,
    child: MaterialButton(
      onPressed: function,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

void navigateTo(context, widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

navigateAndFinish(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

void backarrow(context) {
  Navigator.pop(context);
}

Widget mycheckbox({
  required bool value,
  required ValueChanged<bool?> onChanged,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: Checkbox(value: value, onChanged: onChanged),
  );
}

Widget mydivider(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
