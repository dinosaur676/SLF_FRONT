import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_insert_req_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/price/price_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/price_utils.dart';

enum _TextFormType {
  buyName("구매처", 0),
  buyTime("구매일자", 1),
  size("호수", 2),
  sizePrice("호수 단가", 3),
  count("수량", 4);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class BuyAddDialog extends StatefulWidget {
  String createdOn;

  BuyAddDialog({
    Key? key,
    required this.createdOn,
  }) : super(key: key);

  @override
  State<BuyAddDialog> createState() => _BuyAddDialogState();
}

class _BuyAddDialogState extends State<BuyAddDialog> {
  List<Company> companyList = [];
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  bool floatRound = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: getCompanyList(),
        builder: (context, snapshot) {

          if(snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FractionallySizedBox(
            widthFactor: 0.4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    Checkbox(
                      value: floatRound,
                      onChanged: (value) {
                        setState(() {
                          floatRound = value!;
                        });
                      },
                    ),
                    const Text("소수 반올림"),
                  ],
                ),
                buyBody(),
                buttons()
              ]),
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
        getDropDown(_TextFormType.buyName),
        getDateSeletor(_TextFormType.buyTime),
        getInput(_TextFormType.size),
        getInput(_TextFormType.sizePrice),
        getInput(_TextFormType.count),
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

  Widget getDateSeletor(_TextFormType type) {
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
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: ctlList[type.pos],
                  ),
                ),
                IconButton(
                    onPressed: onBuyDateSelect,
                    icon: const Icon(Icons.date_range))
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

  void onBuyDateSelect() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );

    if (selected != null) {
      setState(() {
        ctlList[_TextFormType.buyTime.pos]!.text =
            DateFormat("yyyy-MM-dd").format(selected);
      });
    }
  }

  void addButton() async {
    if(ctlList[_TextFormType.size.pos]!.text == "" || ctlList[_TextFormType.buyName.pos]!.text == ""
        || ctlList[_TextFormType.buyTime.pos]!.text == "" || ctlList[_TextFormType.count.pos]!.text == "") {
      Fluttertoast.showToast(msg: "값을 입력해주세요.", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
      return;
    }

    int size = int.parse(ctlList[_TextFormType.size.pos]!.text);
    double sizePrice = ctlList[_TextFormType.sizePrice.pos]!.text == ""
        ? size / 10
        : double.parse(ctlList[_TextFormType.sizePrice.pos]!.text);

    final result = await GetIt.instance.get<APIManager>().GET(
          APIManager.URI_PRICE,
          PriceSelectRequestDto(
            ctlList[_TextFormType.buyName.pos]!.text,
            ctlList[_TextFormType.buyTime.pos]!.text,
          ).toJson(),
        );

    if (result == "" || result == null) {
      Fluttertoast.showToast(
          msg: "시세 페이지를 확인해주세요.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      return;
    }

    PriceDto priceDto = PriceDto.byResult(result as Map);

    int price = PriceUtil.getTotalPrice(
        marketPrice: priceDto.marketPrice,
        lotPrice: priceDto.lotPrice,
        loadingPrice: priceDto.loadingPrice,
        sizePrice: sizePrice,
        floatRound: floatRound);

    int count = int.parse(ctlList[_TextFormType.count.pos]!.text);

    BuyInsertReqDto dto = BuyInsertReqDto(
      ctlList[_TextFormType.buyName.pos]!.text,
      ctlList[_TextFormType.buyTime.pos]!.text,
      size,
      count,
      price,
      count * price,
      widget.createdOn,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(dto);
  }
}
