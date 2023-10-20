import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/chicken_production/chicken_prod_resp_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_insert_req_dto.dart';
import 'package:slf_front/model/dto/chicken_sell/chicken_sell_resp_dto.dart';
import 'package:slf_front/model/dto/work/work_insert_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/widget/chicken/prod/chicken_prod_update_dialog.dart';
import 'package:slf_front/widget/chicken/sell/sell_constant.dart';

import '../../../../model/dto/chicken_sell/chicken_sell_update_req_dto.dart';

enum _TextFormType {
  name("판매처", 0),
  count("출고량", 1),
  price("가격", 2),
  type("종류", 3);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class SellItemInDialog extends StatefulWidget {
  ChickenProdRespDto prodRespDto;
  List<Company> companyList;
  ChickenSellRespDto? sellRespDto;

  SellItemInDialog(
      {Key? key,
      required this.prodRespDto,
      this.sellRespDto,
      required this.companyList})
      : super(key: key);

  @override
  State<SellItemInDialog> createState() => _SellItemInDialogState();
}

class _SellItemInDialogState extends State<SellItemInDialog> {
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  late ChickenProdUpdateDialogState prodUpdateDialogState =
      context.findAncestorStateOfType<ChickenProdUpdateDialogState>()!;

  bool isView = true;

  @override
  void initState() {
    super.initState();

    ctlList[_TextFormType.type.pos]!.text = "판매";


    if (widget.sellRespDto != null) {
      ctlList[_TextFormType.name.pos]!.text = widget.sellRespDto!.name;
      ctlList[_TextFormType.count.pos]!.text =
          widget.sellRespDto!.count.toString();
      ctlList[_TextFormType.price.pos]!.text =
          widget.sellRespDto!.price.toString();
      ctlList[_TextFormType.type.pos]!.text = widget.sellRespDto!.type;

      if (ctlList[_TextFormType.type.pos]!.text == "작업") {
        isView = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: widget.sellRespDto == null ? addItem() : hasItem()));
  }

  Widget addItem() {
    return Column(
      children: [
        getDropDown(_TextFormType.name),
        getInput(_TextFormType.count),
        if(isView) getInput(_TextFormType.price),
        getTypeDropDown(_TextFormType.type),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        )
      ],
    );
  }

  Widget hasItem() {
    return Column(
      children: [
        getDropDown(_TextFormType.name),
        getInput(_TextFormType.count),
        if(isView) getInput(_TextFormType.price),
        getTypeDropDown(_TextFormType.type),
        const SizedBox(
          height: 16.0,
        ),
        Row(
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
          ],
        )
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
                  items: widget.companyList
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
                  value: ctlList[type.pos]!.text == ""
                      ? null
                      : ctlList[type.pos]!.text,
                  icon: const Icon(Icons.density_small),
                  items: SellConstant.typeList
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
                      if (value == "작업") {
                        isView = false;
                      } else {
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

  void addButton() async {
    typeCheck();

    double count = ctlList[_TextFormType.count.pos]!.text == ""
        ? 0.0
        : double.parse(ctlList[_TextFormType.count.pos]!.text);
    int price = ctlList[_TextFormType.price.pos]!.text == ""
        ? 0
        : int.parse(ctlList[_TextFormType.price.pos]!.text);

    ChickenSellInsertReqDto sellInsertReqDto = ChickenSellInsertReqDto(
      widget.prodRespDto.parts,
      ctlList[_TextFormType.name.pos]!.text,
      count,
      price,
      (count * price) as int,
      ctlList[_TextFormType.type.pos]!.text,
      widget.prodRespDto.id,
      widget.prodRespDto.createdOn,
    );

    await GetIt.instance
        .get<APIManager>()
        .PUT(APIManager.URI_CHICKEN_SELL, sellInsertReqDto.toJson());

    prodUpdateDialogState.setState(() {});
  }

  void updateButton() async {
    typeCheck();

    double count = ctlList[_TextFormType.count.pos]!.text == ""
        ? 0.0
        : double.parse(ctlList[_TextFormType.count.pos]!.text);
    int price = ctlList[_TextFormType.price.pos]!.text == ""
        ? 0
        : int.parse(ctlList[_TextFormType.price.pos]!.text);

    ChickenSellUpdateReqDto sellUpdateReqDto = ChickenSellUpdateReqDto(
      widget.sellRespDto!.id,
      ctlList[_TextFormType.name.pos]!.text,
      count,
      price,
      (count * price) as int,
      ctlList[_TextFormType.type.pos]!.text
    );

    await GetIt.instance
        .get<APIManager>()
        .POST(APIManager.URI_CHICKEN_SELL, sellUpdateReqDto.toJson());

    prodUpdateDialogState.setState(() {});
  }

  void deleteButton() async {
    await GetIt.instance
        .get<APIManager>()
        .DELETE(APIManager.URI_CHICKEN_SELL, {"id": widget.sellRespDto!.id});

    prodUpdateDialogState.setState(() {});
  }

  void typeCheck() {
    if(ctlList[_TextFormType.type.pos]!.text == "작업") {
      ctlList[_TextFormType.price.pos]!.text = "0";
    }
  }
}
