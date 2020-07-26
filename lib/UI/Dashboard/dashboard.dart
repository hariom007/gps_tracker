import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpstracker/Api/api.dart';
import 'package:gpstracker/Values/AppColors.dart';
import 'package:gpstracker/project_model/driver_invoice_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const debug = true;

class DashBoard extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;

  DashBoard({Key key, this.platform}) : super(key: key);


  @override
  _DashBoardState createState() => _DashBoardState();
}
class Global{
  static final shared =Global();
  bool isSwitched2 = false;
}


/*
class _PDFHolder {
  final String Invoice;
  final DriverInvoice task;

  _PDFHolder({this.Invoice, this.task});
}
*/




class _DashBoardState extends State<DashBoard> {

  DriverInvoice invoice;
  bool isSwitched2;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String latitu,longi;
  int _isCompleted=0;
  Timer timer;

  List<DriverInvoice> _driverInvoice;
//  List<_PDFHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  final invoicePDF=[];

  @override
  void initState() {
    super.initState();

    isSwitched2 = Global.shared.isSwitched2;
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    _permissionReady = false;
    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _driverInvoice?.firstWhere((task) => task.id == id);
      if (task != null) {
        setState(() {
          task.status = status;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }



  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }



  void _cancelDownload(DriverInvoice task) async {
    await FlutterDownloader.cancel(taskId: task.id);
  }

  void _pauseDownload(DriverInvoice task) async {
    await FlutterDownloader.pause(taskId: task.id);
  }

  void _resumeDownload(DriverInvoice task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.id);
    task.id = newTaskId;
  }

  void _retryDownload(DriverInvoice task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.id);
    task.id = newTaskId;
  }

  Future<bool> _openDownloadedFile(DriverInvoice task) {
    return FlutterDownloader.open(taskId: task.id);
  }

  void _delete(DriverInvoice task) async {
    await FlutterDownloader.remove(
        taskId: task.id, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      PermissionStatus permission = await Permission.storage.request();
      if (permission != PermissionStatus.granted) {

        if (await Permission.storage.request().isGranted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _driverInvoice = [];
//    _items = [];

    _driverInvoice.addAll(invoicePDF.map((document) =>
        DriverInvoice(Invoice: document['Invoice'])));

    _driverInvoice.add(DriverInvoice(Invoice: 'Documents'));


    tasks?.forEach((task) {
      for (DriverInvoice info in _driverInvoice) {
        if (info.Invoice == task.taskId) {
          info.id = task.taskId;
          info.status = task.status;
        }
      }
    });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }


  void _onSwitchClick() async {
    if(_currentPosition !=null) {
       latitu =_currentPosition.latitude.toString();
       longi = _currentPosition.longitude.toString();
    }
    var data = {
      "id":"1",
      "driver_id":"3",
      "latitude": latitu,
      "longitude":longi,
      "is_completed": _isCompleted
    };
    print(data);
    try {
      var res = await CallApi().postData(data, 'getDriverLocation');
      var body = json.decode(res.body);
      print(body);
      if (body != null && body['response'] != 'Invalid')
        {
          _getCurrentLocation();
        }
      else{
        setState(() {
          _isCompleted=1;
        });
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


//  SharedPreferences sharedPreferences;

  Future<List<DriverInvoice>> _driverInvoiceList() async {
//    sharedPreferences = await SharedPreferences.getInstance();
//    String uid = sharedPreferences.getString('uid');
    List<DriverInvoice> list;
    var data = {
      "driver_id":"3"
    };
    try {
      var res = await CallApi().postData(data, "getDriverInvoice");
      var body = json.decode(res.body);
      print(body);
      String st = body['st'];
      if(st == "success") {
        List invoicelist = body['uid'] as List;
        list = invoicelist.map<DriverInvoice>((json) => DriverInvoice.fromJson(json)).toList();
        return list;
      }
    } catch (exception) {
      print('$exception');
    }
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
              value: isSwitched2,
              onChanged: (bool isOn) {
                setState(() {
                  isSwitched2 = isOn;
                  Global.shared.isSwitched2 = isOn;
                  isOn =! isOn;
                  Timer.periodic(
                      Duration(seconds: 5), (Timer t) {
                            isSwitched2 ? _onSwitchClick() : Container();
                          }
                  );
                  print(isSwitched2);
                });
              },
              activeTrackColor: Colors.red,
              activeColor: Colors.green,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _driverInvoiceList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }else if (snapshot.data.length == 0) {
            //Navigator.pop(context);
            return Center(
                child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Sorry ! Driver doesn't exists.",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    )));
          }
          else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var sr= index+1;
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 18),
                              child: Text( sr.toString()+".",style: TextStyle(
                                  fontSize: 18,fontWeight: FontWeight.bold
                              ),),
                            ),
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(snapshot.data[index].UserName,style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16
                                          ),),
                                        ],
                                      ),
                                      SizedBox(height: 2,),
                                      RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 14
                                            ),
                                            children: [
                                              TextSpan(text: 'Address - '),
                                              TextSpan(text: snapshot.data[index].UserAddress),
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 2,),
                                      RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              TextSpan(text: 'Email - '),
                                              TextSpan(text: snapshot.data[index].UserEmail),
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 2,),
                                      RichText(
                                        text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                                color: AppColors.black,
                                                fontSize: 12
                                            ),
                                            children: [
                                              TextSpan(text: 'Contact us - '),
                                              TextSpan(text: snapshot.data[index].UserMobile),
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 2,),
                                      Row(
                                        children: <Widget>[
                                         _buildActionForTask(snapshot.data[index].Invoice),
                                          SizedBox(width: 15,),
                                          Tooltip(
                                            message: 'PDF Downloader',
                                            child: RawMaterialButton(
                                              onPressed: (){
//                                                _buildActionForTask(snapshot.data[index].Invoice);

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
                  );
                });
          }
        },
      ),
    );
  }

  Widget _buildActionForTask(String url) {
    if (invoice.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () async{
          await FlutterDownloader.enqueue(
              url: 'https://trading.koffeekodes.com$url',
//              headers: {"auth": "test_for_sql_encoding"},
              savedDir: _localPath,
              showNotification: true,
              openFileFromNotification: true);
        },
        child: new Icon(Icons.file_download),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (invoice.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(invoice);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (invoice.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(invoice);
        },
        child: new Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    }
    else if (invoice.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            'Ready',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(invoice);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    }
    else if (invoice.status == DownloadTaskStatus.canceled) {
      return new Text('Canceled', style: new TextStyle(color: Colors.red));
    } else if (invoice.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('Failed', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(invoice);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }
}
