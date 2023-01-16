import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';

class Printer extends StatefulWidget {
  File? imgFile;
   Printer({Key? key, required this.imgFile}) : super(key: key);

  @override
  _PrinterState createState() => _PrinterState();
}


class _PrinterState extends State<Printer> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();

    printerManager.scanResults.listen((devices) async {

      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];
    // Print image
    final ui.Image image = await decodeImageFromList(widget.imgFile!.readAsBytesSync());
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final Image? imageq = decodeImage(pngBytes);
    bytes += ticket.image(imageq!);
    ticket.feed(2);
    ticket.cut();
    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    final PosPrintResult res =
    await printerManager.printTicket((await demoReceipt(paper, profile)));
    showToast(
      res.msg,
      position: ToastPosition.bottom,
      backgroundColor: res.msg.contains('Error') ? Colors.red : Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('printer'),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.print),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address!),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
              onPressed: _startScanDevices,
              child: const Icon(Icons.search),
            );
          }
        },
      ),
    );
  }
}