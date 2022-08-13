import 'package:attendance/presentlist.dart';
import 'package:attendance/readdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DomainAttendance extends StatefulWidget {
  String domain;
  DomainAttendance({required this.domain});

  @override
  State<DomainAttendance> createState() => _DomainAttendanceState();
}

class _DomainAttendanceState extends State<DomainAttendance> {
  List<DocumentSnapshot>? documents;
  int? dateCount;

  readData() async {
    final _firestore = FirebaseFirestore.instance;
    final QuerySnapshot result =
        await _firestore.collection(widget.domain).get();
    setState(() {
      documents = result.docs;
      dateCount = documents?.length;
    });
    print("DATA IS: ${documents?.length}");
    print("DATA IS: ${documents![1]['date']}");
  }

  @override
  void initState() {
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.domain)),
      body: dateCount != null
          ? ListView.builder(
              itemCount: dateCount,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.date_range_rounded),
                  title: Text(documents?[index]['date']),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AttList(
                              presentList: documents?[index]['grn'],
                              date: documents?[index]['date'],
                            )));
                  },
                );
              })
          : Center(child: CircularProgressIndicator()),
    );
  }
}
