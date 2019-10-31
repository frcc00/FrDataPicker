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
class AddressPicker {
  ///省
  static var _sArr = [];
  ///市
  static var _cArr = [];
  ///区
  static var _qArr = [];

  static showAddressPicker(context) async{
    Completer completer = Completer();
    _show(completer,context);
    return completer.future;
  }

  static _show(Completer completer,context) async{
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
          var sData = {};
          var cData = {};
          var qData = {};
          try{
            sData = _sArr[si];
          }catch(_){}
          try{
            cData = _cArr[ci];
          }catch(_){}
          try{
            qData = _qArr[qi];
          }catch(_){}
          completer.complete(AddressPickerResult(
            provinceId: (sData['id']??'').toString(),
            provinceName: sData['name']??'',
            cityId: (cData['id']??"").toString(),
            cityName: cData['name']??"",
            areaId: (qData['id']??"").toString(),
            areaName: qData['name']??"",
          ));
        },
      );
    });
  }
}

class AddressPickerResult {
  /// provinceId
  String provinceId;

  /// cityId
  String cityId;

  /// areaId
  String areaId;

  /// provinceName
  String provinceName;

  /// cityName
  String cityName;

  /// areaName
  String areaName;

  AddressPickerResult(
      {this.provinceId,
        this.cityId,
        this.areaId,
        this.provinceName,
        this.cityName,
        this.areaName});

  /// string json
  @override
  String toString() {
    Map<String, dynamic> obj = {
      'provinceName': provinceName,
      'provinceId': provinceId,
      'cityName': cityName,
      'cityId': cityId,
      'areaName': areaName,
      'areaId': areaId
    };
    obj.removeWhere((key, value) => value == null);

    return json.encode(obj);
  }
}
```
