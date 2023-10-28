import 'package:driver_app/authentication/login_screen.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/splachScreen/splach_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

import '../appConstatns/app_colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/text_widget.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  List<String> carTypeList = ["uber-x", "uber-go", "bike"];
  String? selectedType;

  //save car information ........................................

  saveCarInfo() {
    Map driverCarInfoMap = {
      "car_color": carColorTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "car_model": carModelTextEditingController.text.trim(),
      "type": selectedType,
    };

    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers");

    driverRef
        .child(currentFirebaseUer!.uid)
        .child("car_detail")
        .set(driverCarInfoMap);

     Fluttertoast.showToast(msg: "Car Detail has been saved> Congratulations");   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkblue,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                //    color: AppColors.darkGreen,
                width: Get.width,
                height: Get.height * 0.4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("images/rege_back2.png"),
                      alignment: Alignment.topCenter),
                ),
              ),
              Container(
                color: AppColors.darkblue,
                width: Get.width,
                height: Get.height * 0.6,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    MyTextField(
                        hintText: "Car model",
                        label: "Car model",
                        textController: carModelTextEditingController,
                        finaleType: TextInputType.name,
                        fontColor: AppColors.CarinfofontColor),
                    MyTextField(
                        hintText: "Car number",
                        label: "Car number",
                        textController: carNumberTextEditingController,
                        finaleType: TextInputType.name,
                        fontColor: AppColors.CarinfofontColor),
                    MyTextField(
                        hintText: "Car color",
                        label: "Car color",
                        textController: carColorTextEditingController,
                        finaleType: TextInputType.name,
                        fontColor: AppColors.CarinfofontColor),
                    const SizedBox(
                      height: 30,
                    ),
                    DropdownButton(
                      dropdownColor: Colors.black,
                      hint: const Text(
                        "Please Choose Car Type",
                        style: TextStyle(
                          fontSize: 14.8,
                          color: AppColors.lightBlue,
                        ),
                      ),
                      value: selectedType,
                      onChanged: (newValue) {
                        setState(() {
                          selectedType = newValue.toString();
                        });
                      },
                      items: carTypeList.map((car) {
                        return DropdownMenuItem(
                          value: car,
                          child: Text(
                            car,
                            style: TextStyle(color: AppColors.lightBlue),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (carColorTextEditingController.text.isNotEmpty &&
                              carNumberTextEditingController.text.isNotEmpty &&
                              carModelTextEditingController.text.isNotEmpty &&
                              selectedType != null) {
                                saveCarInfo();
                              }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const MySplashScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.lightBlue),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                              color: AppColors.darkGreen, fontSize: 18),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
