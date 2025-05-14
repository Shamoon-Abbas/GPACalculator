import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/main.dart';

class splashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return splashScreenState();
  }
}


class splashScreenState extends State<splashScreen> {


  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds:3),(){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context)=>firstScreen()));
    });

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text("GPA",style: TextStyle(
                  fontSize: 100,
                  fontFamily: "Satisfy-Regular",
                  color: Colors.black
                ),),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25)
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(11, 14, 12, 10),
                  child: Text("calculator",style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: "Rockybilly"
                  ),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}