import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/company/company_req_dto.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/model/dto/price/price_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/company/add_company_dialog.dart';
import 'package:slf_front/widget/company/update_company_dialog.dart';

class PricePage extends StatefulWidget {
  const PricePage({Key? key}) : super(key: key);

  @override
  State<PricePage> createState() => _PricePageState();
}

enum _TextFormType {
  search("찾기", 0),
  marketPrice("시세", 1),
  loadingPrice("상하차비", 2),
  lotPrice("제비용", 3);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class _PricePageState extends State<PricePage> {
  List<_TextFormType> types = [
    _TextFormType.marketPrice,
    _TextFormType.loadingPrice,
    _TextFormType.lotPrice,
    _TextFormType.search
  ];

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  List<Company> companyList = [];


  String currentSelectDate = "";
  String selectedCompany = "";

  String searchName = "";
  double scrollPosition = 0.0;

  PriceDto priceDto = PriceDto("", 0, 0, 0, "");

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: selectCompanyListView(),
        ),
        Expanded(
          flex: 8,
          child: FutureBuilder(
              future: getPriceData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator();
                }

                if (selectedCompany != "") {
                  return body();
                } else {
                  return Center(
                    child: Text(
                      "회사를 선택해 주세요",
                      style: StyleConstant.textStyle,
                    ),
                  );
                }
              }),
        ),
      ],
    );
  }

  Widget selectCompanyListView() {
    return FutureBuilder(
        future: getCompanyListData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          scrollController = ScrollController(initialScrollOffset: scrollPosition);

          return Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: Colors.black,
              width: 1,
            )),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctlList[_TextFormType.search.pos],
                        ),
                      ),
                      IconButton(
                          onPressed: () => onSearchCompanyButtonPressed(),
                          icon: const Icon(Icons.search)),
                      ElevatedButton(
                        onPressed: () => onAddCompanyButtonPressed(),
                        child: const Text("추가"),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    itemCount: companyList.length,
                    itemBuilder: (context, index) {
                      Color color = Colors.white;

                      if (selectedCompany == companyList[index].name) {
                        color = Colors.red;
                      }

                      if(companyList[index].name == "이푸드" || companyList[index].name == "재고") {
                        color = Colors.grey;
                      }

                      return Material(
                        color: color,
                        child: InkWell(
                          onLongPress: () => onLongPressedCompany(
                              companyList[index].id, companyList[index].name),
                          onTap: () =>
                              onSelectedCompany(index / companyList.length, companyList[index].name),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                companyList[index].name,
                                style: StyleConstant.textStyle,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget getDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                "날짜",
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Text(
                  currentSelectDate,
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                IconButton(
                    onPressed: () => onSelectDate(),
                    icon: const Icon(Icons.date_range))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              children: [
                Material(child: getDatePicker()),
                ...types.getRange(0, 3).map((e) => getInput(e)),
              ],
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          getInfo(),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            onPressed: onInsertDataButton,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
            child: Text(
              "적용",
              style: StyleConstant.buttonTextStyle,
            ),
          )
        ],
      ),
    );
  }

  Widget getInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getLabelText("시세", priceDto.marketPrice.toString()),
          getLabelText("상하차비", priceDto.loadingPrice.toString()),
          getLabelText("제비용", priceDto.lotPrice.toString()),
        ],
      ),
    );
  }

  Widget getLabelText(String label, String value) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
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
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black),
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

  Future<void> getPriceData() async {
    priceDto = PriceDto("", 0, 0, 0, "");
    if(currentSelectDate != "" && selectedCompany != "") {
      final result = await GetIt.instance.get<APIManager>().GET(APIManager.URI_PRICE, PriceSelectRequestDto(selectedCompany, currentSelectDate).toJson());
      priceDto = PriceDto.byResult(result);
    }

    return;
  }

  Future<void> getCompanyListData() async {
    final result = await GetIt.instance.get<APIManager>().GET(
      APIManager.URI_COMPANY,
      {"name": searchName},
    ) as List;

    companyList = result.map((e) => Company.byResult(e)).toList();

    return;
  }

  void onInsertDataButton() async {
    PriceDto dto = PriceDto(
        selectedCompany,
        int.parse(ctlList[_TextFormType.marketPrice.pos]!.text),
        int.parse(ctlList[_TextFormType.loadingPrice.pos]!.text),
        int.parse(ctlList[_TextFormType.lotPrice.pos]!.text),
        currentSelectDate);

    await GetIt.instance.get<APIManager>().POST(APIManager.URI_PRICE, dto.toJson());

    setState(() {});
  }

  void onSelectDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: currentSelectDate == ""
          ? DateTime.now()
          : DateTime.parse(currentSelectDate),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );

    if (selected != null) {
      setState(() {
        currentSelectDate = DateFormat("yyyy-MM-dd").format(selected);
      });
    }
  }

  void onAddCompanyButtonPressed() async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CompanyAddDialog();
        });

    if (result != null) {
      List<String> check = companyList.map((e) => e.name).where((element) => element == result).toList();

      if(check.isEmpty) {
        GetIt.instance.get<APIManager>().PUT(
          APIManager.URI_COMPANY,
          {"name": result},
        );

        scrollPosition = scrollController.position.maxScrollExtent;
      }
    }

    setState(() {});
  }

  void onSelectedCompany(double pos, String name) {

    if(name == "이푸드" || name == "재고") {
      return;
    }

    scrollPosition = scrollController.position.maxScrollExtent * pos;


    setState(() {
      selectedCompany = name;
    });
  }

  void onLongPressedCompany(int id, String name) async {

    if(name == "이푸드" || name == "재고") {
      return;
    }

    String before = name;

    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CompanyUpdateDialog(value: before);
        });

    if (result != null) {
      CompanyReturnType returnType = result["returnType"];

      if (returnType == CompanyReturnType.update) {

        if(result["name"] == "이푸드" || result["name"] == "재고") {
          return;
        }

        CompanyUpdateReqDto dto = CompanyUpdateReqDto(before, result["name"]);
        GetIt.instance
            .get<APIManager>()
            .POST(APIManager.URI_COMPANY, dto.toJson());
      }
      else if (returnType == CompanyReturnType.delete) {
        GetIt.instance
            .get<APIManager>()
            .DELETE(APIManager.URI_COMPANY, {"id": id});

        if(selectedCompany == name) {
          selectedCompany = "";
        }
      }
    }

    setState(() {});
  }

  void onSearchCompanyButtonPressed() async {
    setState(() {
      searchName = ctlList[_TextFormType.search.pos]!.text;
    });
  }
}
