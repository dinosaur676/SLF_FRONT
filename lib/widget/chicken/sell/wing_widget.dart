import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/listener/main_listener.dart';
import 'package:slf_front/manager/listener/wing_listener.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/param_keys.dart';
import 'package:slf_front/util/param_util.dart';
import 'package:slf_front/widget/chicken/chicken_widget.dart';

class WingWidget extends StatefulWidget {
  const WingWidget({Key? key}) : super(key: key);

  @override
  State<WingWidget> createState() => _WingWidgetState();
}

class _WingWidgetState extends State<WingWidget> {

  List titleList = [
    WidgetParam.createTitle(title: "통 날개", part: ChickenParts.WING, mul: 0),
    WidgetParam.createTitle(title: "윙/봉", part: ChickenParts.WING_BONG, mul: 0.88),
  ];

  List getWidgets(MainListener listener) {
    List result = [];

    result.add(
        ChickenWidget(
          listenerParam: titleList.sublist(1),
          title: titleList[0][ParamKeys.TITLE],
          parts: titleList[0][ParamKeys.PARTS],
          listener: listener,
        )
    );

    List temp = titleList.sublist(1).map((e) =>
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
              "날개",
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
        ...getWidgets(Provider.of<WingListener>(context)),
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
