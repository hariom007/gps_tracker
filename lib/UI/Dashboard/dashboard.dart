import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpstracker/Api/api.dart';
import 'package:gpstracker/UI/Navigator/MyNavigator.dart';
import 'package:gpstracker/Values/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  bool isSwitched = false;
  int _status = 0;
  Position _currentPosition;
  String latitu,longi;



  void initState() {
    super.initState();
  }
/*
  @override
  void dispose() {
    _getCurrentLocation();
  }*/

  void _onSwitchClick() async {
    if(_currentPosition !=null){
       latitu =_currentPosition.latitude.toString();
       longi = _currentPosition.longitude.toString();
    }

    var data = {
      "id":"1",
      "driver_id":"3",
      "latitude": latitu,
      "longitude":longi,
      "is_completed": "0"
    };
//    print(data);
    try {
      var res = await CallApi().postData(data, 'getDriverLocation');
      var body = json.decode(res.body);
      print(body);
      if (body != null && body['response'] != 'Invalid')
        {
          _getCurrentLocation();
        }
    }
    catch(e){
      print('print error: $e');
    }
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koffeekodes'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Tooltip(
            message: 'Turned on/off GPS',
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                if (isSwitched = true) {
                  setState(() {
                    isSwitched == value ?
                    Timer.periodic(Duration(seconds: 5), (Timer t) =>
                          _onSwitchClick()
                        ) :
                    setState(() {
                    MyNavigator.goToDashBoardWithKill(context);
                    });
                  });
                }
              },
              activeTrackColor: Colors.red,
              activeColor: Colors.green,
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 18),
                      child: Text('1.',style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold
                      ),),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('Hariom Gupta',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Text('Guru Krupa nagar, Veer Bhagat chawl, Bhargav road, Kubernagr-382340, Ahmedabad',
                            style: TextStyle(fontSize: 14),),
                            SizedBox(height: 3,),
                            RichText(
                              text: TextSpan(
                                  style: GoogleFonts.montserrat(
                                      color: AppColors.black,
                                      fontSize: 12
                                  ),
                                  children: [
                                    TextSpan(text: 'Contact us - '),
                                    TextSpan(text: '7802852664'),
                                  ]
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: <Widget>[
                                Tooltip(
                                  message: 'Directions',
                                  child: RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4,),
                                      child: RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              WidgetSpan(child: Icon(Icons.directions,color: AppColors.black,size: 16,)),
                                              TextSpan(text: '   Direction'),
                                            ]
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.white_20,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ),
                                SizedBox(width: 15,),
                                Tooltip(
                                  message: 'PDF Downloader',
                                  child: RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4,),
                                      child: RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              WidgetSpan(child: Image.asset('assets/icon/pdf.png',height: 15,)),
                                              TextSpan(text: '  PDF'),
                                            ]
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.white_90,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Verified',
                                  child:RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4,),
                                        child: Icon(Icons.check,size: 20,color: AppColors.white_00,)
                                    ),
                                    shape: CircleBorder(
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.logo_40,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    )
                  ],
                ),
                Divider(thickness: 0.9,)
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 18),
                      child: Text('2.',style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold
                      ),),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('Sunny Soni',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Text('K.R. Complex, Jhansi Garden,Udhana road, Surat',
                            style: TextStyle(fontSize: 14),),
                            SizedBox(height: 3,),
                            RichText(
                              text: TextSpan(
                                  style: GoogleFonts.montserrat(
                                      color: AppColors.black,
                                      fontSize: 12
                                  ),
                                  children: [
                                    TextSpan(text: 'Contact us - '),
                                    TextSpan(text: '9726289580'),
                                  ]
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: <Widget>[
                                Tooltip(
                                  message: 'Directions',
                                  child: RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4,),
                                      child: RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              WidgetSpan(child: Icon(Icons.directions,color: AppColors.black,size: 16,)),
                                              TextSpan(text: '   Direction'),
                                            ]
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.white_20,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ),
                                SizedBox(width: 15,),
                                Tooltip(
                                  message: 'PDF Downloader',
                                  child: RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4,),
                                      child: RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              WidgetSpan(child: Image.asset('assets/icon/pdf.png',height: 15,)),
                                              TextSpan(text: '  PDF'),
                                            ]
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.white_90,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Verified',
                                  child:RawMaterialButton(
                                    onPressed: (){

                                    },
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4,),
                                        child: Icon(Icons.check,size: 20,color: AppColors.white_00,)
                                    ),
                                    shape: CircleBorder(
                                    ),
                                    elevation: 2.0,
                                    fillColor: AppColors.logo_40,
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    )
                  ],
                ),
                Divider(thickness: 0.9,),

if (_currentPosition != null)
Text(
"LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),

              ],
            ),
          ),
        ],
      )
    );
  }
}

/*if (_currentPosition != null)
Text(
"LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}\n${_currentAddress}"),
         */
