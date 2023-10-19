import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/listener/leg_listener.dart';
import 'package:slf_front/manager/listener/main_listener.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_keys.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/chicken/chicken_widget.dart';


class LegWidget extends StatefulWidget {
  const LegWidget({Key? key}) : super(key: key);

  @override
  State<LegWidget> createState() => _LegWidgetState();
}

class _LegWidgetState extends State<LegWidget> {

  List titleList = [
    WidgetParam.createTitle(title: "통다리", part: ChickenParts.LEG, mul: 0),
    WidgetParam.createTitle(title: "북채", event: "이푸드", part: ChickenParts.DRUMSTICK, mul: 0.4),
    WidgetParam.createTitle(title: "통정육", event: "이푸드", part: ChickenParts.MEAT, mul: 0.75),
    WidgetParam.createTitle(title: "통정육(깍둑)", part: ChickenParts.MEAT_CUT, mul: 1),
    WidgetParam.createTitle(title: "사이", event: "이푸드", part: ChickenParts.THIGH, mul: 0.58),
    WidgetParam.createTitle(title: "사이 갈비", part: ChickenParts.THIGH_RIB, mul: 1),
    WidgetParam.createTitle(title: "사이 정육", part: ChickenParts.THIGH_MEAT, mul: 0.82),
  ];

  List getListItem(List positions) {
    return positions.map((e) => titleList[e]).toList();
  }

  List getWidgets(MainListener listener) {
    List result = [];

    result.add(
        ChickenWidget(
          listenerParam: getListItem([1, 2, 4]),
          title: titleList[0][ParamKeys.TITLE],
          parts: titleList[0][ParamKeys.PARTS],
          listener: listener,
        )
    );

    result.add(
        ChickenWidget(
          title: titleList[1][ParamKeys.TITLE],
          parts: titleList[1][ParamKeys.PARTS],
          listener: listener,
        )
    );

    result.add(
        ChickenWidget(
          listenerParam: getListItem([3]),
          title: titleList[2][ParamKeys.TITLE],
          parts: titleList[2][ParamKeys.PARTS],
          listener: listener,
        )
    );

    result.add(
        ChickenWidget(
          title: titleList[3][ParamKeys.TITLE],
          parts: titleList[3][ParamKeys.PARTS],
          listener: listener,
        )
    );

    result.add(
        ChickenWidget(
          listenerParam: getListItem([5, 6]),
          title: titleList[4][ParamKeys.TITLE],
          parts: titleList[4][ParamKeys.PARTS],
          listener: listener,
        )
    );

    List temp = titleList.sublist(5).map((e) =>
        ChickenWidget(title: e[ParamKeys.TITLE],
            parts: e[ParamKeys.PARTS],
            listener: listener)
    ).toList();

    result.addAll(temp);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          color: Colors.black,
          height: 2.0,
        ),
        Container(
          color: Colors.grey[300],
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "다리",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.black,
          height: 2.0,
        ),
        ...getWidgets(Provider.of<LegListener>(context)),
        Padding(
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
