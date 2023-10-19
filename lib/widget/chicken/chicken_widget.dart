import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/buy_manager.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/listener/main_listener.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_select_reqeust_dto.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_keys.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/chicken/prod/chicken_prod_insert_dialog.dart';
import 'package:slf_front/widget/chicken/sell/add_dialog.dart';

class ChickenWidget extends StatefulWidget {
  final String title;
  final String parts;
  MainListener? listener;
  List? listenerParam;

  ChickenWidget({Key? key,
    required this.title,
    required this.parts,
    this.listener,
    this.listenerParam})
      : super(key: key);

  @override
  State<ChickenWidget> createState() => _ChickenWidgetState();
}

class _ChickenWidgetState extends State<ChickenWidget> {
  int createTotal = 0;
  int sellTotal = 0;
  bool isOpen = true;
  bool allRead = false;

  List sellList = [];
  List<ChickenProdRespDto> prodList = [];

  List<String> prodColumn = ["생산처", "생산량", "생산가격", "소계", "생산종류"];
  List<String> sellColumn = ["판매처", "출고량", "단가", "계"];

  late TableManager _chickenManager;
  late DateManager _dateManager;
  late BuyManager _buyManager;

  @override
  Widget build(BuildContext context) {
    _chickenManager = Provider.of<TableManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: true);
    _buyManager = Provider.of<BuyManager>(context, listen: true);

    return FutureBuilder(
        future: updateNewData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Column(
            children: [
              _Top(
                onPressed: onTopPressed,
                title: widget.title,
                mainKey: widget.parts,
                createList: prodList,
                sellList: sellList,
                chickenManager: _chickenManager,
              ),
              if (isOpen) body()
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateNewData() async {
    var result = await getAPIManager().GET(
        APIManager.URI_CHICKEN_PRODUCTION, ChickenProdSelectRequestDto(widget.parts, _dateManager.selectTime).toJson()) as List;

    prodList = result.map((e) => ChickenProdRespDto.byResult(e)).toList();

    _chickenManager.updateView();

    return;
  }

  void onTopPressed() async {
    isOpen = !isOpen;

    onSetState();
  }

  void onCreateAddPressed() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChickenProdInsertDialog(parts: widget.parts, createdOn: _dateManager.selectTime);
        });

    onSetState();
  }

  void onSellAddPressed() async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChickenDialog(
              labels: sellColumn.sublist(0, 3),
              time: _dateManager.selectTime,
              stock: _chickenManager.stockMap[widget.parts]);
        });

    if (result != null) {
      await getAPIManager().PUT(APIManager.URI_CHICKEN_PRODUCTION,
          ChickenParam.addItemParam(widget.parts, ChickenParts.SELL));

      if (widget.listenerParam != null) {
        List eventList =
        widget.listenerParam!.map((e) => e[ParamKeys.EVENT]).toList();


        widget.listener!.updateView();
      }
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
              column: prodColumn,
              mainKey: widget.parts,
              createList: prodList,
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
              mainKey: widget.parts,
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

  _SellTable({Key? key,
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
        .map((e) =>
        DataColumn(
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
              APIManager.URI_CHICKEN_PRODUCTION, ChickenParam.deleteItemParam(e["id"]));

          onSetState();
        },
        cells: [
          DataCell(Text(e["name"])),
          DataCell(Text((e["count"] as double).toStringAsFixed(1))),
          DataCell(Text(e["price"].toString())),
          DataCell(Text(e["total"].toString()))
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

  _CreateTable({Key? key,
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
        .map((e) =>
        DataColumn(
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
              APIManager.URI_CHICKEN_PRODUCTION, ChickenParam.deleteItemParam(e["id"]));

          onSetState();
        },
        cells: [
          DataCell(Text(e["name"])),
          DataCell(Text(e["count"].toString())),
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
  final TableManager chickenManager;

  _Top({Key? key,
    required this.createList,
    required this.sellList,
    required this.onPressed,
    required this.title,
    required this.mainKey,
    required this.chickenManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String stock = _chickenManager.getStockValue(mainKey).toString();
    // String price = _chickenManager.getPriceValue(mainKey).toString();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SelectionArea(
                        child: Text(
                          title,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28.0,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        valueText(
                            "생산량",
                            '${chickenManager.tableStockMap[mainKey]}',
                            "kg"),
                        VerticalDivider(thickness: 1),
                        valueText(
                            "재고",
                            '${getStock()}',
                            "kg"),
                        VerticalDivider(thickness: 1),
                        valueText(
                            "판매 금액",
                            '${chickenManager.priceMap[mainKey]}',
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

  double getStock() {
    return chickenManager.stockMap[mainKey] ?? 0.0;
  }

  Widget valueText(String kind, String value, String unit) {
    String text = "$kind : $value $unit";

    return SelectionArea(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w700),
        ));
  }
}
