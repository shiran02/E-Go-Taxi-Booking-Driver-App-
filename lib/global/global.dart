

import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/models/drivwe_data.dart';
import 'package:driver_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUer ;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamSubscriptionPosttion;
StreamSubscription<Position>? streamSubscriptionDriverLivePosttion;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? driverCurentPosition;
DriverData onlinerDriverData = DriverData();
String? driverVehicalType = "";