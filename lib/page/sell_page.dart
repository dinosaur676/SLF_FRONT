import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/widget/buy/buy_widget.dart';
import 'package:slf_front/widget/chicken/sell/breast_widget.dart';
import 'package:slf_front/widget/chicken/sell/etc_widget.dart';
import 'package:slf_front/widget/chicken/sell/leg_widget.dart';
import 'package:slf_front/widget/chicken/sell/tender_widget.dart';
import 'package:slf_front/widget/chicken/sell/wing_widget.dart';

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
        const BuyWidget(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 25.0),
          child: Divider(thickness: 10),
        ),
        ...widgetList.map((e) =>
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: e)).toList()
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  _Bottom({Key? key}) : super(key: key);

  late ChickenManager _chickenManager;

  @override
  Widget build(BuildContext context) {
    _chickenManager = Provider.of<ChickenManager>(context);

    return Column(
      children: [
        const Divider(height: 2, color: Colors.black,),
        getRow("판매 합계 금액", "${_chickenManager.getTotalSell()}"),
        const Divider(thickness: 1,),
        getRow("구매 및 작업비 합계 금액", "${_chickenManager.getTotalBuy()}"),
        const Divider(thickness: 1,),
        getRow("수익금", "${context.watch<ChickenManager>().getProfits()}"),
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
