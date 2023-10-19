
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_keys.dart';
import 'package:slf_front/util/param_util.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {

  String stockDay = "";

  List partList = [
    WidgetParam.createTitle(title: "통 날개", part: ChickenParts.WING, mul: 0),
    WidgetParam.createTitle(
        title: "윙/봉", part: ChickenParts.WING_BONG, mul: 0.88),
    WidgetParam.createTitle(
        title: "가슴살 S/O", part: ChickenParts.BREAST_SO, mul: 0),
    WidgetParam.createTitle(
        title: "가슴살 S/O (80g ~ 90g)", part: ChickenParts.BREAST_SO_890, mul: 1),
    WidgetParam.createTitle(
        title: "가슴살 S/L", part: ChickenParts.BREAST_SL, mul: 0.9),
    WidgetParam.createTitle(
        title: "가슴살 S/L 2분할", part: ChickenParts.BREAST_SL_CUT, mul: 1),
    WidgetParam.createTitle(
        title: "가슴살 포", part: ChickenParts.BREAST_PO, mul: 1),
    WidgetParam.createTitle(
        title: "스킨", part: ChickenParts.BREAST_SKIN, mul: 0.1),
    WidgetParam.createTitle(
        title: "가슴살 조각", part: ChickenParts.BREAST_PART, mul: 1),
    WidgetParam.createTitle(title: "통다리", part: ChickenParts.LEG, mul: 0),
    WidgetParam.createTitle(
        title: "북채", event: "이푸드", part: ChickenParts.DRUMSTICK, mul: 0.4),
    WidgetParam.createTitle(
        title: "통정육", event: "이푸드", part: ChickenParts.MEAT, mul: 0.75),
    WidgetParam.createTitle(
        title: "통정육(깍둑)", part: ChickenParts.MEAT_CUT, mul: 1),
    WidgetParam.createTitle(
        title: "사이", event: "이푸드", part: ChickenParts.THIGH, mul: 0.58),
    WidgetParam.createTitle(
        title: "사이 갈비", part: ChickenParts.THIGH_RIB, mul: 1),
    WidgetParam.createTitle(
        title: "사이 정육", part: ChickenParts.THIGH_MEAT, mul: 0.82),
    WidgetParam.createTitle(title: "안심", part: ChickenParts.TENDER, mul: 0),
    WidgetParam.createTitle(
        title: "안심 조각", part: ChickenParts.TENDER_CUT, mul: 1),
    WidgetParam.createTitle(title: "어깨살", part: ChickenParts.SHOULDER, mul: 1),
    WidgetParam.createTitle(title: "잔골", part: ChickenParts.BONE, mul: 0.82),
    WidgetParam.createTitle(title: "목살", part: ChickenParts.NECK, mul: 0),
    WidgetParam.createTitle(title: "잡육", part: ChickenParts.ETC_MEAT, mul: 1),
  ];

  List<TextEditingController> ctlList = [];
  List eventList = [];

  late DateManager _dateManager;
  late TableManager _chickenManager;

  @override
  Widget build(BuildContext context) {
    _dateManager = Provider.of<DateManager>(context, listen: true);
    _chickenManager = Provider.of<TableManager>(context, listen: true);

    if(stockDay == "" || !checkSelectDay()) {
      stockDay = DateFormat("yyyy-MM-dd").format(DateTime.parse(_dateManager.selectTime).add(const Duration(days: 1)));
      getData();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300]
                  ),
                  child: Column(
                    children: [
                      ...getRows()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          stockDay,
                          style: TextStyle(
                              fontSize: 20.0
                          ),
                        ),
                        const SizedBox(width: 16.0,),
                        IconButton(onPressed: () => onSelectDate(),
                            icon: const Icon(Icons.date_range))
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen
                      ),
                      onPressed: onPressed,
                      child: const Text(
                        "적용",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool checkSelectDay() {
    DateTime select = DateTime.parse(stockDay);
    DateTime first = DateTime.parse(_dateManager.selectTime).add(const Duration(days: 0));
    DateTime last = DateTime.parse(_dateManager.selectTime).add(const Duration(days: 4));

    bool checkFirst = first.isBefore(select);
    bool checkLast = last.isAfter(select);

    return checkFirst && checkLast;
  }

  void onSelectDate() async {
    final DateTime? selected = await showDatePicker(context: context,
      initialDate: DateTime.parse(_dateManager.selectTime).add(const Duration(days: 1)),
      firstDate: DateTime.parse(_dateManager.selectTime).add(const Duration(days: 1)),
      lastDate: DateTime.parse(_dateManager.selectTime).add(const Duration(days: 3)),
    );

    if(selected != null) {
      setState(() {
        stockDay = DateFormat("yyyy-MM-dd").format(selected);
        getData();
      });
    }

  }

  void onPressed() async {
    Fluttertoast.showToast(msg: "적용중", gravity: ToastGravity.CENTER);
    for (var event in eventList) {
      await GetIt.instance.get<APIManager>().PUT(
          APIManager.URI_CHICKEN_PRODUCTION,
          ChickenParam.addItemParam(
              event[ParamKeys.MAIN_KEY],
              event[ParamKeys.SUB_KEY])
      );
    }

    Fluttertoast.showToast(msg: "적용 완료", gravity: ToastGravity.CENTER);
  }

  List getRows() {
    List output = [];
    List partKeyList = partList.map((e) {
      return e[ParamKeys.PARTS];
    }).toList();

    output =
        _chickenManager.stockMap.entries.where((element) => element.value !=
            0 && element.key != ChickenParts.CHICKEN).map((e) {
          String label = "";
          int index = -1;

          for (int i = 0; i < partKeyList.length; ++i) {
            if (partKeyList[i] == e.key) {
              index = i;
              break;
            }
          }

          if (index != -1) {
            label = partList[index][ParamKeys.TITLE];
          } else {
            label = "${e.key as String}호";
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                ),
              ),
              Text(
                "${e.value}kg",
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black),
              ),
              const VerticalDivider(
                thickness: 1,
                color: Colors.black,
              ),
              // Container(
              //     decoration: BoxDecoration(
              //       color: Colors.grey[300],
              //     ),
              //     child: getLabelText(label, (e.value as int).toString())),
            ],
          );
        }).toList();

    return output;
  }

  void getData() {
    List partKeyList = partList.map((e) {
      return e[ParamKeys.PARTS];
    }).toList();

    eventList =
        _chickenManager.stockMap.entries.where((element) => element.value !=
            0 && element.key != ChickenParts.CHICKEN).map((e) {
          if (partKeyList.contains(e.key)) {
            return getAPIMap(
                e.key,
                ChickenParts.CREATE);
          }

          return getAPIMap(
              ChickenParts.BUY_COUNT,
              ChickenParts.BUY_COUNT);
        }).toList();
  }

  Map getAPIMap(String mainKey, String subKey) {
    Map map = {};

    map[ParamKeys.MAIN_KEY] = mainKey;
    map[ParamKeys.SUB_KEY] = subKey;

    return map;
  }
}
