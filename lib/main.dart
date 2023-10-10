import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/buy_manager.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/manager/listener/breast_listener.dart';
import 'package:slf_front/manager/listener/leg_listener.dart';
import 'package:slf_front/manager/listener/tender_listener.dart';
import 'package:slf_front/manager/listener/wing_listener.dart';
import 'package:slf_front/manager/price_manager.dart';
import 'package:slf_front/page/home.dart';
import 'package:slf_front/page/sell_page.dart';
import 'package:slf_front/widget/chicken/chicken_widget.dart';
import 'package:slf_front/widget/chicken/sell/wing_widget.dart';

void main() {
  GetIt.instance.registerSingleton(APIManager());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '서울이푸드 재고관리',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (BuildContext context) => ChickenManager()),
          ChangeNotifierProvider(create: (BuildContext context) => DateManager()),
          ChangeNotifierProvider(create: (BuildContext context) => PriceManager()),
          ChangeNotifierProvider(create: (BuildContext context) => BuyManager()),

          //리스너
          ChangeNotifierProvider(create: (BuildContext context) => TenderListener()),
          ChangeNotifierProvider(create: (BuildContext context) => WingListener()),
          ChangeNotifierProvider(create: (BuildContext context) => BreastListener()),
          ChangeNotifierProvider(create: (BuildContext context) => LegListener()),
        ],
        child: HomePage(),
        ),
    );
  }
}
