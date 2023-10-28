import 'package:driver_app/assistants/request_assistant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_detail_info.dart';
import '../models/directions.dart';
import '../models/user_model.dart';


class AssistantMethods{

  String mapKey = "AIzaSyCWVJSsMkbwzC8r7XhW62cycZMowkh-OKY";


  static Future<String> searchAddressForGeograpiCodinates(Position position , context)async{
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyCWVJSsMkbwzC8r7XhW62cycZMowkh-OKY";
    String humanReadableAddress = "";

    var requestresponse =  await RequestAssistant.receiveRequest(apiUrl);

    if(requestresponse !=  "Error occured ,Faild. No Response"){
      humanReadableAddress =requestresponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatiude = position.latitude.toString();
      userPickUpAddress.locationLongitude = position.longitude.toString();
      userPickUpAddress.locationname = humanReadableAddress;

      Provider.of<AppInfo>(context , listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    
    return humanReadableAddress;
  }





  static void readCurrentUserOnLineUserInfo() async{

    currentFirebaseUer = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
    .ref()
    .child("users")
    .child(currentFirebaseUer!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
       userModelCurrentInfo =   UserModel.fromSnapshot(snap.snapshot);
       print("name" + userModelCurrentInfo!.name.toString());
       print("email" + userModelCurrentInfo!.email.toString());
      }
    });
  }


  static Future<DirectionDetailInfo?> obtainOriginToDestinationDirectionDetail(LatLng originPosition , LatLng destinationPosition)async{

    String urlOriginToDestinationDirectionDetail = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=AIzaSyCWVJSsMkbwzC8r7XhW62cycZMowkh-OKY";

    //get response from API 
    var responseDirectionApi =  await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetail);
  
  
     if (responseDirectionApi == "Error occured ,Faild. No Response") {
        return null;
      }


      DirectionDetailInfo directionDetailInfo = DirectionDetailInfo();
      directionDetailInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];
      directionDetailInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
      directionDetailInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
      directionDetailInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
      directionDetailInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];


      return directionDetailInfo;


  }

  static pauseLiveLocationUpdate(){
    streamSubscriptionPosttion!.pause();
    Geofire.removeLocation(currentFirebaseUer!.uid);
  }

  static resumetLiveLocationUpdates(){
    streamSubscriptionPosttion!.resume();
    Geofire.setLocation(
        currentFirebaseUer!.uid,
        driverCurentPosition!.latitude,
        driverCurentPosition!.longitude
    );
  }


  static double claculateFairAmountFromOriginoDestination(DirectionDetailInfo directionDetailInfo){

    double timeTraveledFareAmountPerMinutes = (directionDetailInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerLilometer = (directionDetailInfo.duration_value! / 1000) * 0.1;
    double totalFaireAmount = timeTraveledFareAmountPerMinutes + distanceTraveledFareAmountPerLilometer;

    // 1 used = 120;
    double localCurrencyAmountTotalFare = totalFaireAmount * 120;

    if(driverVehicalType == "bike")
    {
      double resultFareAnount = (totalFaireAmount.truncate()) / 2.0;
      return resultFareAnount;
    }
    else if(driverVehicalType == "uber-go")
    {
      return totalFaireAmount.truncate().toDouble();
    }
    else if(driverVehicalType == "uber-x")
    {
      double resultFareAnount = (totalFaireAmount.truncate()) * 2.0;
      return resultFareAnount;
    }
    else
    {
      return totalFaireAmount.truncate().toDouble();
    }


  }

}