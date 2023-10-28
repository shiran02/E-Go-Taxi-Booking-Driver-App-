import 'package:driver_app/global/global.dart';
import 'package:flutter/material.dart';

import '../splachScreen/splach_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          child: Text("Sign Out"),
          onPressed: () {
            fAuth.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const MySplashScreen()));
          },
        ),
      ),
    );
  }
}
