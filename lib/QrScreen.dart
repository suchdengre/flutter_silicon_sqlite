import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/widgets.dart' as FlutterWidgets;

import 'package:excel/excel.dart';
import 'package:flutter_silicon_app/sqlite/DatabaseHelper.dart';
import 'package:flutter_silicon_app/sqlite/User.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_silicon_app/model.dart';
import 'package:flutter_silicon_app/scan_qr_code.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';


import 'FileStorage.dart';
import 'LocalStorage.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key, required this.qrScreenCode}) : super(key: key);
  // Step 2 <-- SEE HERE
  final String qrScreenCode;

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  late String _localPath;
  late bool _permissionReady;
  late TargetPlatform? platform;
  var _openResult = 'Unknown';

  String displayedText = "Dynamic";
  TextEditingController textEditingController = TextEditingController();
  int counter = 0;
  int userCount = 0;
  int count = 0;
  bool isText1Visible = true;
  final dbHelper = DatabaseHelper();
  /*Future<void> incrementCounter() {
    fetchData().then((result) {
      // Synchronously update the state inside setState()
      setState(() async {
        counter = await LocalStorage.countUserDataLocally();
        print('Total Users: $counter');
      });
    });

  }*/
  void incrementCounter() async{
    userCount = (await (dbHelper.countUsers()))!;
  setState(() {
    print('Total Users: $userCount');
  });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: FlutterWidgets.Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterWidgets.Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome ${widget.qrScreenCode}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),),
                SizedBox(height: 30,),
                ElevatedButton(
                    onPressed: () async {


                        List<User> users = await dbHelper.getUsers();
                        users.forEach((user) {
                          print('ID: ${user.id}, Name: ${user.name}, Location: ${user.location}');
                        });

                      // Retrieve all user data
                      List<Info> allUserData = await LocalStorage.getAllUserDataLocally();

                      // Print the retrieved data
                      allUserData.forEach((user) {
                        print('Name: ${user.name}, Location: ${user.location}');
                      });
                     // count = await LocalStorage.countUserDataLocally();
                     // if(userCount !=0) {
                       /* fetchData().then((result) async {
                          // Perform asynchronous work here

                          counter = await LocalStorage.countUserDataLocally();

                          // Update the state inside setState
                          setState(() {
                            // Update state with the result of the asynchronous operation
                            counter = allUserData.length;
                            isText1Visible = !isText1Visible;
                            print('Total Users: $counter');
                          });
                        });*/
                        /*userCount = (await dbHelper.countUsers())!;
                        print('Total Users: $userCount');*/
                        incrementCounter();
                        //  print('Total Users: $count');
                     // }else {
                        counter = allUserData.length;
                        print("allUser $counter");
                     // }

                    },
                    child: const Text("Registration")),
                SizedBox(height: 20,),
                Center(
                  child: FlutterWidgets.Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          Text("Total   Users:  $userCount"),
                    ],
                  ),
                ),SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () async {
                      List<Info> allUserData = await LocalStorage.getAllUserDataLocally();
                      List<String> header = [];
                      header.add("Name");
                      header.add("Location");
                      // Get the Downloads directory
                      await exportToCSV2(allUserData);
                      //exportToExcel();
                      createExcel();
                     // writeCsvFile(allUserData);
                       // open file
                      /*_permissionReady = await _checkPermission();
                      if (_permissionReady) {
                        await _prepareSaveDir();
                        print("Downloading");
                        try {
                          await Dio().download("https://people.sc.fsu.edu/~jburkardt/data/csv/addresses.csv",
                              _localPath +"/" + "codeplayon.csv");
                          print("Download Completed.");
                          openFile();
                        } catch (e) {
                          print("Download Failed.\n\n" + e.toString());
                        }
                      }*/
                      // Additional print statement to output the path
                      print('Path to CSV file: ${await getCSVFilePath()}');
                    },
                    child:const Text("Export"))
              ],
            ),
          ],
        ),
      ),

    );
  }
  Future<void> exportToCSV(List<Info> data, String filePath) async {
    List<List<dynamic>> rows = [];

    // Add header row
    rows.add(['Name', 'Location']);

    // Add data rows
    rows.addAll(data.map((user) => [user.name, user.location]));

    String csv = const ListToCsvConverter().convert(rows);

    // Save CSV to a file
    File file = File(filePath);
    await file.writeAsString(csv);

    print('CSV file exported successfully: $filePath');
  }

  Future<void> copyToDownloads(String sourcePath, String fileName) async {

      Directory? externalDirectory = await getExternalStorageDirectory();
      String destinationPath = '${externalDirectory?.path}/Download/$fileName';

      File sourceFile = File(sourcePath);
      File destinationFile = File(destinationPath);

      try {
        await destinationFile.create(recursive: true);
        await sourceFile.copy(destinationPath);
        print('File copied to Downloads: $destinationPath');
      } catch (e) {
        print('Error copying file: $e');
      }
    }
  Future<void> exportToCSV1(List<Info> data) async {
    List<List<dynamic>> rows = [];

    // Add header row
    rows.add(['Name', 'Location']);

    // Add data rows
    rows.addAll(data.map((user) => [user.name, user.location]));

    String csv = const ListToCsvConverter().convert(rows);

    // Get the documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Create a subdirectory named "Download" if it doesn't exist
    Directory downloadDirectory = Directory('${documentsDirectory.path}/Download');
    if (!downloadDirectory.existsSync()) {
      downloadDirectory.createSync();
    }

    // Create a file named "user_data.csv" in the "Download" subdirectory
    File file = File('${downloadDirectory.path}/user_data.csv');

    // Save CSV to the file
    await file.writeAsString(csv);

    print('CSV file exported successfully: ${file.path}');
  }
  Future<String> getCSVFilePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    Directory downloadDirectory = Directory('${documentsDirectory.path}/Download');
    return '${downloadDirectory.path}/user_data.csv';
  }
  Future<void> exportToCSV2(List<Info> data) async {
    List<List<dynamic>> rows = [];

    // Add header row
    rows.add(['Name', 'Location']);

    // Add data rows
    rows.addAll(data.map((user) => [user.name, user.location]));

    String csv = const ListToCsvConverter().convert(rows);

    // Get the downloads directory
    Directory? downloadsDirectory = await getDownloadsDirectory();

    // Create a file named "user_data.csv" in the downloads directory
    File file = File('${downloadsDirectory?.path}/user_data.csv');

    // Save CSV to the file
    await file.writeAsString(csv);

    print('CSV file exported successfully: ${file.path}');
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
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

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;

    print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (platform == TargetPlatform.android) {
      return "/sdcard/download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return directory.path + Platform.pathSeparator + 'Download';
    }
  }

  /*Future<void> openFile() async {
    final filePath = _localPath+"/" + "codeplayon.csv";
    final result = await OpenFile.open(filePath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }*/
@override
  void initState() {
    // TODO: implement initState
  if (Platform.isAndroid) {
    platform = TargetPlatform.android;
  } else {
    platform = TargetPlatform.iOS;
  }
    super.initState();
  }
  static const int rows = 10000;
  Duration? executionTime;

  void exportToExcel() {
    final stopwatch = Stopwatch()..start();

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    for (var row = 0; row < rows; row++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = 'FLUTTER';

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = 'is';

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = "Google's";

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = "UI";

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = "toolkit";
    }

    excel.save(fileName: "MyData.xlsx");
    setState(() {
      executionTime = stopwatch.elapsed;
    });
  }


  Future<void> createExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    List<Info> allUserData = await LocalStorage.getAllUserDataLocally();

    // Print the retrieved data
   /* allUserData.forEach((user) {
      print('Name: ${user.name}, Location: ${user.location}');
      sheet.getRangeByName('A1').setText(user.name);
    });*/

    for (var i = 0; i < allUserData.length; i++) {
      final item = allUserData[i];
      sheet.getRangeByIndex(i + 2, 1).setText(item.name);
      sheet.getRangeByIndex(i + 2, 2).setText(item.location);
    }

    // sheet.getRangeByName('A1').setText('Hello World!');
    final List<int> bytes = workbook.saveAsStream();


    // Convert List<int> to Uint8List
    Uint8List uint8List = Uint8List.fromList(bytes);
    FileStorage.writeCounter(uint8List, "userData.xlsx", context);
    workbook.dispose();


   /* if (kIsWeb) {
      AnchorElement(
          href:
          'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
    } else {*/



    final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
      Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  void writeCsvFile(List<Info> csvData) async {
    try {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
      Platform.isWindows ? '$path\\user_data.csv' : '$path/user_data.csv';

      final File file = File(fileName);

      // Convert the list of Info objects to CSV format
      String csvContent = 'Name,Age,Location\n'; // CSV header

      csvContent += csvData.map((info) {
        return '${info.name},${info.location}';
      }).join('\n');

      // Write CSV content to the file
      await file.writeAsString(csvContent, flush: true);

      // Open the file (for demonstration purposes)
      Process.start('open', [fileName]); // For macOS
      // For other platforms, you might use OpenFile.open or another method
    } catch (error) {
      print('Error writing CSV file: $error');
      // Handle errors
    }
  }
  void updateText(String count) {
    setState(() {
      count = "uma";
    });
  }
  Future<String> fetchData() async {
    // Simulate asynchronous work
    await Future.delayed(Duration(seconds: 1));
    return 'Updated Text';
  }
}




