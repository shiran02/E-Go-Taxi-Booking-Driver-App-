
import 'package:driver_app/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../appConstatns/app_colors.dart';

class FareAmountCollectionDialog extends StatefulWidget {

  double? totalFareAmount;

  FareAmountCollectionDialog({
    this.totalFareAmount
});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor:  Colors.yellowAccent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
          boxShadow:
          [
            BoxShadow(
              color: AppColors.yellowColor,
              blurRadius: 30,
              spreadRadius: .9,
              offset: Offset(0.1, 0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),

            Text(
              "Trip Fare Amount " + "(" + driverVehicalType!.toUpperCase() + ")",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.yellowAccent,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20,),


            const Divider(
              thickness: 4,
              color: Colors.yellowAccent
            ),

            const SizedBox(height: 16,),

            Text(
              widget.totalFareAmount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                fontSize: 50,
              ),
            ),

            const SizedBox(height: 10,),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "This is the total trip amount, Please it Collect from user.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.orangeAccent,
                ),
              ),
            ),

            const SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                onPressed: ()
                {
                  Future.delayed(const Duration(milliseconds: 2000), ()
                  {
                    SystemNavigator.pop();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Collect Cash",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$  " + widget.totalFareAmount!.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
