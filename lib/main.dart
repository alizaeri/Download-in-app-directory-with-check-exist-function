import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Newdownloader(),
    );
  }
}

class Newdownloader extends StatefulWidget {
  const Newdownloader({Key? key}) : super(key: key);

  @override
  State<Newdownloader> createState() => _Newdownloader();
}

class _Newdownloader extends State<Newdownloader> {
  bool downloading = false;
  String progressString = '';
  String downloadedImagePath = '';
  final audioPlayer = AudioPlayer();

  Future<bool> getStoragePermission() async {
    return await Permission.storage.request().isGranted;
  }

  Future<String> getDownloadFolderPath() async {
    String appDocPath = '';
    // return await ExternalPath.getExternalStoragePublicDirectory(
    //     ExternalPath.DIRECTORY_DOWNLOADS);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    print(' path in hast 555555555555555555 $appDocPath');
    return appDocPath = appDocDir.path;
  }

  Future downloadFile(String downloadDirectory) async {
    Dio dio = Dio();
    var downloadVideoPath = '$downloadDirectory/file_example_MP3_5MG.mp3';
    try {
      await dio.download(
        'https://file-examples.com/storage/feadec8f346400f84963e24/2017/11/file_example_MP3_5MG.mp3',
        downloadVideoPath,
        onReceiveProgress: (count, total) {
          print('REC: $count, total: $total');
          setState(() {
            downloading = true;
            progressString = ((count / total) * 100).toStringAsFixed(0) + '%';
          });
        },
      );
    } catch (e) {
      print(e);
    }
    await Future.delayed(const Duration(seconds: 3));
    return downloadVideoPath;
  }

  @override
  void initState() {
    super.initState();
  }

  Future setAudio() async {
    // final player = AudioCache(prefix: '$downloadedImagePath/');
    // final url = await player.load('audio.mp3');
    await audioPlayer
        .setSourceDeviceFile('$downloadedImagePath/file_example_MP3_5MG.mp3');
    // audioPlayer.play();
  }

  Future<void> doDownloadFile() async {
    if (await getStoragePermission()) {
      String downloadDirectory = await getDownloadFolderPath();
      await downloadFile(downloadDirectory).then((imagePath) {
        displayImage(imagePath);
      });
    }
  }

  void displayImage(String downloadDirectory) {
    setState(() {
      downloading = false;
      progressString = 'completed';
      downloadedImagePath = downloadDirectory;
      print(downloadDirectory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Center(
          //   child: ElevatedButton(
          //       onPressed: () {
          //         print('download failed on press');
          //         // openFile(
          //         //     url:
          //         //         'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_2mb.mp4',
          //         //     fileName: 'big_buck_bunny_720p_2mb.mp4');
          //       },
          //       child: Text(
          //         "Download ",
          //         style: TextStyle(color: Colors.white, fontSize: 25),
          //       )),
          // ),
          downloading
              ? Center(
                  child: SizedBox(
                    height: 120,
                    width: 200,
                    child: Card(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'downloading File: $progressString',
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    downloadedImagePath == ''
                        ? Container()
                        : IconButton(
                            onPressed: () async {
                              bool exist =
                                  await File(downloadedImagePath).exists();

                              audioPlayer.play(
                                  DeviceFileSource('$downloadedImagePath'));
                              print(' 9999999999999999999999999999 $exist');
                              // audioPlayer.resume();
                              // setAudio().then((value) => audioPlayer.resume());
                            },
                            icon: Icon(Icons.play_arrow),
                            iconSize: 50,
                          ),
                    // : Image.file(File(downloadedImagePath)),
                    const SizedBox(
                      height: 100,
                    ),
                    downloadedImagePath == ''
                        ? MaterialButton(
                            height: 50,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () => doDownloadFile(),
                            color: Colors.green,
                            child: const Text(
                              'download',
                              style: TextStyle(color: Colors.white),
                            ))
                        : Container()
                  ],
                )
        ],
      ),
    );
  }

  // Future openFile({required String url, String? fileName}) async {
  //   final file = await downloadFile(url, fileName!);
  //   if (file == null) return;
  //   print('Path: ${file.path}');
  //   OpenFile.open(file.path);
  // }

  // Future<File?> downloadFile(String url, String name) async {
  //   print('download failed start download func');

  //   final appStorage = await getApplicationDocumentsDirectory();
  //   final file = File('${appStorage.path}/$name');
  //   try {
  //     print('download failed in try');
  //     final response = await Dio().get(url,
  //         options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           receiveTimeout: const Duration(seconds: 5),
  //         ));
  //     final raf = file.openSync(mode: FileMode.write);
  //     raf.writeByteSync(response.data);
  //     await raf.close();
  //     return file;
  //   } catch (e) {
  //     print('download failed in catch $e');
  //     return null;
  //   }
  // }
}
