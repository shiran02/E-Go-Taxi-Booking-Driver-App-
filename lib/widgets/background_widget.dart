import 'package:driver_app/appConstatns/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget BackgroundImage() {
  return Container(
    child: Column(
      children: [
        Container(
          //    color: AppColors.darkGreen,
          width: Get.width,
          height: Get.height * 0.4,
          decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("images/registerback.png"),
                alignment: Alignment.topCenter),
          ),
        ),
        Expanded(
            child: Container(
          color: AppColors.darkGreen,
        ))
      ],
    ),
  );
}
