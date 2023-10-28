import 'package:driver_app/appConstatns/app_colors.dart';
import 'package:flutter/material.dart';

Widget MyButton(){
  return ElevatedButton(
    onPressed: (){

    }, 
    style: ElevatedButton.styleFrom(
      primary: AppColors.lightBlue
    ),
    child: Text("Create Account",
    style: TextStyle(
      color: AppColors.darkGreen,
      fontSize: 18
    ),
    )
    );
}