import 'dart:async';

import 'package:driver_app/main.dart';
import 'package:driver_app/push_notification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  var geoLocater = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;



  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  checkIfLocationPermissionload() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // get user current location
  localDriverPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurentPosition = currentPosition;

    LatLng latingPosition =
        LatLng(driverCurentPosition!.latitude, driverCurentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latingPosition, zoom: 1);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeograpiCodinates(
            driverCurentPosition!, context);
    print("this is your address" + humanReadableAddress);

    // userName = userModelCurrentInfo!.name!;
    //userEmail = userModelCurrentInfo!.email!;
  }

  readCurrentDriverInformation() async{

    currentFirebaseUer = fAuth.currentUser;

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUer!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null){
        onlinerDriverData.id =  (snap.snapshot.value as Map)["id"];
        onlinerDriverData.name = (snap.snapshot.value as Map)["name"];
        onlinerDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlinerDriverData.email = (snap.snapshot.value as Map)["email"];
        onlinerDriverData.car_color = (snap.snapshot.value as Map)["car_detail"]["car_color"];
        onlinerDriverData.car_model = (snap.snapshot.value as Map)["car_detail"]["car_model"];
        onlinerDriverData.car_number = (snap.snapshot.value as Map)["car_detail"]["car_number"];

        driverVehicalType = (snap.snapshot.value as Map)["car_detail"]["type"];

        print("::::::::::::::::::::::::::::::::::::::::::::::");
        print(onlinerDriverData.id);
        print(onlinerDriverData.email);
        print(onlinerDriverData.car_model);
        print(onlinerDriverData.car_number);

      }
    });




    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudingMessaging(context);
    pushNotificationSystem.genaratingAndGetToken();
  }
  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionload();
    readCurrentDriverInformation();
  }

  double topPaddingOfMap = 0;

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            //mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;

              // for black theme google map
              //  newGoogleMapController!.setMapStyle(_mapStyle);

              setState(() {
                //bottomPaddingOfMap = 275;
                topPaddingOfMap = 35;
              });

              blackThemeGoogleMap();
              localDriverPosition();
            },
          ),

          // ui for outline offline driver

          statusText != "Now Online"
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : Container(),

          //buttom for online driver

          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.45
                : 45,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {


                    if(isDriverActive != true){ // when offline go o online
                      driverIsOnline();
                      updateDrivverLocationRealTime();

                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });

                      Fluttertoast.showToast(msg: "You are online Now");
                    }else{  // when online press it go to offline
                      driverIsOfflineNow();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });

                      Fluttertoast.showToast(msg: "You are Offline Now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      )),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : const Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  driverIsOnline() async
  {

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    driverCurentPosition = pos;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUer!.uid, driverCurentPosition!.latitude,
        driverCurentPosition!.longitude
        );

    DatabaseReference ref = FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(currentFirebaseUer!.uid)
      .child("newRideStatus");


    
    ref.set("idle");
    
  }

  updateDrivverLocationRealTime(){
    streamSubscriptionPosttion = Geolocator.getPositionStream()
        .listen((Position position) {
          driverCurentPosition = position;

          if(isDriverActive == true){
            Geofire.setLocation(
                currentFirebaseUer!.uid,
                driverCurentPosition!.latitude,
                driverCurentPosition!.longitude
            );
          }

          //update driver position real time using geo fire............

          LatLng latlang = LatLng(
              driverCurentPosition!.latitude,
              driverCurentPosition!.longitude
          );

          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latlang));
    });
  }



  driverIsOfflineNow(){
    Geofire.removeLocation(currentFirebaseUer!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUer!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref..remove();
    ref = null;
    
    Future.delayed(Duration(microseconds: 2000),(){
      SystemChannels.platform.invokeListMethod( "SystemNavigator.pop");

     // MyApp.restartApp(context);
    });
   
  }
}
