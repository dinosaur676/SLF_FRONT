import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/price_dto.dart';
import 'package:slf_front/util/param_util.dart';

class PricePage extends StatefulWidget {
  const PricePage({Key? key}) : super(key: key);

  @override
  State<PricePage> createState() => _PricePageState();
}

enum TextFormType {
  search("찾기", 0),
  marketPrice("시세", 1),
  loadingPrice("상하차비", 2),
  lotPrice("제비용", 3);

  const TextFormType(this.label, this.pos);
  final String label;
  final int pos;
}

class _PricePageState extends State<PricePage> {


  List test = [1, 2, 3];
  List<TextFormType> types = [TextFormType.marketPrice, TextFormType.loadingPrice, TextFormType.lotPrice, TextFormType.search];
  late Map<int, TextEditingController> ctlList = { for (var element in types) element.pos : TextEditingController() };


  String currentSelectDate = "";
  String selectedCompany = "";

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
                return body();
              }),
        ),
      ],
    );
  }

  Future<void> getPriceData() async {
    return;
  }

  Future<List> getCompanyListData() async {
    return [
      {"id": 1, "name": "a"},
      {"id": 2, "name": "b"},
      {"id": 3, "name": "c"},
    ];
  }

  Widget selectCompanyListView() {
    return FutureBuilder(
        future: getCompanyListData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          List<Company> companyList =
              snapshot.data!.map((e) => Company(e["id"], e["name"])).toList();

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
                      Expanded(child: TextFormField()),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("추가"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: companyList.length,
                    itemBuilder: (context, index) {
                      Color color = Colors.white;
                      if(selectedCompany == companyList[index].name) {
                        color = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color
                          ),
                          child: Center(
                            child: Text(
                              companyList[index].name,
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black),
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

  Widget body() {
    return FractionallySizedBox(
      widthFactor: 0.4,
      child: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                children: [
                  getDatePicker(),
                  ...labels.map((e) => getInput(e)),
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
              onPressed: onPressedAsync,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
              child: const Text(
                "적용",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPressedAsync() async {
    PriceDto dto = PriceDto(
        int.parse(ctlList[0].text),
        int.parse(ctlList[1].text),
        int.parse(ctlList[2].text),
        currentSelectDate);

    await GetIt.instance
        .get<APIManager>()
        .PUT(APIManager.URI_PRICE, PriceParam.insert(dto));

    setState(() {
      ctlList.map((e) => e.dispose());
      ctlList.clear();
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

  Widget getInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: Column(
        children: [
          getLabelText("시세", "0"),
          getLabelText("상하차비", "0"),
          getLabelText("제비용", "0"),
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

  Widget getInput(String label) {
    ctlList.add(TextEditingController());

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
              controller: ctlList.last,
            ),
          )
        ],
      ),
    );
  }
}
