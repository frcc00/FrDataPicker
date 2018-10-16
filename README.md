# frdatapicker

A new Flutter plugin.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).


```
dependencies:
    frdatapicker:
        git: https://github.com/frcc00/frdatapicker

```

```
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
```