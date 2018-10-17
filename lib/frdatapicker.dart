import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef DataSourceCallback = List<String> Function(int columnIndex);

class FrDataPicker extends StatefulWidget {
  FrDataPicker(
      {Key key,
      @required this.itemCount,
      @required this.dataSourceCallback,
      this.itemTitles,
      this.okBtnTitle,
      this.cancelBtnTitle,
      this.okBtnClicked,
      this.cancelBtnClicked,
      @required this.onSelectedItemChanged,
      this.hideToolBar})
      : assert(dataSourceCallback != null),
        assert(onSelectedItemChanged != null),
        super(key: key);

  int itemCount = 0;
  List<String> itemTitles = [];

  String cancelBtnTitle = '';
  String okBtnTitle = '';

  bool hideToolBar;

  DataSourceCallback dataSourceCallback;
  Function(int index, int columnIndex,
      Function(List<int> columnIndexs) needReloadColumns) onSelectedItemChanged;

  VoidCallback cancelBtnClicked;
  VoidCallback okBtnClicked;

  final double _cellHeight = 36.0;
  final double _fontSize = 20.0;
  final double _titleHeight = 36.0;
  final double _toolBarHeight = 36.0;

  @override
  State<StatefulWidget> createState() {
    return FrDataPickerState();
  }
}

class FrDataPickerState extends State<FrDataPicker> {
  List<Picker> pickers = List<Picker>();

  @override
  void initState() {
    super.initState();
    widget.itemTitles = widget.itemTitles ?? [];
  }

  needReloadColumns(List<int> columnIndexs) {
    print("needReloadColumns");
    columnIndexs.forEach((int columnIndex) {
      try{
        Picker picker = pickers[columnIndex];
        picker.reload();
      }catch(_){
      };
    });
  }

  _pickerSelectedChanged(int index, int columnIndex) {
    widget.onSelectedItemChanged(index, columnIndex, needReloadColumns);
  }

  _getPickerContainer(double _width, int columnIndex) {
    Picker picker = Picker(
      width: _width,
      cellHeight: widget._cellHeight,
      fontSize: widget._fontSize,
      columnIndex: columnIndex,
      selectedChanged: _pickerSelectedChanged,
      dataSourceCallback: widget.dataSourceCallback,
    );
    pickers.add(picker);
    return picker;
  }

  _getToolBar() {
    if(widget.hideToolBar==true){
      return Container();
    }
    return Container(
      height: widget._toolBarHeight,
      color: Colors.grey[300],
      child: Row(
        children: <Widget>[
          Container(
            width: 5.0,
          ),
          RaisedButton(
            onPressed: widget.cancelBtnClicked,
            child: Text(widget.cancelBtnTitle ?? "cancel"),
          ),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: widget.okBtnClicked,
            child: Text(widget.okBtnTitle ?? 'OK'),
          ),
          Container(
            width: 5.0,
          ),
        ],
      ),
    );
  }

  _getTitles(double _width) {
    return Container(
      height: widget.itemTitles.length == 0 ? 0.0 : widget._titleHeight,
      child: Row(
        children: List.generate(widget.itemTitles.length, (int index) {
          return Container(
            color: Colors.white,
            width: _width,
            height: widget._titleHeight,
            child: Center(
              child: Text(
                widget.itemTitles[index],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: widget._fontSize),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var itemWidth = constraints.constrainWidth() / widget.itemCount ?? 1;
      return Column(
        children: <Widget>[
          _getToolBar(),
          _getTitles(itemWidth),
          Expanded(
              child: Row(
            children: List<Widget>.generate(widget.itemCount ?? 1, (int index) {
              return _getPickerContainer(itemWidth, index);
            }),
          )),
        ],
      );
    });
  }
}

class Picker extends StatefulWidget {
  Picker(
      {Key key,
      @required this.width,
      @required this.cellHeight,
      @required this.fontSize,
      @required this.columnIndex,
      @required this.selectedChanged,
      @required this.dataSourceCallback})
      : assert(dataSourceCallback != null),
        super(key: key);

  var width;
  var cellHeight;
  var fontSize;
  var columnIndex;
  Function(int index, int columnIndex) selectedChanged;
  DataSourceCallback dataSourceCallback;

  PickerState pickerState;

  reload() {
    pickerState.setState((){});
  }

  @override
  State<StatefulWidget> createState() {
    return pickerState = PickerState();
  }
}

class PickerState extends State<Picker> {
  FixedExtentScrollController fixedExtentScrollController =
      FixedExtentScrollController();

  Timer timer;
  
  @override
  void dispose() {
    fixedExtentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> data = widget.dataSourceCallback(widget.columnIndex);

    return Container(
      width: widget.width,
      child: CupertinoPicker(
          scrollController: fixedExtentScrollController,
          itemExtent: widget.cellHeight,
          backgroundColor: CupertinoColors.white,
          onSelectedItemChanged: (int index) {
            if (timer == null) {
              timer = Timer(Duration(milliseconds: 500), () {
                widget.selectedChanged(index, widget.columnIndex);
              });
            } else {
              timer.cancel();
              timer = Timer(Duration(milliseconds: 500), () {
                widget.selectedChanged(index, widget.columnIndex);
              });
            }
          },
          children: List<Widget>.generate(data.length, (int index) {
        return Center(
          child: Text(
            data[index] ?? "",
            style: TextStyle(fontSize: widget.fontSize),
          ),
        );
      }),
    ),
    );
  }
}
