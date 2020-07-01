import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpstracker/UI/Navigator/MyNavigator.dart';
import 'package:gpstracker/Values/AppColors.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  int _state = 0;
  Widget _submitButton() {
    return
      new RawMaterialButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            setState(() {
              if (_state == 0) {
                animateButton();
              }
            });
          }
        },
        child: setUpButtonChild(),
        shape: CircleBorder(),
        elevation: 2.0,
        fillColor: AppColors.logo_00,
        padding: const EdgeInsets.all(8.0),
      );
  }
  Widget setUpButtonChild() {
    if (_state == 0) {
      return new Icon(
        Icons.arrow_forward,
        color: Colors.white,
        size: 35.0,
      );
    } else if (_state == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Icon(Icons.check, color: Colors.white,size: 35.0);
    }
  }
  void animateButton() async {
    setState(() {
      _state = 1;
    });
    Timer(Duration(milliseconds: 1100), () {
      setState(() {
        _state = 2;
      MyNavigator.goToOTPScreen(context);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final height =  MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.logo_00,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
              height: height,
              width: width,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: height*0.45,
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/logo/LOGOKoffeekodesWhite.png',width: width*0.6,),
                          SizedBox(height: 50,),
                          Container(
                            transform: Matrix4.translationValues(0, height*0.07, 0),
                            child: Text('Sign In',style: GoogleFonts.aBeeZee(fontSize: 23,color: AppColors.white_30),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: height*0.55,
                      width: width,
                      decoration: BoxDecoration(
                          color: AppColors.white_00,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)
                          )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 20,right: 20,top: height*0.08),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Mobile Number',style: TextStyle(
                                      fontSize:15,fontWeight: FontWeight.bold
                                  ),),
                                  SizedBox(height: 15,),
                                  Container(
                                    child: TextField(
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                          hintText: 'Enter your mobile number',
                                          hintStyle: TextStyle(fontSize:15),
                                          prefixIcon: Icon(Icons.phone),
                                          border: InputBorder.none,
                                          fillColor: AppColors.white_50,
                                          filled: true),
                                    ),
                                  ),
                                  SizedBox(height: 50,),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Text('Sign In',style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold
                                            ),),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: _submitButton(),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
          ),
        )
      )
    );
  }
}
