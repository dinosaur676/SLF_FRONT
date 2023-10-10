import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/listener/breast_listener.dart';
import 'package:slf_front/manager/listener/main_listener.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_keys.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/chicken/chicken_widget.dart';

class BreastWidget extends StatefulWidget {
  const BreastWidget({Key? key}) : super(key: key);

  @override
  State<BreastWidget> createState() => _BreastWidgetState();
}

class _BreastWidgetState extends State<BreastWidget> {
  List titleList = [
    WidgetParam.createTitle(
        title: "가슴살 S/O", part: ChickenParts.BREAST_SO, mul: 0),
    WidgetParam.createTitle(
        title: "가슴살 S/O (80g ~ 90g)", part: ChickenParts.BREAST_SO_890, mul: 1),
    WidgetParam.createTitle(
        title: "가슴살 S/L", part: ChickenParts.BREAST_SL, mul: 0.9),
    WidgetParam.createTitle(
        title: "가슴살 S/L 2분할", part: ChickenParts.BREAST_SL_CUT, mul: 1),
    WidgetParam.createTitle(
        title: "가슴살 포", part: ChickenParts.BREAST_PO, mul: 1),
    WidgetParam.createTitle(
        title: "스킨", event: "가슴살 S/L", part: ChickenParts.BREAST_SKIN, mul: 0.1),
    WidgetParam.createTitle(
        title: "가슴살 조각", part: ChickenParts.BREAST_PART, mul: 1),
  ];

  List getWidgets(MainListener listener) {
    List result = [];

    result.add(ChickenWidget(
      listenerParam: titleList.sublist(1),
      title: titleList[0][ParamKeys.TITLE],
      mainKey: titleList[0][ParamKeys.PARTS],
      listener: listener,
    ));

    List temp = titleList
        .sublist(1)
        .map((e) => ChickenWidget(
            title: e[ParamKeys.TITLE],
            mainKey: e[ParamKeys.PARTS],
            listener: listener))
        .toList();

    result.addAll(temp);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        Container(
          color: Colors.grey[300],
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "가슴살",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        ...getWidgets(Provider.of<BreastListener>(context)),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Divider(
            color: Colors.black,
            height: 2.0,
          ),
        ),
      ],
    );
  }
}
