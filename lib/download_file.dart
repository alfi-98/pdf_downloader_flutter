import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:dio/dio.dart';
import 'package:practice_folder/api/firebase_file.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DownloadFile extends StatefulWidget {
  final FirebaseFile file;
  DownloadFile({required this.file});

  @override
  _DownloadFileState createState() => _DownloadFileState(file: file);
}

class _DownloadFileState extends State<DownloadFile> {
  final FirebaseFile file;
  _DownloadFileState({required this.file});
 

  var dio = Dio();
  @override
  void initState() {
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    final imgURL = file.url;
    final fileName = file.name;

    return Scaffold(
      appBar: AppBar(
        title: Text('Download File'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
              child: Text("Download".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
              style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green)))),
              onPressed: () async {
                String path =
                    await ExtStorage.getExternalStoragePublicDirectory(
                        ExtStorage.DIRECTORY_DOWNLOADS);
                String fullPath = "$path/$fileName";
                download2(dio, imgURL, fullPath);
              }),
        ],
      )),
    );
  }

  void getPermission() async {
    print("getPermission");
    await Permission.storage.request();
  }

  Future download2(Dio dio, String url, String savePath) async {
  
    //get pdf from link
    Response response = await dio.get(
      url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
  }

  void showDownloadProgress(received, total) {
    
    if (total != -1) {
    
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }
}
