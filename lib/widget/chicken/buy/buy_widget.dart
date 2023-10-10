import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/buy_manager.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/model/dto/request_dto.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/chicken/buy/buy_add_dialog.dart';
import 'package:slf_front/widget/chicken/buy/buy_work_dialog.dart';
import 'package:slf_front/widget/chicken/sell/add_dialog.dart';

class BuyWidget extends StatefulWidget {
  const BuyWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<BuyWidget> createState() => _BuyWidgetState();
}

class _BuyWidgetState extends State<BuyWidget> {
  final String title = "구매";
  final String mainKey = ChickenParts.BUY;

  int createTotal = 0;
  int sellTotal = 0;
  bool isOpen = true;
  bool allRead = false;

  List sellList = [];
  List createList = [];

  List<String> createColumn = ["구매 호수", "수량", "단가", "소계"];
  List<String> sellColumn = ["생산처", "작업량", "작업비"];

  late ChickenManager _chickenManager;
  late DateManager _dateManager;
  late PriceManager _priceManager;

  @override
  Widget build(BuildContext context) {
    _chickenManager = Provider.of<ChickenManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: true);
    _priceManager = Provider.of<PriceManager>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        Container(
          color: Colors.grey[300],
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        buyTableWidget()
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buyTableWidget() {
    return FutureBuilder(
        future: updateNewData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Column(
            children: [
              _Top(
                onPressed: onTopPressed,
                title: title,
                mainKey: mainKey,
                createList: createList,
                sellList: sellList,
              ),
              if (isOpen) body()
            ],
          );
        });
  }

  Future<void> updateNewData() async {
    createList = await getAPIManager().POST(
        APIManager.URI_CHICKEN,
        ChickenParam.getInfoParam(
            mainKey, ChickenParts.BUY, _dateManager.selectTime));

    sellList = await getAPIManager().POST(
        APIManager.URI_CHICKEN,
        ChickenParam.getInfoParam(
            mainKey, ChickenParts.WORK, _dateManager.selectTime));

    _chickenManager.totalMap[ChickenParts.BUY] = getTotalSum(createList, "total");
    _chickenManager.totalMap[ChickenParts.WORK] = getTotalSum(sellList, "total");
    _chickenManager.tableStockMap[ChickenParts.BUY] = getTotalSum(createList, "count").toInt();
    _chickenManager.tableStockMap[ChickenParts.WORK] = getTotalSum(sellList, "count").toInt();

    _chickenManager.tableStockMap[ChickenParts.BUY_KG] = createList.fold(0.0, (sum, element) {
      String name = getHo(element["name"]);
      double kg = element["count"] * (double.parse(name) / 10);

      return sum + kg;
    });


    for (var element in createList) {
      String name = getHo(element["name"]);
      if(name == null) {
        continue;
      }

      _chickenManager.stockMap[name] = 0;
    }

    for (var element in createList) {
      String name = getHo(element["name"]);
      if(name == null) {
        continue;
      }

      if(_chickenManager.stockMap[name] == null) {
        _chickenManager.stockMap[name] = 0;
      }

      _chickenManager.stockMap[name] += element["count"];
    }

    _chickenManager.tableStockMap[ChickenParts.SELL_KG] = sellList.fold(0.0, (sum, element) {
      String name = getHo(element["name"]);

      double kg = element["count"] * (double.parse(name) / 10);

      return sum + kg;
    });

    for (var element in sellList) {
      String name = getHo(element["name"]);
      if(name == null) {
        continue;
      }

      if(_chickenManager.stockMap[name] == null) {
        _chickenManager.stockMap[name] = 0;
      }

      _chickenManager.stockMap[name] -= element["count"];
    }

    _chickenManager.stockMap[ChickenParts.CHICKEN] = _chickenManager.tableStockMap[ChickenParts.BUY] - _chickenManager.tableStockMap[ChickenParts.WORK];
    _chickenManager.totalMap[ChickenManager.TOTAL_BUY] = _chickenManager.totalMap[ChickenParts.BUY] + _chickenManager.totalMap[ChickenParts.WORK];

    _chickenManager.updateView();

    return;
  }
  double getTotalSum(List list, String parameterName) {
    return  list.fold(0, (sum, element) => sum + (element[parameterName] as double));
  }

  String getHo(String name) {
    int pos = name.lastIndexOf("/ ");
    name = name.substring(pos, name.length);
    name = name.replaceAll("/ ", "");
    name = name.replaceAll("호", "");

    return name;
  }


  void onTopPressed() async {
    isOpen = !isOpen;

    onSetState();
  }

  void onCreateAddPressed() async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChickenBuyDialog(
              time: _dateManager.selectTime, priceManager: _priceManager);
        });

    if (result != null) {
      await getAPIManager().PUT(APIManager.URI_CHICKEN,
          ChickenParam.addItemParam(mainKey, ChickenParts.BUY, result));
    }

    onSetState();
  }

  void onSellAddPressed() async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChickenWorkDialog(time: _dateManager.selectTime,  chickenManager: _chickenManager);
        });


    if (result != null) {
      (result as RequestDto).clearTotal();

      await getAPIManager().PUT(APIManager.URI_CHICKEN,
          ChickenParam.addItemParam(mainKey, ChickenParts.WORK, result));
    }

    onSetState();
  }

  void onSetState() {
    setState(() {});
  }

  Widget body() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _CreateTable(
              onCreateAddPressed: onCreateAddPressed,
              column: createColumn,
              mainKey: mainKey,
              createList: createList,
              onSetState: onSetState,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _SellTable(
              onSellAddPressed: onSellAddPressed,
              column: sellColumn,
              mainKey: mainKey,
              sellList: sellList,
              onSetState: onSetState,
            ),
          ),
        )
      ],
    );
  }

  APIManager getAPIManager() {
    return GetIt.instance.get<APIManager>();
  }
}

class _SellTable extends StatelessWidget {
  final List<String> column;
  final List sellList;
  final VoidCallback onSellAddPressed;
  final String mainKey;
  final VoidCallback onSetState;

  _SellTable(
      {Key? key,
      required this.onSellAddPressed,
      required this.column,
      required this.sellList,
      required this.mainKey,
      required this.onSetState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
            border: const TableBorder(
                top: BorderSide(width: 2),
                right: BorderSide(width: 2),
                bottom: BorderSide(width: 2),
                left: BorderSide(width: 1),
                verticalInside: BorderSide(width: 0.5)),
            columns: createColumn(),
            rows: createRows()),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [addButton()],
          ),
        )
      ],
    );
  }

  Widget addButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: CircleBorder(
              side: BorderSide(width: 1.0, color: Colors.lightGreen)),
          backgroundColor: Colors.lightGreen),
      onPressed: onSellAddPressed,
      child: Icon(Icons.add),
    );
  }

  List<DataColumn> createColumn() {
    return column
        .map((e) => DataColumn(
                label: Text(
              e,
              style: TextStyle(fontWeight: FontWeight.w700),
            )))
        .toList();
  }

  List<DataRow> createRows() {
    return sellList.map((e) {
      return DataRow(
        onLongPress: () {
          GetIt.instance.get<APIManager>().DELETE(
              APIManager.URI_CHICKEN, ChickenParam.deleteItemParam(e["id"]));

          onSetState();
        },
        cells: [
          DataCell(Text(e["name"])),
          DataCell(Text(e["count"].toString())),
          DataCell(Text(e["price"].toString())),
        ],
      );
    }).toList();
  }
}

class _CreateTable extends StatelessWidget {
  final List createList;
  final List<String> column;
  final VoidCallback onCreateAddPressed;
  final VoidCallback onSetState;
  final String mainKey;

  _CreateTable(
      {Key? key,
      required this.onCreateAddPressed,
      required this.column,
      required this.mainKey,
      required this.createList,
      required this.onSetState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
            border: const TableBorder(
                top: BorderSide(width: 2),
                right: BorderSide(width: 1),
                bottom: BorderSide(width: 2),
                left: BorderSide(width: 2),
                verticalInside: BorderSide(width: 0.5)),
            columns: createColumn(),
            rows: createRows()),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [addButton()],
          ),
        )
      ],
    );
  }

  Widget addButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: CircleBorder(
              side: BorderSide(width: 1.0, color: Colors.lightGreen)),
          backgroundColor: Colors.lightGreen),
      onPressed: onCreateAddPressed,
      child: Icon(Icons.add),
    );
  }

  List<DataColumn> createColumn() {
    return column
        .map((e) => DataColumn(
                label: Text(
              e,
              style: TextStyle(fontWeight: FontWeight.w700),
            )))
        .toList();
  }

  List<DataRow> createRows() {
    return createList.map((e) {
      return DataRow(
        onLongPress: () {
          GetIt.instance.get<APIManager>().DELETE(
              APIManager.URI_CHICKEN, ChickenParam.deleteItemParam(e["id"]));

          onSetState();
        },
        cells: [
          DataCell(Text(e["name"])),
          DataCell(Text(e["count"].toString())),
          DataCell(Text(e["price"].toString())),
          DataCell(Text(e["total"].toString())),
        ],
      );
    }).toList();
  }
}

class _Top extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final List sellList, createList;
  final String mainKey;

  _Top(
      {Key? key,
      required this.createList,
      required this.sellList,
      required this.onPressed,
      required this.title,
      required this.mainKey})
      : super(key: key);

  late BuyManager _buyManager;
  late ChickenManager _chickenManager;
  late DateManager _dateManager;

  @override
  Widget build(BuildContext context) {
    _buyManager = Provider.of<BuyManager>(context, listen: false);
    _chickenManager = Provider.of<ChickenManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded (
                  flex: 2,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen
                        ),
                        onPressed: onFinish,
                        child: const Text(
                          "적용",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        valueText(
                            "구매량",
                            '${context.watch<ChickenManager>().tableStockMap[ChickenParts.BUY]}',
                            "수"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "구매량 Kg",
                            '${context.watch<ChickenManager>().tableStockMap[ChickenParts.BUY_KG]}',
                            "Kg"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "재고",
                            '${context.watch<ChickenManager>().stockMap[ChickenParts.CHICKEN]}',
                            "수"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "구매 금액",
                            '${context.watch<ChickenManager>().totalMap[ChickenParts.BUY]}',
                            "원"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "작업 비",
                            '${context.watch<ChickenManager>().totalMap[ChickenParts.WORK]}',
                            "원"),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: OutlinedButton(
                            onPressed: onPressed,
                            child: const Icon(
                              Icons.expand_more,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onFinish() async {
    List chickenPartList = [ChickenParts.WING, ChickenParts.BREAST_SO, ChickenParts.LEG, ChickenParts.TENDER];
    List chickenMulList = [0.1, 0.22, 0.3, 0.042];

    for(int i = 0; i < chickenPartList.length; ++i) {
      await GetIt.instance.get<APIManager>().PUT(APIManager.URI_CHICKEN, ChickenParam.addItemParam(chickenPartList[i], ChickenParts.CREATE,
          RequestDto(name: "이푸드", count: _chickenManager.tableStockMap[ChickenParts.SELL_KG] * chickenMulList[i], createOn: _dateManager.selectTime)));
    }

    _buyManager.updateView();

  }

  Widget valueText(String kind, String value, String unit) {
    String text = kind + " : " + value + " " + unit;

    return SelectionArea(
        child: Text(
      text,
      style: const TextStyle(
          fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w700),
    ));
  }
}
