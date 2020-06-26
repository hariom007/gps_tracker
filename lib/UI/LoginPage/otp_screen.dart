import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpstracker/UI/Navigator/MyNavigator.dart';
import 'package:gpstracker/Values/AppColors.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  final _formKey = GlobalKey<FormState>();
  int _state = 0;
  TextEditingController _otpController=TextEditingController();

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
        MyNavigator.goToDashBoardWithKill(context);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final height =  MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: AppColors.logo_00,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
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
                                  SizedBox(height: 30,),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text('Verification code',style: TextStyle(fontSize: 21,),),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 20,right: 20,top: 25),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Enter the 4 digit OTP',style: TextStyle(
                                              fontSize:17,fontWeight: FontWeight.bold
                                          ),),
                                          SizedBox(height: 15,),
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.6,
                                            child: TextField(
                                              maxLength: 4,
                                              maxLengthEnforced: true,
                                              keyboardType: TextInputType.phone,
                                              showCursor: false,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  letterSpacing: 35),
                                              decoration: InputDecoration(
                                                  hintStyle: TextStyle(fontSize:25),
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(left:width*0.05,right:width*0.05 ),
                                                  fillColor: AppColors.white_50,
                                                  filled: true),
                                              controller: _otpController,
                                            ),
                                          ),
                                          SizedBox(height: 40,),
                                          Container(
                                            alignment: Alignment.center,
                                            child: _submitButton(),
                                          ),
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
            ),
            Positioned(
                top: 40,
                left: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                          child: Icon(Icons.keyboard_arrow_left,
                              color: Colors.white),
                        ),
                        Text('Back',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500,
                                color: Colors.white))
                      ],
                    ),
                  ),
                )),
          ],
        )
    );
  }
}
