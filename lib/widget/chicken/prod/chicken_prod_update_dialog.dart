import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_insert_req_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_insert_request_dto.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_resp_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/price/price_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/price_utils.dart';
import 'package:slf_front/widget/chicken/prod/prod_constant.dart';
import 'package:slf_front/widget/chicken/sell/dialog/sell_item_in_dialog.dart';

import '../../../model/dto/chicken_production/chicken_prod_update_request_dto.dart';

enum _TextFormType {
  prodName("생산처", 0),
  count("수량", 1),
  price("가격", 2),
  type("종류", 4);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class ChickenProdUpdateDialog extends StatefulWidget {
  ChickenProdRespDto dto;


  ChickenProdUpdateDialog({
    Key? key,
    required this.dto,
  }) : super(key: key);

  @override
  State<ChickenProdUpdateDialog> createState() =>
      ChickenProdUpdateDialogState();
}

class ChickenProdUpdateDialogState extends State<ChickenProdUpdateDialog> {
  List<ChickenSellRespDto> sellRespDtoList = [];
  List<Company> companyList = [];
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  int currentPage = 0;
  PageController pageController = PageController();
  double stockCount = 0.0;

  bool isView = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ctlList[_TextFormType.prodName.pos]!.text = widget.dto.name;
    ctlList[_TextFormType.count.pos]!.text = widget.dto.count.toString();
    ctlList[_TextFormType.price.pos]!.text = widget.dto.price.toString();
    ctlList[_TextFormType.type.pos]!.text = widget.dto.type;

    if(ctlList[_TextFormType.type.pos]!.text == "구매") {
      isView = true;
    }
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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                prodBody(),
                Expanded(child: sellBody()),
                buttons()
              ]),
            ),
          );
        },
      ),
    );
  }

  Future<void> getCompanyList() async {
    var result = await GetIt.instance
        .get<APIManager>()
        .GET(APIManager.URI_COMPANY, {"name": ""}) as List;

    companyList = result.map((e) => Company.byResult(e)).toList();

    result = await GetIt.instance.get<APIManager>().GET("${APIManager.URI_CHICKEN_SELL}/prod-id", {"prodId": widget.dto.id});

    sellRespDtoList = result.map((e) => ChickenSellRespDto.byResult(e)).toList();

    stockCount = widget.dto.count;

    for(ChickenSellRespDto sellRespDto in sellRespDtoList) {
      stockCount -= sellRespDto.count;
    }

    return;
  }

  Widget prodBody() {
    return Column(
      children: [
        getDropDown(_TextFormType.prodName),
        getInput(_TextFormType.count),
        if(isView) getInput(_TextFormType.price),
        getTypeDropDown(_TextFormType.type),
        getLabel("남은 수량", stockCount.toString())
      ],
    );
  }

  Widget sellBody() {
    pageController = PageController(initialPage: currentPage);
    return Container(
      decoration:
      BoxDecoration(border: Border.all(width: 1.0, color: Colors.black)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                int totalPage = sellRespDtoList.length + 1;
                currentPage = (currentPage - 1 + totalPage) % (totalPage);
                pageController.animateToPage(currentPage,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn);
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: sellRespDtoList.length + 1,
                itemBuilder: (context, index) {
                  if (index < sellRespDtoList.length) {
                    return SellItemInDialog(
                        prodRespDto: widget.dto,
                        companyList: companyList,
                        sellRespDto: sellRespDtoList[index]);
                  } else {
                    return SellItemInDialog(
                        prodRespDto: widget.dto,
                        companyList: companyList);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                int totalPage = sellRespDtoList.length + 1;
                currentPage = (currentPage + 1) % totalPage;
                pageController.animateToPage(currentPage,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn);
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: updateButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: Text(
            "수정",
            style: StyleConstant.buttonTextStyle,
          ),
        ),
        ElevatedButton(
          onPressed: deleteButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            "삭제",
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

  Widget getLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                label,
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Text(
                value,
                style: StyleConstant.textStyle
            ),
          )
        ],
      ),
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
                  items: ProdConstant.typeList
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
                      if(value == "구매") {
                        isView = true;
                      }
                      else {
                        isView = false;
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

  void deleteButton() async {
    await GetIt.instance.get<APIManager>().DELETE(APIManager.URI_CHICKEN_PRODUCTION,
        {"id": widget.dto.id});

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(null);
  }

  void updateButton() async {
    double count = ctlList[_TextFormType.count.pos]!.text == "" ? 0.0 : double.parse(ctlList[_TextFormType.count.pos]!.text);
    int price = ctlList[_TextFormType.price.pos]!.text == "" ? 0 : int.parse(ctlList[_TextFormType.price.pos]!.text);

    if(ctlList[_TextFormType.type.pos]!.text == "생산") {
      price = 0;
    }

    ChickenProdUpdateReqDto dto = ChickenProdUpdateReqDto(
      widget.dto.id,
      ctlList[_TextFormType.prodName.pos]!.text,
      count,
      price,
      (count * price) as int,
      ctlList[_TextFormType.type.pos]!.text,
    );

    await GetIt.instance.get<APIManager>().POST(APIManager.URI_CHICKEN_PRODUCTION, dto.toJson());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(null);
  }
}
