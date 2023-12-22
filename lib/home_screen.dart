import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String qrResult = "Scanned Data will appear here";
  Future<void> scanQR()async{
    try{
      final qrCode = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
      if(!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
      });
    }on PlatformException{
      qrResult = "Fail to read QR code";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Column(
        children: [
          Text('Welcome $qrResult'),
          ElevatedButton(
              onPressed: (){},
              child: const Text("Registration"))
        ],
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    scanQR();
    super.initState();
  }
}
