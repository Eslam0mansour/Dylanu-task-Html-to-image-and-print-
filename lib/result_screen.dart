import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:htmlapp/editor.dart';
import 'package:htmlapp/printer.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  String result;

  ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late String html = widget.result;

  GlobalKey boundarya = GlobalKey();

  File? imgFile;

  @override
  void initState() {
    imgFile = null;
    super.initState();
  }

  Future<void> _capturePng(GlobalKey boundaryE) async {
    final RenderRepaintBoundary boundary =
        boundaryE.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = (await getApplicationDocumentsDirectory()).path;
    String date = DateFormat("yyyy_MM_dd_hh_mm_ss").format(DateTime.now());
    final File file = File('$directory/$date.screenshot.png');
    await file.writeAsBytes(pngBytes);
    setState(() {
      imgFile = File(file.path);
    });
    print(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Result'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                boundarya = GlobalKey();
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HtmlEditorExample(),
                  ));
            },
            icon: const Icon(
              Icons.add_box_outlined,
              size: 30,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Text('Convert HTML to Image'),
                onPressed: () async {
                  setState(() {});
                  await _capturePng(boundarya);
                },
              ),
              RepaintBoundary(
                key: boundarya,
                child: Html(
                  // style: {
                  //   'table': Style(
                  //     border: Border.all(color: Colors.black),
                  //     padding: const EdgeInsets.all(10),
                  //   ),
                  //   'th': Style(
                  //     border: Border.all(color: Colors.black),
                  //     padding: const EdgeInsets.all(10),
                  //   ),
                  //   'td': Style(
                  //     border: Border.all(color: Colors.black),
                  //     padding: const EdgeInsets.all(10),
                  //   ),
                  //   'tr': Style(
                  //     border: Border.all(color: Colors.black),
                  //     padding: const EdgeInsets.all(10),
                  //   ),
                  // },
                  data: html,
                ),
              ),
              const Divider(
                color: Colors.black,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              Center(
                child: Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      child: const Text('Save Image'),
                      onPressed: () async {
                        //ask for permission to save image
                        if (imgFile != null) {
                          final status = await Permission.storage.request();
                          if (status.isGranted) {
                            final externalDir =
                                await getExternalStorageDirectory();
                            final result = await ImageGallerySaver.saveImage(
                                imgFile!.readAsBytesSync(),
                                quality: 60,
                                name: " ${DateTime.now()}");
                            showToast('Image Saved Successfully',
                                position: ToastPosition.bottom,
                                backgroundColor: Colors.green,
                                radius: 10,
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 20));
                            print(result);
                          } else {
                            print('Permission deined');
                          }
                        } else {
                          showToast('Please convert HTML to Image first',
                              position: ToastPosition.bottom,
                              backgroundColor: Colors.red);
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      child: const Text('print Image'),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Printer(
                                imgFile: imgFile,
                              ),
                            ));
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Text('the image', style: Theme.of(context).textTheme.headline4),
              imgFile == null
                  ? const Center(child: Text('No Image'))
                  : Center(
                      child: Image.file(
                      File(imgFile!.path),
                      fit: BoxFit.cover,
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
