import 'package:driver_app/appConstatns/app_colors.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
 // const ProgressDialog({super.key});

  String? message;
  ProgressDialog({ this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(16.8),
        decoration:BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(padding: EdgeInsets.all(16),
         child: Row(
          children: [
            const SizedBox(width: 6.0),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),

            const SizedBox(width: 26.0,),

            Text(
              message!,
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 12,
              ),

            )
          ],
         ),
        ),
      ),
    );
  }
}