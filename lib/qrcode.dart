import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class MyQRCode extends StatefulWidget {
  String domain;
  MyQRCode({required this.domain});

  @override
  State<MyQRCode> createState() => _MyQRCodeState();
}

class _MyQRCodeState extends State<MyQRCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? formatter;
  bool success = false;

  @override
  void initState() {
    controller?.resumeCamera();
    print("SELECT DOMAIN: ${widget.domain}");
    final now = new DateTime.now();
    formatter = DateFormat('yMd').format(now);
    formatter = formatter?.replaceAll('/', '-');
    print("DATEFORMATTER:$formatter");
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            controller?.toggleFlash();
                          },
                          child: Icon(Icons.flash_on)),
                      ElevatedButton(
                          onPressed: () {
                            controller?.resumeCamera();
                            setState(() {
                              success = false;
                              result = null;
                            });
                          },
                          child: Text("New"))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: (result != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            (result!.code)!.length < 10
                                ? Row(
                                    children: [
                                      Text(
                                        'GR Number: ',
                                        style: TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        '${result!.code}',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "Invalid QR !!!",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                            (success == true)
                                ? Icon(
                                    Icons.cloud_done_rounded,
                                    color: Colors.green[700],
                                    size: 44,
                                  )
                                : CircularProgressIndicator(),
                          ],
                        )
                      : Text('Scan a code'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.stopCamera();
      });
      print("RESULT: ${result!.code}");
      if ((result!.code) != null && (result!.code)!.length < 10) {
        addToDatabase(grn: (result!.code) ?? "");
        // addToDatabase(grn: "12016879");
      }
    });
  }

  addToDatabase({required String grn}) async {
    print('ADDTODATABASE 1');
    final docUser =
        FirebaseFirestore.instance.collection(widget.domain).doc(formatter);
    final json = {
      'date': docUser.id,
      'grn': FieldValue.arrayUnion([grn]),
    };
    await docUser.set(json, SetOptions(merge: true));
    setState(() {
      success = true;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
