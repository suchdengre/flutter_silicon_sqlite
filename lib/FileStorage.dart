import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FileStorage {
  static Future<void> writeCounter(Uint8List bytes, String fileName, BuildContext context) async {
    try {
      // Get the application documents directory
      Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = join(appDocumentsDirectory.path, fileName);

      // Write the bytes to the file
      await File(filePath).writeAsBytes(bytes);

      // Optionally, show a message to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved successfully: $filePath'),
        ),
      );
    } catch (error) {
      // Handle any errors that might occur during the process
      print('Error writing file: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error writing file: $error'),
        ),
      );
    }
  }
}
