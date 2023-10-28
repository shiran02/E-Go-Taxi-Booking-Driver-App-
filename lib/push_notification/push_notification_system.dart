import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/models/user_ride_requet_information.dart';
import 'package:driver_app/push_notification/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudingMessaging(BuildContext context) async{

    // 1.terminated
    // -> when the app is completely close and opened directly push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){

            if(remoteMessage != null){

              print("this is Ride Request Id : ::::::");
              print(remoteMessage.data["rideRequestId"]);
              //display ride request information - user information who request a ride
              readUserRideRequestInformation(remoteMessage.data["rideRequestId"] , context);
            }
    });


    // 2 . foreground
    // when the app is open and it receive push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //display ride request information - user information who request a ride

      print("this is Ride Request Id : ::::::");
      print(remoteMessage?.data["rideRequestId"]);
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);

    });


    // 3. background
    // when the app is in the background and opened directly push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      //display ride request information - user information who request a ride

      print("this is Ride Request Id : ::::::");
      print(remoteMessage?.data["rideRequestId"]);
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);

    });
  }

  Future genaratingAndGetToken() async{
    String? registrationToken =  await messaging.getToken();
    print("FCM registation Token ");
    print(registrationToken);
   // return registrationToken;
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUer!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");

  }


  readUserRideRequestInformation(String userRideRequestId ,BuildContext context){

    print(" in  loop");


    FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .child(userRideRequestId)
        .once()
        .then((snapData)
    {
      if(snapData.snapshot.value != null){

        audioPlayer.open(Audio("music/music_notification.mp3"));
        audioPlayer.play();

        double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

        double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];


        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

        String? rideRequestId = snapData.snapshot.key;

        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;


        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;
        userRideRequestDetails.rideReqiuestId = rideRequestId;

        // print("user Ride Request inforamation :::::::::::");
        // print(userRideRequestDetails.userName);
        // print(userRideRequestDetails.userPhone);
        print(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
         print(userRideRequestDetails.rideReqiuestId);


        showDialog(
          context: context,
            builder: (BuildContext context) => NotificationDialogBox(
                  userRideRequestInformation: userRideRequestDetails
            ),
        );

      }
      else
      {
      //  print(userRideRequestDetails.rideReqiuestId);
        Fluttertoast.showToast(msg: "This ride Request Id not exists");
      }

    });
  }


}