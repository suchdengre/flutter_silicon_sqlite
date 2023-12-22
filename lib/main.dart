import 'package:flutter/material.dart';
import 'package:flutter_silicon_app/scan_qr_code.dart';


void main()async {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "QR code Scanner",
      debugShowCheckedModeBanner: false,
      home:ScanQRCode(),
    );
  }
}
