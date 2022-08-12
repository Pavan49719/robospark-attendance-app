import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class MyQRCode extends StatefulWidget {
  const MyQRCode({Key? key}) : super(key: key);

  @override
  State<MyQRCode> createState() => _MyQRCodeState();
}

class _MyQRCodeState extends State<MyQRCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? formatter;
  @override
  void initState() {
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
      body: Column(
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
              child: (result != null)
                  ? Text('GR Number: ${result!.code}')
                  : Text('Scan a code'),
            ),
          )
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
      if ((result!.code) != null) {
        // addToDatabase(grn: (result!.code) ?? "");
        addToDatabase(grn: "12010999");
      }
    });
  }

  addToDatabase({required String grn}) async {
    print('ADDTODATABASE 1');
    final docUser =
        FirebaseFirestore.instance.collection('students').doc('ergdbdbfdfbd');
    final json = {
      'grn': FieldValue.arrayUnion([grn]),
    };
    await docUser.set(json);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
