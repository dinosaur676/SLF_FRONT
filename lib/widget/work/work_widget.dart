import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/buy_manager.dart';
import 'package:slf_front/manager/stock_manager.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/model/dto/work/work_resp_dto.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/widget/work/dialog/work_update_dialog.dart';

class WorkWidget extends StatefulWidget {
  const WorkWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<WorkWidget> createState() => _WorkWidgetState();
}

class _WorkWidgetState extends State<WorkWidget> {

  int createTotal = 0;
  bool isOpen = true;

  List<WorkRespDto> itemList = [];

  List<String> column = ["작업처", "작업일자", "호수", "수량", "단가", "소계"];

  late TableManager _tableManager;
  late StockManager _stockManager;
  late DateManager _dateManager;
  late BuyManager _buyManager;

  @override
  Widget build(BuildContext context) {
    _buyManager = Provider.of<BuyManager>(context, listen: true);
    _tableManager = Provider.of<TableManager>(context, listen: false);
    _stockManager = Provider.of<StockManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                itemList: itemList,
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
        .GET(APIManager.URI_WORK, param) as List;

    itemList = result.map((e) => WorkRespDto.byResult(e)).toList();

    _tableManager.tableStockMap[ChickenParts.WORK_COUNT] = itemList.fold(0, (previousValue, element) => previousValue + element.count);
    _tableManager.tableStockMap[ChickenParts.WORK_TOTAL] = itemList.fold(0, (previousValue, element) => previousValue + element.total);

    return;
  }

  double getTotalSum(List list, String parameterName) {
    return list.fold(
      0,
          (sum, element) => sum + (element[parameterName] as double),
    );
  }

  void onTopPressed() async {
    isOpen = !isOpen;
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
            child: _WorkTable(
              column: column,
              itemList: itemList,
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

  void onPressRowItem(WorkRespDto dto) async {
    await showDialog(
      context: context,
      builder: (context) {
        return WorkUpdateDialog(dto: dto);
      },
    );

    _buyManager.updateView();

    return;
  }
}

class _WorkTable extends StatelessWidget {
  final List<WorkRespDto> itemList;
  final List<String> column;
  final VoidCallback onSetState;
  final void Function(WorkRespDto dto) onPressRowItem;

  const _WorkTable({
    Key? key,
    required this.column,
    required this.itemList,
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
      ],
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
    return itemList.map((e) {
      return DataRow(
        onSelectChanged: (value) {
          onPressRowItem(e);
        },
        cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.workTime)),
          DataCell(Text(e.size.toString())),
          DataCell(Text(e.count.toString())),
          DataCell(Text(e.price.toString())),
          DataCell(Text(e.total.toString())),
        ],
      );
    }).toList();
  }
}

class _Top extends StatelessWidget {
  final VoidCallback onPressed;
  final List itemList;

  _Top({
    Key? key,
    required this.itemList,
    required this.onPressed,
  }) : super(key: key);

  late BuyManager _buyManager;

  @override
  Widget build(BuildContext context) {
    _buyManager = Provider.of<BuyManager>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        "적용",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
                            "작업 량",
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.WORK_COUNT]}',
                            "수"),
                        const VerticalDivider(thickness: 1),
                        valueText(
                            "작업 비",
                            '${context.watch<TableManager>().tableStockMap[ChickenParts.WORK_TOTAL]}',
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
