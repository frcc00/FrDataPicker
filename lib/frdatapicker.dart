import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef DataSourceCallback = List<String> Function(int columnIndex);

class FrDataPicker extends StatefulWidget {
  FrDataPicker(
      {Key key,
        @required this.itemCount,
        @required this.dataSourceCallback,
        this.itemTitles = const [],
        this.okBtnTitle,
        this.cancelBtnTitle,
        this.initialItems = const [],
        @required this.onSelectedItemChanged,
        @required this.onDone,
        this.hideToolBar})
      : assert(dataSourceCallback != null),
        assert(onSelectedItemChanged != null),
        super(key: key);

  int itemCount;
  List<String> itemTitles;

  String cancelBtnTitle;
  String okBtnTitle;

  bool hideToolBar;

  List<int> initialItems;

  Function(List<int> selectedList) onDone;

  DataSourceCallback dataSourceCallback;
  Function(int index, int columnIndex, Function(List<int> columnIndexs) needReloadColumns) onSelectedItemChanged;

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

  List<int> selectedList = [];

  @override
  void initState() {
    super.initState();
    if(widget.initialItems.isNotEmpty){
      selectedList = widget.initialItems;
    }else{
      selectedList = List.generate(widget.itemCount, (i)=>0);
    }
  }

  needReloadColumns(List<int> columnIndexs) {
    columnIndexs.forEach((int columnIndex) {
      try{
        Picker picker = pickers[columnIndex];
        picker.reload();
      }catch(_){
      }
    });
  }

  _pickerSelectedChanged(int index, int columnIndex) {
    selectedList[columnIndex] = index;
    widget.onSelectedItemChanged(index, columnIndex, needReloadColumns);
  }

  _getPickerContainer(double _width, int columnIndex) {
    int initialItem = 0;
    try{
      initialItem = widget.initialItems[columnIndex];
    }catch(_){}
    Picker picker = Picker(
      width: _width,
      cellHeight: widget._cellHeight,
      fontSize: widget._fontSize,
      columnIndex: columnIndex,
      selectedChanged: _pickerSelectedChanged,
      dataSourceCallback: widget.dataSourceCallback,
      initialItem: initialItem,
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
          FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(widget.cancelBtnTitle ?? "cancel"),
          ),
          Expanded(
            child: Container(),
          ),
          FlatButton(
            onPressed: (){
              widget.onDone(selectedList);
              Navigator.pop(context);
            },
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
        @required this.dataSourceCallback,
        @required this.initialItem})
      : assert(dataSourceCallback != null),
        super(key: key);

  var width;
  var cellHeight;
  var fontSize;
  var columnIndex;
  var initialItem;
  Function(int index, int columnIndex) selectedChanged;
  DataSourceCallback dataSourceCallback;

  PickerState pickerState;

  reload() {
    pickerState.reload();
  }

  @override
  State<StatefulWidget> createState() {
    return pickerState = PickerState();
  }
}

class PickerState extends State<Picker> {
  FixedExtentScrollController fixedExtentScrollController;

  Timer timer;
  int cacheIndex = 0;

  reload() {
    setState(() {
      cacheIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    cacheIndex = widget.initialItem;
  }

  @override
  void dispose() {
    fixedExtentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(fixedExtentScrollController != null){
      fixedExtentScrollController.dispose();
    }
    fixedExtentScrollController =
        FixedExtentScrollController(initialItem: cacheIndex);
    List<String> data = widget.dataSourceCallback(widget.columnIndex);
    return Container(
      width: widget.width,
      child: CupertinoPicker(
        key: GlobalKey(),
        scrollController: fixedExtentScrollController,
        itemExtent: widget.cellHeight,
        backgroundColor: CupertinoColors.white,
        onSelectedItemChanged: (int index) {
          cacheIndex = index;
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
              maxLines: 1,
            ),
          );
        }),
      ),
    );
  }
}
