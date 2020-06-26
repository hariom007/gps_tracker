import 'package:flutter/material.dart';
import 'package:gpstracker/UI/LoginPage/otp_screen.dart';

class MyNavigator{

  static void goToLoginWithKill(BuildContext context){
    Navigator.pushReplacementNamed(context, '/loginScreen');
  }
  static void  goToDashBoardWithKill(BuildContext context){
    Navigator.pushReplacementNamed(context, '/homepage');
  }
  static void goToOTPScreen(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OTPScreen()));
  }

}