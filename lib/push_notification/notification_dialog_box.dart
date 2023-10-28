import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/appConstatns/app_colors.dart';
import 'package:driver_app/assistants/assistant_methods.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/mainScreen/new_trip_screen.dart';
import 'package:driver_app/models/user_ride_requet_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {

  UserRideRequestInformation? userRideRequestInformation;

  NotificationDialogBox({
     this.userRideRequestInformation,
    });


  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.yellowColor
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "images/threewheel.png",
              width: 160,
            ),
            const SizedBox(height: 2),
            const Text(
              "New Ride Requst",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          child: Text(
                           widget.userRideRequestInformation!.originAddress!,
                           style: const TextStyle(
                               color: AppColors.darkGreen,
                               fontSize: 16,
                               fontWeight: FontWeight.bold
                           ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Container(
                          child: Text(
                        widget.userRideRequestInformation!.destinationAddress!,
                        style: const TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                        )
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(

                        onPressed: (){
                          audioPlayer.pause();
                          audioPlayer.stop();
                          audioPlayer = AssetsAudioPlayer();

                          Navigator.pop(context);

                          //
                          FirebaseDatabase.instance.ref()
                              .child("All Ride Request")
                              .child(widget.userRideRequestInformation!.rideReqiuestId!)
                              .remove().then((value)
                          {
                            FirebaseDatabase.instance.ref()
                                .child("drivers")
                                .child(currentFirebaseUer!.uid)
                                .child("newRideStatus")
                                .set("idle");
                          }).then((value) {
                            FirebaseDatabase.instance.ref()
                                .child("drivers")
                                .child(currentFirebaseUer!.uid)
                                .child("tripsHistoty")
                                .child(widget.userRideRequestInformation!.rideReqiuestId!)
                                .remove();

                          }).then((value){
                            Fluttertoast.showToast(msg: "Ride Request has cancelled.successfully..restart map now");
                          });

                          Future.delayed( const Duration(microseconds: 2000),(){
                            SystemNavigator.pop();
                          });



                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: Text(
                          "cancel".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20,),
                      ElevatedButton(
                        onPressed: (){

                          audioPlayer.pause();
                          audioPlayer.stop();
                          audioPlayer = AssetsAudioPlayer();

                        //  Navigator.pop(context);

                          acceptRideRequest(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.darkGreen,
                        ),
                        child: Text(
                          "Accept".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    }

  acceptRideRequest(BuildContext context){
    String getRideRequestId = "";
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUer!.uid)
        .child('newRideStatus')
        .once()
        .then((snap){

          if(snap.snapshot.value != null)
          {
            getRideRequestId = snap.snapshot.value.toString();
          }
          else
          {
            Fluttertoast.showToast(msg: "this ride request is not exist");

          }
          print("ride request :;;;;;;;;;;;;;;;;;;;;;;;;;;");
          print(getRideRequestId);
          print(widget.userRideRequestInformation!.rideReqiuestId.toString());

          if(getRideRequestId == widget.userRideRequestInformation!.rideReqiuestId)
          {
            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(currentFirebaseUer!.uid)
                .child('newRideStatus')
                .set("accepted");

            AssistantMethods.pauseLiveLocationUpdate();

            //trip started now :  send driver to trip screen

            Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
                userRideRequestInformation  : widget.userRideRequestInformation)));
          }
          else
          {
            Fluttertoast.showToast(msg: "this Ride Request is Deleted");

          }


    });
  }
}
