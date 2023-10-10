import 'package:flutter/material.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/widget/chicken/chicken_widget.dart';

class EtcWidget extends StatefulWidget {
  const EtcWidget({Key? key}) : super(key: key);

  @override
  State<EtcWidget> createState() => _EtcWidgetState();
}

class _EtcWidgetState extends State<EtcWidget> {
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
              "기타",
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
        ChickenWidget(title: "어깨살", mainKey: ChickenParts.SHOULDER),
        ChickenWidget(title: "잔골", mainKey: ChickenParts.BONE),
        ChickenWidget(title: "목살", mainKey: ChickenParts.NECK),
        ChickenWidget(title: "잡육", mainKey: ChickenParts.ETC_MEAT),
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
