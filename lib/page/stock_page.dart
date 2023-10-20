
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/model/dto/buy/buy_insert_req_dto.dart';
import 'package:slf_front/model/dto/buy/buy_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_insert_request_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_select_reqeust_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_select_req_dto.dart';
import 'package:slf_front/model/dto/work/work_resp_dto.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/constant.dart';
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

  List<BuyRespDto> buyList = [];
  List<ChickenProdRespDto> prodList = [];

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
    await _calData();

    for (var event in eventList) {
      if(event is ChickenProdInsertReqDto) {
        await GetIt.instance.get<APIManager>().PUT(APIManager.URI_CHICKEN_PRODUCTION, event.toJson());
      }
      else if(event is BuyInsertReqDto) {
        await GetIt.instance.get<APIManager>().PUT(APIManager.URI_BUY, event.toJson());
      }
    }

    Fluttertoast.showToast(msg: "적용 완료", gravity: ToastGravity.CENTER);
  }

  Future<void> _calData() async {
    var result = await GetIt.instance.get<APIManager>().GET(APIManager.URI_BUY, {"createdOn": _dateManager.selectTime}) as List;
    buyList = result.map((e) => BuyRespDto.byResult(e)).toList();

    result = await GetIt.instance.get<APIManager>().GET(APIManager.URI_CHICKEN_PRODUCTION, {"createdOn": _dateManager.selectTime}) as List;
    prodList = result.map((e) => ChickenProdRespDto.byResult(e)).toList();

    Map<int, int> chickenStockMap = await _getChiStock();
    Map<int, double> partsStockMap = await _getProdStock();

    for(BuyRespDto buyRespDto in buyList) {
      if(chickenStockMap[buyRespDto.id] != 0) {
        int count = chickenStockMap[buyRespDto.id]!;
        int price = buyRespDto.price;
        int total = count * price;
        eventList.add(BuyInsertReqDto("재고", buyRespDto.buyTime, buyRespDto.size, count, price, total, stockDay));
      }
    }

    for(ChickenProdRespDto prodRespDto in prodList) {
      if(partsStockMap[prodRespDto.id]!.toInt() != 0) {
        double count = partsStockMap[prodRespDto.id]!;
        int price = prodRespDto.price;
        int total = (count * price) as int;

        eventList.add(ChickenProdInsertReqDto(prodRespDto.parts, prodRespDto.name, count, price, total, "재고", stockDay));
      }
    }
  }
  
  Future<Map<int, int>> _getChiStock() async {
    Map<int, int> output = {};
    
    for(BuyRespDto dto in buyList) {
      final result = await GetIt.instance.get<APIManager>().GET("${APIManager.URI_WORK}/buy", {"buyId": dto.id}) as List;
      List<WorkRespDto> workList = result.map((e) => WorkRespDto.byResult(e)).toList();

      output[dto.id] = dto.count;

      for(WorkRespDto workRespDto in workList) {
        output[dto.id] = output[dto.id]! - workRespDto.count;
      }
    }
    
    
    return output;
  }

  Future<Map<int, double>> _getProdStock() async {
    Map<int, double> output = {};

    for(ChickenProdRespDto dto in prodList) {
      final result = await GetIt.instance.get<APIManager>().GET("${APIManager.URI_CHICKEN_SELL}/prod-id", {"prodId": dto.id}) as List;
      List<ChickenSellRespDto> sellList = result.map((e) => ChickenSellRespDto.byResult(e)).toList();

      output[dto.id] = dto.count;

      for(ChickenSellRespDto sellRespDto in sellList) {
        output[dto.id] = output[dto.id]! - sellRespDto.count;
      }
    }


    return output;
  }




  List getRows() {
    List output = [];
    List partKeyList = partList.map((e) {
      return e[ParamKeys.PARTS];
    }).toList();

    output = _chickenManager.tableStockMap.entries.where((element) {
      bool output = false;
      String key = element.key;

      if(element.value != 0 && key.contains(ChickenParts.STOCK)) {
        output = true;
      }

      return output;
    }).map((e) {
          String label = "";
          int index = -1;

          String key = e.key;
          key = key.replaceAll(ChickenParts.STOCK, "");

          for (int i = 0; i < partKeyList.length; ++i) {
            if (partKeyList[i] == key) {
              index = i;
              break;
            }
          }

          if (index != -1) {
            label = partList[index][ParamKeys.TITLE];
          } else {
            label = "${key}호";
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  style: StyleConstant.textStyle,
                ),
              ),
              Text(
                "${e.value}kg",
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
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

  }
}
