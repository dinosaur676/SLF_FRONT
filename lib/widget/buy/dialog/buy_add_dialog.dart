import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/util/constant.dart';

enum _TextFormType {
  buyName("구매처", 0),
  buyTime("구매일자", 1),
  size("호수", 2),
  sizePrice("호수 단가", 3),
  count("수량", 4),
  workName("작업처", 5),
  workTime("작업일자", 6),
  workPrice("작업비", 7);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class BuyAddDialog extends StatefulWidget {
  List<Company> companyList;

  BuyAddDialog({Key? key, required this.companyList}) : super(key: key);

  @override
  State<BuyAddDialog> createState() => _BuyAddDialogState();
}

class _BuyAddDialogState extends State<BuyAddDialog> {
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  bool floatRound = false;
  bool isWorked = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FractionallySizedBox(
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
            Row(
              children: [
                Checkbox(
                  value: isWorked,
                  onChanged: (value) {
                    setState(() {
                      isWorked = value!;
                    });
                  },
                ),
                const Text("작업"),
              ],
            ),
            if (isWorked) workBody(),
            buttons()
          ]),
        ),
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
    return Column(
      children: [
        getDropDown(_TextFormType.workName),
        getDateSeletor(_TextFormType.workTime),
        getInput(_TextFormType.workPrice),
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

  void onBuyDateSelect() {}

  void addButton() {
    //Navigator.of(context).pop(dto);
  }
}
