import 'dart:io';

import 'package:attendance/checkcount.dart';
import 'package:attendance/domain_att.dart';
import 'package:attendance/qrcode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

enum SelectDomain { Prog, Mech, Elex }

class RadioButtons extends StatefulWidget {
  const RadioButtons({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
  SelectDomain? _domain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "RoboSpark Attendance App",
          style: TextStyle(overflow: TextOverflow.clip),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Prog',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    leading: Radio(
                      value: SelectDomain.Prog,
                      groupValue: _domain,
                      onChanged: (SelectDomain? value) {
                        setState(() {
                          _domain = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Mech',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    leading: Radio(
                      value: SelectDomain.Mech,
                      groupValue: _domain,
                      onChanged: (SelectDomain? value) {
                        setState(() {
                          _domain = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Elex',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    leading: Radio(
                      value: SelectDomain.Elex,
                      groupValue: _domain,
                      onChanged: (SelectDomain? value) {
                        setState(() {
                          _domain = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)))),
                onPressed: () {
                  if (_domain == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please select the domain!!!')));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CheckByGRN(domain: _domain!.name)),
                    );
                  }
                },
                child: const Text(
                  "Scan",
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
    );
  }
}
