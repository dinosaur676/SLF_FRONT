import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_insert_req_dto.dart';
import 'package:slf_front/model/dto/buy/buy_resp_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/price/price_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/price_utils.dart';
import 'package:slf_front/widget/work/work_item_in_dialog.dart';

import '../../../model/dto/buy/buy_update_req_dto.dart';
import '../../../model/dto/work/work_resp_dto.dart';

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

class BuyUpdateDialog extends StatefulWidget {
  BuyRespDto buyRespDto;

  BuyUpdateDialog({Key? key, required this.buyRespDto}) : super(key: key);

  @override
  State<BuyUpdateDialog> createState() => BuyUpdateDialogState();
}

class BuyUpdateDialogState extends State<BuyUpdateDialog> {
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();
  List<Company> companyList = [];
  List<WorkRespDto> workRespDtoList = [];

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  bool floatRound = false;

  @override
  void initState() {
    ctlList[_TextFormType.buyName.pos]!.text = widget.buyRespDto.name;
    ctlList[_TextFormType.buyTime.pos]!.text = widget.buyRespDto.buyTime;
    ctlList[_TextFormType.size.pos]!.text = widget.buyRespDto.size.toString();
    ctlList[_TextFormType.count.pos]!.text = widget.buyRespDto.count.toString();
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
            widthFactor: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Divider(
                    height: 2.0,
                    color: Colors.black,
                  ),
                  Expanded(child: workBody()),
                  buttons()
                ],
              ),
            ),
          );
        },
      ),
    );
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

  Widget workBody() {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 1.0, color: Colors.black)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                int totalPage = workRespDtoList.length + 1;
                currentPage = (currentPage - 1 + totalPage) % (totalPage);
                pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: workRespDtoList.length + 1,
                itemBuilder: (context, index) {
                  if (index < workRespDtoList.length) {
                    return WorkItemInDialog(
                        buyRespDto: widget.buyRespDto,
                        companyList: companyList,
                        workRespDto: workRespDtoList[index]);
                  } else {
                    return WorkItemInDialog(
                        buyRespDto: widget.buyRespDto,
                        companyList: companyList);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                int totalPage = workRespDtoList.length + 1;
                currentPage = (currentPage + 1) % totalPage;
                pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
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
          onPressed: addButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: Text(
            "수정",
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

  Future<void> getCompanyList() async {
    final result = await GetIt.instance
        .get<APIManager>()
        .GET(APIManager.URI_COMPANY, {"name": ""}) as List;

    companyList = result.map((e) => Company.byResult(e)).toList();

    final workResult = await GetIt.instance.get<APIManager>().GET(
        "${APIManager.URI_WORK}/buy", {"buyId": widget.buyRespDto.id}) as List;

    workRespDtoList = workResult.map((e) => WorkRespDto.byResult(e)).toList();

    return;
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

    BuyUpdateReqDto dto = BuyUpdateReqDto(
      widget.buyRespDto.id,
      ctlList[_TextFormType.buyName.pos]!.text,
      ctlList[_TextFormType.buyTime.pos]!.text,
      size,
      count,
      price,
      count * price,
    );

    await GetIt.instance
        .get<APIManager>()
        .POST(APIManager.URI_BUY, dto.toJson());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(dto);
  }
}
