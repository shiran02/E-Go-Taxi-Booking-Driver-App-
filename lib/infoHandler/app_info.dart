

import 'package:flutter/material.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier{


  Directions? userPickUpLocation;
  Directions? userDropOffLocation;

  void updatePickUpLocationAddress(Directions userPickUpAddress ){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress ){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }


}