import 'dart:async';

import 'package:driver_app/global/global.dart';
import 'package:driver_app/models/user_ride_requet_information.dart';
import 'package:driver_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../appConstatns/app_colors.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_google_map.dart';
import '../infoHandler/app_info.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {

  UserRideRequestInformation? userRideRequestInformation;

  NewTripScreen({
    this.userRideRequestInformation
});

  @override
  State<NewTripScreen> createState() => _NewTripSCreenState();
}

class _NewTripSCreenState extends State<NewTripScreen>
{

  String? buttonTitle = "Arrived";
  MaterialColor buttonColor = Colors.green;
  //String statusBtn = "accepted";

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCordinate = [];
  PolylinePoints polyLinePoints = PolylinePoints();


  GoogleMapController? newTripGoogleMapController;

  BitmapDescriptor? iconAnimaterMarker;
  var geoLacator = Geolocator();
  Position? onlinedriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestication =  "";

  bool isRequestDirectionDetails = false;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  double bottomPaddingOfMap = 0;



  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // 1.when driver accept the user ride request
  //  origin lat lang = driver current position
  //  destination lat lang = user pick up location

  // 2.user alrady pick up the user
  //  origin lat lang = user pickup position
  //  destination lat lang = user drop uof location

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatlang ,LatLng destinationLatlang) async {



    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: ",Please wait.",
      ),
    );

    var directionDetailsInfo =
    await AssistantMethods.obtainOriginToDestinationDirectionDetail(
        originLatlang, destinationLatlang);



    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
    pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polyLinePositionCordinate.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCordinate
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.white,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCordinate,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatlang.latitude > destinationLatlang.latitude &&
        originLatlang.longitude > destinationLatlang.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatlang, northeast: originLatlang);
    } else if (originLatlang.longitude > destinationLatlang.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatlang.latitude, destinationLatlang.longitude),
        northeast: LatLng(destinationLatlang.latitude, originLatlang.longitude),
      );
    } else if (originLatlang.latitude > destinationLatlang.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatlang.latitude, originLatlang.longitude),
        northeast: LatLng(originLatlang.latitude, destinationLatlang.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatlang, northeast: destinationLatlang);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),

      position: originLatlang,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),

      position: destinationLatlang,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatlang,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatlang,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

@override
  void initState(){
    super.initState();
    saveAssignedDriverDetailstoRideRequest();
  }

  createDriverIconMarker()
  {
    if (iconAnimaterMarker == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimaterMarker = value;
      });
    }
  }


  getDrivverLocationUpdatesAtRealTime()
  {
    LatLng oldLatLang = LatLng(0, 0);

    streamSubscriptionDriverLivePosttion = Geolocator.getPositionStream()
        .listen((Position position) {
      driverCurentPosition = position;
      onlinedriverCurrentPosition = position;


      //update driver position real time using geo fire............

      LatLng latlangLiveDriverPosition = LatLng(
          onlinedriverCurrentPosition!.latitude,
          onlinedriverCurrentPosition!.longitude
      );

      Marker animatingaMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latlangLiveDriverPosition,
        icon: iconAnimaterMarker!,
        infoWindow: const InfoWindow(title: "this is your cirrent Location"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latlangLiveDriverPosition,zoom: 16);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingaMarker);
      });

      oldLatLang = latlangLiveDriverPosition;
      updateDurationTimeRealTime();

      ///updating driver location at real time in database
      Map driverLatLngDataMap =
      {
        "latitude" : onlinedriverCurrentPosition!.latitude.toString(),
        "longitude" : onlinedriverCurrentPosition!.longitude.toString(),
      };
      
      FirebaseDatabase.instance.ref().child("All Ride Request")
          .child(widget.userRideRequestInformation!.rideReqiuestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);

    });
  }

  updateDurationTimeRealTime() async
  {

      if(isRequestDirectionDetails == false){
        isRequestDirectionDetails == true;

        if(onlinedriverCurrentPosition == null)
        {
          return;
        }

        var originLatLng = LatLng(
            onlinedriverCurrentPosition!.latitude,
            onlinedriverCurrentPosition!.longitude
        ); ///driver current location

        var destinationLatLng;

        if(rideRequestStatus == "accepted"){
          //user pick up Location
          destinationLatLng = widget.userRideRequestInformation!.originLatLng;
        }
        else
        {
          //user drop of locatiom
          destinationLatLng = widget.userRideRequestInformation!.destinationLatLng;
        }

        var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetail(originLatLng, destinationLatLng);

        if(directionInformation != null){
          setState(() {
            durationFromOriginToDestication = directionInformation.duration_text!;
          });
        }

        isRequestDirectionDetails == false;
      }

  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();


    return Stack(
      children: [
        //google map
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          //mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          markers: setOfMarkers,
          circles: setOfCircle,
          polylines: setOfPolyline,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            newTripGoogleMapController = controller;

            // for black theme google map
            //  newGoogleMapController!.setMapStyle(_mapStyle);

            var driverCurrentLatLng = LatLng(
                driverCurentPosition!.latitude,
                driverCurentPosition!.longitude
            );

            getDrivverLocationUpdatesAtRealTime();

            var userPickUpLatLng = widget.userRideRequestInformation!.originLatLng;

            drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatLng!);
            setState(() {
              bottomPaddingOfMap = 275;
             // topPaddingOfMap = 35;
            });

            blackThemeGoogleMap(newTripGoogleMapController);
           // localDriverPosition();
          },
        ),

        // ui
        Positioned(
          bottom: 10,
          left: 10,
          right:10,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.fa,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow:
              [
                BoxShadow(
                  color: AppColors.yellowColor,
                  blurRadius: 32,
                  spreadRadius: .9,
                  offset: Offset(0.1, 0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  //duration
                   Text(
                    durationFromOriginToDestication,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Divider(
                    thickness: 2,
                    height: 2,
                    color: Colors.grey,
                  ),


                  //user name - icon
                  Center(
                    child: Container(
                      child: Row(
                        children: [
                             Text(
                              widget.userRideRequestInformation!.userName!,
                              style: const TextStyle(
                                fontSize: 22,
                               fontWeight: FontWeight.bold,
                                color: Colors.yellowAccent,

                              ),
                            ),

                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.phone_android,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18,),

                  //user PickUp Address with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            child: Text(
                              widget.userRideRequestInformation!.originAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  //user DropOff Address with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestInformation!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color:Colors.deepOrange
                              ,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24,),

                  const Divider(
                    thickness: 2,
                    height: 2,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 10.0),

                  ElevatedButton.icon(
                    onPressed: () async
                    {
                      //driver has arrived at user PickUp Location
                      if(rideRequestStatus == "accepted")
                      {
                        rideRequestStatus = "arrived";

                        FirebaseDatabase.instance.ref()
                            .child("All Ride Request")
                            .child(widget.userRideRequestInformation!.rideReqiuestId!)
                            .child("status")
                            .set(rideRequestStatus);

                        setState(() {
                          buttonTitle = "Let's Go"; //start the trip
                          buttonColor = Colors.lightGreen;
                        });

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext c)=> ProgressDialog(
                            message: "Loading...",
                          ),
                        );

                        await drawPolyLineFromOriginToDestination(
                            widget.userRideRequestInformation!.originLatLng!,
                            widget.userRideRequestInformation!.destinationLatLng!
                        );

                        Navigator.pop(context);
                      }
                      //user  has already sit in driver's car -> start trip  -. buttom lets go
                      else if(rideRequestStatus == "arrived")
                      {
                        rideRequestStatus = "ontrip";

                        FirebaseDatabase.instance.ref()
                            .child("All Ride Request")
                            .child(widget.userRideRequestInformation!.rideReqiuestId!)
                            .child("status")
                            .set(rideRequestStatus);

                        setState(() {
                          buttonTitle = "To End Trip"; //start the trip
                          buttonColor = Colors.red;
                        });

                      }
                      //user /driver reached to the drop if destination  -. end trip buttom lets go
                      else if(rideRequestStatus == "ontrip")
                      {
                        endTripNow();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                    ),
                    icon: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 25,
                    ),
                    label: Text(
                      buttonTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
              )
            ),
          ),
        )

      ],
    );
  }


  endTripNow() async{

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c)=> ProgressDialog(
        message: "Please Wait...",
      ),
    );


    //get the trip direction Details -> distance traveled

    var currentDriverPostitionLatLang = LatLng(
        onlinedriverCurrentPosition!.latitude,
        onlinedriverCurrentPosition!.longitude
    );

    var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetail(
        currentDriverPostitionLatLang,
        widget.userRideRequestInformation!.originLatLng!
    );

    // fare amount
    double totalFareAmount =  AssistantMethods.claculateFairAmountFromOriginoDestination(tripDirectionDetails!);
    
    
    FirebaseDatabase.instance.ref().child("All Ride Request")
        .child(widget.userRideRequestInformation!.rideReqiuestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("All Ride Request")
        .child(widget.userRideRequestInformation!.rideReqiuestId!)
        .child("status")
        .set("ended");

    streamSubscriptionDriverLivePosttion!.cancel();
    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext c) =>
        FareAmountCollectionDialog(
            totalFareAmount : totalFareAmount
        ),
    );

    saveFareAmountTotalToDriveEarnigs(totalFareAmount);
  
  }

  saveFareAmountTotalToDriveEarnigs(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers")
        .child(currentFirebaseUer!.uid)
        .child("earning")
        .once()
        .then((snap){

          if(snap.snapshot.value != null){

            double oldEarnings = double.parse(snap.snapshot.value.toString());
            double driverTotalEarning = totalFareAmount + oldEarnings;

            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(currentFirebaseUer!.uid)
                .child("earning")
                 .set(driverTotalEarning.toString());

          }else{
            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(currentFirebaseUer!.uid)
                .child("earning")
                .set(totalFareAmount.toString());
          }
    });
  }



  saveAssignedDriverDetailstoRideRequest()
  {
    DatabaseReference databaseReference= FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .child(widget.userRideRequestInformation!.rideReqiuestId!);

    Map driverLocationDataMap =
    {
      "latitude" : driverCurentPosition!.latitude.toString(),
      "longtude" : driverCurentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlinerDriverData.id);
    databaseReference.child("driverName").set(onlinerDriverData.name);
    databaseReference.child("driverPhone").set(onlinerDriverData.phone);
    databaseReference.child("car_detail").set(onlinerDriverData.car_color.toString()+" " + onlinerDriverData.car_model.toString()+" "  + onlinerDriverData.car_number.toString());


    saveRideRequestIdToDriverHistory();

  }

  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripHistoryReference= FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUer!.uid)
        .child("tripsHistoty");

    tripHistoryReference.child(widget.userRideRequestInformation!.rideReqiuestId!).set(true);

  }
}
