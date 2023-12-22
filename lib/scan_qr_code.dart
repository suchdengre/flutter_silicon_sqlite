import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_silicon_app/QrScreen.dart';
import 'package:flutter_silicon_app/home_screen.dart';
import 'package:flutter_silicon_app/model.dart';
import 'package:flutter_silicon_app/sqlite/DatabaseHelper.dart';
import 'package:flutter_silicon_app/sqlite/User.dart';

import 'LocalStorage.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({super.key});

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String qrResult = "Scanned Data will appear here";
  Future<void> scanQR()async{
   try{
    final qrCode = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
    if(!mounted) return;
    List<Info> allUserData =  await LocalStorage.getAllUserDataLocally();
    setState(() {
      this.qrResult = qrCode.toString();
      Map<String, String> result = extractNameAndLocation(qrResult);
      print('${result['name']}');
/*     int count = await LocalStorage.countUserDataLocally();

      print('Total Users: $count');*/

     // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> QRScreen(qrScreenCode: '${result['name']}')));
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> QRScreen(qrScreenCode: '${result['name']}')));
      //Navigator.of(context).push(MaterialPageRoute(builder: (context)=> QRScreen(qrScreenCode: qrResult)));

      // Print the retrieved data
      allUserData.forEach((user) {
        print('Name: ${user.name}, Location: ${user.location}');
      });
    });
   }on PlatformException{
     qrResult = "Fail to read QR code";
   }
  }
  final dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("QR Code Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              scanQR();
            },
                child: const Text("Scan code"))
          ],
        ),
      )
    );
  }
  /*Map<String, String> extractNameAndLocation(String inputString) {
    // Splitting using string manipulation
    List<String> nameAndLocation = inputString.split(' Location:');

    // Extracting name and location values
    String name = nameAndLocation[0].split('Name:')[1].trim();
    String location = nameAndLocation[1].trim();

    // Creating a map to store the results
    Map<String, String> result = {
      'name': name,
      'location': location,
    };

    // Returning the map
    return result;
  }*/
/* Map<String, String> extractNameAndLocation(String inputString) {
    // Splitting using string manipulation
    List<String> nameAndLocation = inputString.split(' Location:');

    // Extracting name and location values
    Info userData = Info(name: "", location: "");
    userData.name = nameAndLocation[0].split('Name:')[1].trim();
    userData.location = nameAndLocation[1].trim();

    // Creating a map to store the results
    Map<String, String> result = {
      'name': userData.name,
      'location': userData.location,
    };

    // Returning the map
    return result;
  }*/
  Map<String, String> extractNameAndLocation(String inputString) {
    RegExp regExp = RegExp(r"Name: (.+) Location: (.+)");
    Match match = regExp.firstMatch(inputString) as Match;
    User user = User(name: "", location: "");

    Info userData = Info(name: "", location: "");
    if (match != null) {
      userData.name = match.group(1)!.trim();
      userData.location = match.group(2)!.trim();
      user.name = match.group(1)!.trim();
      user.location = match.group(2)!.trim();
      dbHelper.insertUser(user.name,user.location);
       print(user.name);
       print(user.location);

      LocalStorage.saveUserDataLocally(userData);
      //return {'name': userData.name, 'location': userData.location};
      return {'name': user.name, 'location': user.location};
    }

    // Return an empty map if no match is found
    return {};
  }

}
