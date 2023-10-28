import 'package:flutter/material.dart';

class EarningTabPage extends StatefulWidget {
  const EarningTabPage({super.key});

  @override
  State<EarningTabPage> createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child:Text('Earning page'),
      ),
    );
  }
}