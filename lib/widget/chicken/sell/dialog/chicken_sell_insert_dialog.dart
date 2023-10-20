import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_insert_req_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_insert_request_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_insert_req_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/price/price_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/price_utils.dart';

enum _TextFormType {
  prodName("판매처", 0),
  count("출고량", 1),
  price("단가", 2),
  type("종류", 3);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class ChickenSellInsertDialog extends StatefulWidget {
  String parts;
  String createdOn;

  ChickenSellInsertDialog({
    Key? key,
    required this.parts,
    required this.createdOn,
  }) : super(key: key);

  @override
  State<ChickenSellInsertDialog> createState() =>
      _ChickenSellInsertDialogState();
}

class _ChickenSellInsertDialogState extends State<ChickenSellInsertDialog> {
  List<Company> companyList = [];
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  bool isView = false;

  @override
  void initState() {
    ctlList[_TextFormType.type.pos]!.text = "판매";
    isView = true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: getCompanyList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FractionallySizedBox(
            widthFactor: 0.4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [buyBody(), buttons()]),
            ),
          );
        },
      ),
    );
  }

  Future<void> getCompanyList() async {
    final result = await GetIt.instance
        .get<APIManager>()
        .GET(APIManager.URI_COMPANY, {"name": ""}) as List;

    companyList = result.map((e) => Company.byResult(e)).toList();

    return;
  }

  Widget buyBody() {
    return Column(
      children: [
        getDropDown(_TextFormType.prodName),
        getInput(_TextFormType.count),
        if(isView) getInput(_TextFormType.price),
        getTypeDropDown(_TextFormType.type)
      ],
    );
  }

  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: addButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: Text(
            "추가",
            style: StyleConstant.buttonTextStyle,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            "취소",
            style: StyleConstant.buttonTextStyle,
          ),
        ),
      ],
    );
  }

  Widget getInput(_TextFormType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                type.label,
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: TextFormField(
              controller: ctlList[type.pos],
            ),
          )
        ],
      ),
    );
  }

  Widget getTypeDropDown(_TextFormType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                type.label,
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              children: [
                DropdownButton(
                  value: ctlList[type.pos]!.text == "" ? null : ctlList[type.pos]!.text,
                  icon: const Icon(Icons.density_small),
                  items: ["작업", "판매"]
                      .map(
                        (e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    ctlList[type.pos]!.text = value!;
                    setState(() {
                      if(value == "작업") {
                        isView = false;
                      }
                      else {
                        isView = true;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getDropDown(_TextFormType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                type.label,
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              children: [
                DropdownButton(
                  value: ctlList[type.pos]!.text == ""
                      ? null
                      : ctlList[type.pos]!.text,
                  icon: const Icon(Icons.density_small),
                  items: companyList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.name,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.name),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    ctlList[type.pos]!.text = value!;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addButton() async {
    double count = ctlList[_TextFormType.count.pos]!.text == ""
        ? 0.0
        : double.parse(ctlList[_TextFormType.count.pos]!.text);
    int price = ctlList[_TextFormType.price.pos]!.text == ""
        ? 0
        : int.parse(ctlList[_TextFormType.price.pos]!.text);

    if (ctlList[_TextFormType.prodName.pos]!.text == "") {
      Fluttertoast.showToast(
          msg: "값을 입력해주세요.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      return;
    }

    if(ctlList[_TextFormType.type.pos]!.text == "작업") {
      price = 0;
    }

    ChickenSellInsertReqDto dto = ChickenSellInsertReqDto(
      widget.parts,
      ctlList[_TextFormType.prodName.pos]!.text,
      count,
      price,
      (count * price) as int,
      ctlList[_TextFormType.type.pos]!.text,
      0,
      widget.createdOn,
    );

    await GetIt.instance
        .get<APIManager>()
        .PUT(APIManager.URI_CHICKEN_SELL, dto.toJson());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(null);
  }
}
