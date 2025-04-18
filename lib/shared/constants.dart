import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget defaultTextFormField({
  required String label,
  required IconData prefix,
  required TextEditingController controller,
  required String? Function(String?) validator,
  IconData? suffix,
  TextInputType inputType = TextInputType.text,
  VoidCallback? suffixPressed,
  bool isPassword = false,
  bool readOnly = false,
}) {
  return TextFormField(
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefix),
      border: const OutlineInputBorder(),
      suffixIcon:
          suffix != null
              ? IconButton(onPressed: suffixPressed, icon: Icon(suffix))
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
  Color backgroundcolor = Colors.blue,
  required String text,
  required VoidCallback function,
}) {
  return Container(
    width: width,
    color: backgroundcolor,
    child: MaterialButton(
      onPressed: function,
      child: Text(text, style: TextStyle(color: Colors.white)),
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
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  child: Container(
    height: 1,
    color:
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,                 
  ),
);
