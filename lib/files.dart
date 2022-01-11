import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:practice_folder/api/firebase_file.dart';
import 'package:practice_folder/api/firebase_pdf_api.dart';
import 'package:practice_folder/download_file.dart';
import 'package:practice_folder/main.dart';

class FileRepo extends StatefulWidget {
  const FileRepo({Key? key}) : super(key: key);

  @override
  _FileRepoState createState() => _FileRepoState();
}

class _FileRepoState extends State<FileRepo> {
  late Future<List<FirebaseFile>> futureFiles;
  @override
  void initState() {
    super.initState();

    futureFiles = FirebaseApi.listAll('files/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Download'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FirebaseFile>>(
        future: futureFiles,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Some error occurred!'));
              } else {
                final files = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(files.length),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          SizedBox(height: 10);
                          return buildFile(context, file);
                        },
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: Icon(Icons.home),
              color: Colors.black,
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FileRepo()),
                  );
                },
                icon: Icon(
                  Icons.dashboard,
                  color: Colors.black,
                ))
          ]),
        ),
      ),
    );
  }

  Widget buildFile(BuildContext context, FirebaseFile file) => GestureDetector(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            file.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DownloadFile(file: file),
        )),
      );

  Widget buildHeader(int length) => ListTile(
        tileColor: Colors.blue,
        leading: Container(
          width: 52,
          height: 52,
          child: Icon(
            Icons.file_copy,
            color: Colors.white,
          ),
        ),
        title: Text(
          '$length Files',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      );
}
