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

![image](https://github.com/frcc00/AriaNg-apk/blob/master/QQ20181016-123620.gif)

```
  ///省
  static var _sArr = [];
  ///市
  static var _cArr = [];
  ///区
  static var _qArr = [];
  
  if(_sArr.isEmpty){
      var data = await HttpPart1().getAllProvince();
      _sArr = data['data'];
    }
    if(_cArr.isEmpty){
      var data = await HttpPart1().getChildById(_sArr.first['id'].toString());
      _cArr = data['data'];
    }
    if(_qArr.isEmpty){
      var data = await HttpPart1().getChildById(_cArr.first['id'].toString());
      _qArr = data['data'];
    }
    
    showModalBottomSheet(context: context, builder: (c){
      return FrDataPicker(
        itemCount: 3,
        cancelBtnTitle: '取消',
        okBtnTitle: '确定',
        dataSourceCallback: (i){
          if(i==0){
            return _sArr.map<String>((v)=>v['name']).toList();
          }
          if(i==1){
            return _cArr.map<String>((v)=>v['name']).toList();
          }
          return _qArr.map<String>((v)=>v['name']).toList();
        },
        onSelectedItemChanged: (int index, int columnIndex, Function(List<int> columnIndexs) needReloadColumns)async{
          if(columnIndex == 0){
            var data = await HttpPart1().getChildById(_sArr[index]['id'].toString());
            _cArr = data['data'];
            _qArr = [];
            if(_cArr.isNotEmpty){
              var data1 = await HttpPart1().getChildById(_cArr.first['id'].toString());
              _qArr = data1['data'];
            }
            needReloadColumns([1,2]);
          }
          if(columnIndex == 1){
            var data1 = await HttpPart1().getChildById(_cArr[index]['id'].toString());
            _qArr = data1['data'];
            needReloadColumns([2]);
          }
        },
        onDone: (list){
          var si = list[0];
          var ci = list[1];
          var qi = list[2];
        },
      );
    });
```
