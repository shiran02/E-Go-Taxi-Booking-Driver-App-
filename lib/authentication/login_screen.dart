import 'package:driver_app/authentication/signup_screen.dart';
import 'package:driver_app/mainScreen/main_screen.dart';
import 'package:driver_app/splachScreen/splach_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../appConstatns/app_colors.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  //validatiion ................................................

  validateForm() {
    if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "email is not valide");
    } else if (passwordTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "password is Required");
    } else {
      loginDriverNow();
    }
  }

  loginDriverNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Processing ,Please wait");
        });

    final User? firebaseUser = (await fAuth
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text.trim(),
                password: passwordTextEditingController.text.trim())
            .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error :" + msg.toString());
    })).user;

    if (firebaseUser != null) {

      DatabaseReference driverRef =
          FirebaseDatabase.instance.ref().child("drivers");
      driverRef.child(firebaseUser.uid).once().then((deriverKey) {
        final snap = deriverKey.snapshot;

        //check driver detail is exist in data base
        //if its not cant log

        if (snap.value != null) {
          currentFirebaseUer = firebaseUser;
          Fluttertoast.showToast(msg: "Login successFull .");
          Navigator.push(context,
              MaterialPageRoute(builder: (c) => const MySplashScreen()));
        }else{
          Fluttertoast.showToast(msg: "No record exist with this email");
          fAuth.signOut();
           Navigator.push(context,
              MaterialPageRoute(builder: (c) => const MySplashScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Erra occured.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkbrown,
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
                      image: AssetImage("images/add.png"),
                      alignment: Alignment.topCenter),
                ),
              ),
              Container(
                color: AppColors.darkbrown,
                width: Get.width,
                height: Get.height * 0.6,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    MyTextField(
                        hintText: "Enter Email",
                        label: "Email",
                        textController: emailTextEditingController,
                        finaleType: TextInputType.emailAddress,
                        fontColor: AppColors.loginScreenFontColor),
                    MyTextField(
                        hintText: "Enter Password",
                        label: "Password",
                        textController: passwordTextEditingController,
                        finaleType: TextInputType.name,
                        fontColor: AppColors.loginScreenFontColor),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          validateForm();
                          //  Navigator.push(context, MaterialPageRoute(builder: (c)=>const CarInfoScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.loginbtnColor),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: AppColors.darkGreen, fontSize: 18),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const SignUpScreen()));
                        },
                        child: Text(
                          "Crate an account",
                          style: TextStyle(
                              color: AppColors.loginScreenFontColor,
                              fontWeight: FontWeight.bold),
                        ))
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
