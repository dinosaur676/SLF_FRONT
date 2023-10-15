import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/model/dto/request_dto.dart';

class ChickenBuyDialog extends StatefulWidget {
  final String time;
  final PriceManager priceManager;
  final List<String> labels = [
    "구매처",
    "호수",
    "호수 단가",
    "수량",
  ];

  ChickenBuyDialog({
    Key? key,
    required this.time,
    required this.priceManager,
  }) : super(key: key);

  @override
  State<ChickenBuyDialog> createState() => _ChickenBuyDialogState();
}

class _ChickenBuyDialogState extends State<ChickenBuyDialog> {
  List<TextEditingController> ctlList = [];

  bool floatRound = false;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: FractionallySizedBox(
        widthFactor: 0.25,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Checkbox(
                  value: floatRound,
                  onChanged: (value) {
                    floatRound = value!;
                    setState(() {
                      ctlList.map((e) => e.dispose());
                      ctlList.clear();
                    });
                  },
                ),
                Text("소수 반올림"),
              ],
            ),
            ...widget.labels.map((label) => getInput(label)).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: addButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                  ),
                  child: const Text(
                    "추가",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    "취소",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }

  void addButton() {
    RequestDto dto;
    dto = RequestDto(
        name: "${ctlList[0].text} / ${ctlList[1].text}호",
        count: double.parse(ctlList[3].text),
        createOn: widget.time);

    // dto.setPrice(
    //     widget.priceManager.getTotalPrice(double.parse(ctlList[2].text), floatRound));floatRound

    dto.setTotal();

    Navigator.of(context).pop(dto);
  }

  Widget getInput(String label) {
    ctlList.add(TextEditingController());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: ctlList.last,
            ),
          )
        ],
      ),
    );
  }
}
