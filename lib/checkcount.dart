import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CheckByGRN extends StatefulWidget {
  String domain;
  CheckByGRN({required this.domain});

  @override
  State<CheckByGRN> createState() => _CheckByGRNState();
}

class _CheckByGRNState extends State<CheckByGRN> {
  List<DocumentSnapshot>? documents;
  int? dateCount;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? formatter;
  bool success = false;
  int count1 = 0;
  double? perc;

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
                                ? Column(
                                    children: [
                                      Row(
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
                                      ),
                                      Text(
                                        'Total Days: $count1  Perc:$perc %',
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
        // print("DATA IS count: ${result!.code}");
        getFromDatabase(grn: (result!.code) ?? "");
      }
    });
  }

  getFromDatabase({required String grn}) async {
    final _firestore = FirebaseFirestore.instance;
    final QuerySnapshot result =
        await _firestore.collection(widget.domain).get();
    setState(() {
      documents = result.docs;
    });
    print("DATA IS length:${documents?.length as num}");

    for (int i = 0; i < (documents?.length as num); i++) {
      List l = documents![i]['grn'];
      print("DATA IS count list $l");
      for (int j = 0; j < (l.length); j++) {
        if (l[j] == grn) {
          count1 = count1 + 1;
        }
      }
    }
    setState(() {
      count1 = count1;
      perc = count1 / (documents?.length as num) * 100;
    });
    print("DATA IS count: $count1");
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
