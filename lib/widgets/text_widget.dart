import 'dart:convert';

import 'package:flutter/material.dart';

import '../appConstatns/app_colors.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final String label;
  final TextEditingController textController;
  final TextInputType finaleType;
  final Color fontColor;

  const MyTextField({
    Key? key,
    required this.hintText,
    required this.label,
    required this.textController,
    required this.finaleType,
    required this.fontColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 30),
      child: TextField(
        controller: textController,
        keyboardType: finaleType,
        style: TextStyle(
          color: fontColor,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: fontColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: fontColor,
            fontSize: 15,
            fontStyle: FontStyle.normal,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: fontColor),
          ),
        ),
      ),
    );
  }
}
