import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpstracker/UI/Dashboard/dashboard.dart';
import 'package:gpstracker/UI/LoginPage/login_screen.dart';
import 'package:gpstracker/Values/AppColors.dart';

void main() async{
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runApp(KOFEE());
}
class KOFEE extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'GPS Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.logo_40,
        textTheme:GoogleFonts.montserratAlternatesTextTheme(textTheme).copyWith(
          body1: GoogleFonts.montserrat(textStyle: textTheme.body1),
        ),
      ),
      home: LoginScreen(),
      routes: <String,WidgetBuilder>{
        '/loginScreen' : (BuildContext context) => LoginScreen(),
        '/homepage' : (BuildContext context) => DashBoard(),
      },
    );
  }
}

