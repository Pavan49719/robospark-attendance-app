import 'package:flutter/material.dart';

class AttList extends StatefulWidget {
  String date;
  List presentList;
  AttList({required this.date, required this.presentList});

  @override
  State<AttList> createState() => _AttListState();
}

class _AttListState extends State<AttList> {
  @override
  void initState() {
    print("DATA IS attlist: ${widget.date}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.date),
          Text("Total:${widget.presentList.length}")
        ],
      )),
      body: ListView.builder(
          itemCount: widget.presentList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Text("(${(index + 1).toString()}) "),
              title: Text(widget.presentList[index]),
            );
          }),
    );
  }
}
