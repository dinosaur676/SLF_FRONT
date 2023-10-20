import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/table_manager.dart';
import 'package:slf_front/util/chicken_parts.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/widget/buy/buy_widget.dart';
import 'package:slf_front/widget/chicken/sell/breast_widget.dart';
import 'package:slf_front/widget/chicken/sell/etc_widget.dart';
import 'package:slf_front/widget/chicken/sell/leg_widget.dart';
import 'package:slf_front/widget/chicken/sell/tender_widget.dart';
import 'package:slf_front/widget/chicken/sell/wing_widget.dart';
import 'package:slf_front/widget/work/work_widget.dart';

class SellPage extends StatefulWidget {
  const SellPage({Key? key}) : super(key: key);

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {

  List<Widget> widgetList = [
    const WingWidget(),
    const BreastWidget(),
    const LegWidget(),
    const TenderWidget(),
    const EtcWidget()
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                body(),
              ],
            ),
          ),
        ),
        _Bottom(),
      ],
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buyBody(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 25.0),
          child: Divider(thickness: 10),
        ),
        ...widgetList.map((e) =>
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList()
      ],
    );
  }

  Widget buyBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        Container(
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "구매 및 작업",
              textAlign: TextAlign.center,
              style: StyleConstant.labelStyleWeight,
            ),
          ),
        ),
        const Divider(
          color: Colors.black,
          height: 2.0,
        ),
        const BuyWidget(),
        const WorkWidget(),
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  _Bottom({Key? key}) : super(key: key);

  late TableManager _chickenManager;

  @override
  Widget build(BuildContext context) {
    _chickenManager = Provider.of<TableManager>(context);

    return Column(
      children: [
        const Divider(height: 2, color: Colors.black,),
        getRow("판매 합계 금액", "${_chickenManager.getPartsTotal()}"),
        const Divider(thickness: 1,),
        getRow("구매(작업된 닭) 및 작업비 합계 금액", "${_chickenManager.getWorkedPrice()}"),
        const Divider(thickness: 1,),
        getRow("수익금", "${context.watch<TableManager>().getProfits()}"),
        const Divider(height: 2,),
      ],
    );
  }

  Widget getRow(String label, String value) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          VerticalDivider(thickness: 1, color: Colors.black),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}
