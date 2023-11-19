import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/buy_manager.dart';
import 'package:slf_front/manager/stock_manager.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_resp_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/work/work_resp_dto.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/buy/dialog/buy_add_dialog.dart';
import 'package:slf_front/widget/buy/dialog/buy_update_dialog.dart';
import 'package:slf_front/widget/date_date_update_dialog.dart';

class BuyWidget extends StatefulWidget {
  const BuyWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<BuyWidget> createState() => _BuyWidgetState();
}

class _BuyWidgetState extends State<BuyWidget> {
  int createTotal = 0;
  int sellTotal = 0;
  bool isOpen = true;
  bool allRead = false;

  List<BuyRespDto> buyList = [];

  List<String> buyColumn = ["구매처", "구매일자", "호수", "수량", "단가", "소계", "작업처 개수"];

  late TableManager _tableManager;
  late BuyManager _buyManager;
  late DateManager _dateManager;
  late StockManager _stockManager;

  @override
  Widget build(BuildContext context) {
    _tableManager = Provider.of<TableManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: true);
    _buyManager = Provider.of<BuyManager>(context, listen: true);
    _stockManager = Provider.of<StockManager>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [buyTableWidget()],
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
                createList: buyList,
                onUpdateDate: onUpdateDate,
              ),
              if (isOpen) body()
            ],
          );
        });
  }

  Future<void> updateNewData() async {
    Map param = {"createdOn": _dateManager.selectTime};
    final result = await GetIt.instance
        .get<APIManager>()
        .GET(APIManager.URI_BUY, param) as List;

    buyList = result.map((e) => BuyRespDto.byResult(e)).toList();

    final resultWork = await GetIt.instance
        .get<APIManager>()
        .GET(APIManager.URI_WORK, param) as List;
    List<WorkRespDto> workRespList =
        resultWork.map((e) => WorkRespDto.byResult(e)).toList();

    _tableManager.tableStockMap[ChickenParts.BUY_COUNT] = buyList.fold(
        0, (previousValue, element) => previousValue + element.count);
    _tableManager.tableStockMap[ChickenParts.BUY_TOTAL] = buyList.fold(
        0, (previousValue, element) => previousValue + element.total);

    _tableManager.tableStockMap[ChickenParts.CHICKEN] =
        _tableManager.tableStockMap[ChickenParts.BUY_COUNT] -
            workRespList.fold(
                0, (previousValue, element) => previousValue + element.count);

    Map<int, int> chickenPriceTempMap = {};

    for (var buy in buyList) {
      chickenPriceTempMap[buy.id] = buy.price;
    }

    _tableManager.tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE] =
        workRespList.fold(0, (previousValue, element) {
      return previousValue +
          (element.count * chickenPriceTempMap[element.buyId]!);
    });

    _tableManager.tableStockMap[ChickenParts.BUY_SUB_PRICE_TOTAL] =
        _tableManager.tableStockMap[ChickenParts.BUY_TOTAL] -
            _tableManager.tableStockMap[ChickenParts.WORKED_CHICKEN_PRICE];

    List<String> keyList = _tableManager.tableStockMap.entries.where((element) {
      String key = element.key;

      if(key.indexOf(ChickenParts.STOCK) == 0) {
        return true;
      }

      return false;
    }).map((e) => (e.key as String)).toList();

    for(String key in keyList) {
      _tableManager.tableStockMap[key] = 0;
    }

    for (var buyDto in buyList) {
      String key = ChickenParts.STOCK + buyDto.size.toString();
      _tableManager.tableStockMap[key] = _tableManager.tableStockMap[key] ?? 0;

      _tableManager.tableStockMap[key] += buyDto.count;
    }

    for (var workDto in workRespList) {
      String key = ChickenParts.STOCK + workDto.size.toString();

      if (_tableManager.tableStockMap[key] == null) {
        continue;
      }

      _tableManager.tableStockMap[key] -= workDto.count;
    }

    _tableManager.updateView();
    return;
  }

  void onTopPressed() async {
    isOpen = !isOpen;
  }

  void onCreateAddPressed() async {
    List companyData = await GetIt.instance.get<APIManager>().GET(
      APIManager.URI_COMPANY,
      {"name": ""},
    ) as List;

    List<Company> companyList =
        companyData.map((e) => Company.byResult(e)).toList();

    if (!mounted)
      return; //위젯이 마운트되지 않으면 async뒤에 context를 썼을 때 그 안에 아무런 값도 들어있지 않을 수 있어서다.

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return BuyAddDialog(createdOn: _dateManager.selectTime);
      },
    );

    if (result != null) {
      await GetIt.instance
          .get<APIManager>()
          .PUT(APIManager.URI_BUY, result.toJson());
    }

    setState(() {});
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
            child: _BuyTable(
              onCreateAddPressed: onCreateAddPressed,
              column: buyColumn,
              buyList: buyList,
              onSetState: onSetState,
              onPressRowItem: onPressRowItem,
            ),
          ),
        ),
      ],
    );
  }

  APIManager getAPIManager() {
    return GetIt.instance.get<APIManager>();
  }

  void onPressRowItem(BuyRespDto dto) async {
    await showDialog(
      context: context,
      builder: (context) {
        return BuyUpdateDialog(buyRespDto: dto);
      },
    );

    _buyManager.updateView();

    return;
  }

  void onUpdateDate() async {
    await showDialog(
      context: context,
      builder: (context) {
        return DateUpdateDialog(createdOn: _dateManager.selectTime);
      },
    );

    setState(() {

    });

    _buyManager.updateView();
  }
}

class _BuyTable extends StatelessWidget {
  final List<BuyRespDto> buyList;
  final List<String> column;
  final VoidCallback onCreateAddPressed;
  final VoidCallback onSetState;
  final void Function(BuyRespDto dto) onPressRowItem;

  const _BuyTable({
    Key? key,
    required this.onCreateAddPressed,
    required this.column,
    required this.buyList,
    required this.onSetState,
    required this.onPressRowItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
            showCheckboxColumn: false,
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
          shape: const CircleBorder(
            side: BorderSide(width: 1.0, color: Colors.lightGreen),
          ),
          backgroundColor: Colors.lightGreen),
      onPressed: onCreateAddPressed,
      child: const Icon(Icons.add),
    );
  }

  List<DataColumn> createColumn() {
    return column
        .map(
          (e) => DataColumn(
            label: Text(
              e,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        )
        .toList();
  }

  List<DataRow> createRows() {
    return buyList.map((e) {
      return DataRow(
        onSelectChanged: (value) {
          onPressRowItem(e);
        },
        cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.buyTime)),
          DataCell(Text(e.size.toString())),
          DataCell(Text(e.count.toString())),
          DataCell(Text(e.price.toString())),
          DataCell(Text(e.total.toString())),
          DataCell(Text(e.workCount.toString())),
        ],
      );
    }).toList();
  }
}

class _Top extends StatelessWidget {
  final VoidCallback onPressed;
  final List createList;
  final void Function() onUpdateDate;

  _Top({
    Key? key,
    required this.createList,
    required this.onPressed,
    required this.onUpdateDate,
  }) : super(key: key);

  late BuyManager _buyManager;

  late DateManager _dateManager;

  @override
  Widget build(BuildContext context) {
    _buyManager = Provider.of<BuyManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.lightGreen),
                      //   onPressed: onFinish,
                      //   child: const Text(
                      //     "적용",
                      //     style: TextStyle(
                      //       fontSize: 28,
                      //       fontWeight: FontWeight.w500,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen),
                        onPressed: onUpdateDate,
                        child: const Text(
                          "전체 관리",
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
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.BUY_COUNT]}',
                            "수"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "재고",
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.CHICKEN]}',
                            "원"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "남은 금액",
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.BUY_SUB_PRICE_TOTAL]}',
                            "원"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "구매 금액",
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.BUY_TOTAL]}',
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
    List chickenPartList = [
      ChickenParts.WING,
      ChickenParts.BREAST_SO,
      ChickenParts.LEG,
      ChickenParts.TENDER
    ];
    List chickenMulList = [0.1, 0.22, 0.3, 0.042];

    for (int i = 0; i < chickenPartList.length; ++i) {}

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
