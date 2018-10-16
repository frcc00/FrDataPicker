import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:frdatapicker/frdatapicker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
//      platformVersion = await frdatapicker.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  var column1Data = ['A1','A2','A3','A4'];
  var column2Data = ['B1','B2','B3','B4'];

  var columnChangeData = ['C1','C2','C3','C4','C5'];

  List<String> dataSourceCallback(int i){
    if(i==1){
      return column2Data;
    }
    return column1Data;
  }

  onSelectedItemChanged(int index, int columnIndex, Function(List<int> columnIndexs) needReloadColumns){
    column2Data = columnChangeData;
    print(index.toString() + ":" + columnIndex.toString());
    if(columnIndex==0){
      needReloadColumns([1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: Container(
            height: 300.0,
            child: FrDataPicker(itemCount: 2,itemTitles: ['A','B'],dataSourceCallback: dataSourceCallback,onSelectedItemChanged: onSelectedItemChanged,),
          ),
        ),
      ),
    );
  }
}
