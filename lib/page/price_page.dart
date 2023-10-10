import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/model/dto/price_dto.dart';
import 'package:slf_front/util/param_util.dart';

class PricePage extends StatefulWidget {
  const PricePage({Key? key}) : super(key: key);

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<String> labels = ["시세", "상하차비", "제비용"];
  List<TextEditingController> ctlList = [];

  late PriceManager _priceManager;
  late DateManager _dateManager;

  @override
  Widget build(BuildContext context) {
    _priceManager = Provider.of<PriceManager>(context, listen: false);
    _dateManager = Provider.of<DateManager>(context, listen: true);
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator();
          }
          return body();
        });
  }

  Future<void> getData() async {

    dynamic result = await GetIt.instance.get<APIManager>().GET(APIManager.URI_PRICE, PriceParam.getInfo(_dateManager.selectTime));

    _priceManager.marketPrice = result["marketPrice"];
    _priceManager.loadingCost = result["loadingPrice"];
    _priceManager.lotCost = result["lotPrice"];

    return;
  }

  Widget body() {
    return FractionallySizedBox(
      widthFactor: 0.3,
      child: Center(
        child: Column(
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                children: [...labels.map((e) => getInput(e))],
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
    PriceDto dto = PriceDto(int.parse(ctlList[0].text), int.parse(ctlList[1].text), int.parse(ctlList[2].text), _dateManager.selectTime);

    await GetIt.instance.get<APIManager>().PUT(APIManager.URI_PRICE, PriceParam.insert(dto));

    setState(() {
      ctlList.map((e) => e.dispose());
      ctlList.clear();
    });
  }

  Widget getInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: Column(
        children: [
          getLabelText("시세", _priceManager.marketPrice.toString()),
          getLabelText("상하차비", _priceManager.loadingCost.toString()),
          getLabelText("제비용", _priceManager.lotCost.toString()),
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
