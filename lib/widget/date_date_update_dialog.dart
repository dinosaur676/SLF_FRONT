import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/manager/date_manager.dart';
import 'package:slf_front/model/dto/date/date_delete_req_dto.dart';
import 'package:slf_front/model/dto/date/date_update_req_dto.dart';
import 'package:slf_front/util/constant.dart';

enum _TextFormType {
  before("수정할 날짜", 0),
  after("수정된 날짜", 1);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class DateUpdateDialog extends StatefulWidget {

  String createdOn;
  DateUpdateDialog({Key? key, required this.createdOn}) : super(key: key);

  @override
  State<DateUpdateDialog> createState() => _DateUpdateDialogState();
}

class _DateUpdateDialogState extends State<DateUpdateDialog> {
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };


  @override
  void initState() {
    super.initState();
    ctlList[_TextFormType.before.pos]!.text = widget.createdOn;
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: FractionallySizedBox(
        widthFactor: 0.4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getInput(_TextFormType.before),
              getDateSeletor(_TextFormType.after),
              const SizedBox(
                height: 16.0,
              ),
              buttons()
            ],
          ),
        ),
      ),
    );
  }

  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: updateButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: Text(
            "전체 이동",
            style: StyleConstant.buttonTextStyle,
          ),
        ),
        ElevatedButton(
          onPressed: deleteButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            "전체 삭제",
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
              readOnly: true,
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
                    onPressed: () => onBuyDateSelect(type),
                    icon: const Icon(Icons.date_range))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onBuyDateSelect(_TextFormType type) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );

    if (selected != null) {
      setState(() {
        ctlList[type.pos]!.text = DateFormat("yyyy-MM-dd").format(selected);
      });
    }
  }

  void updateButton() async {
    String before = ctlList[_TextFormType.before.pos]!.text;
    String after = ctlList[_TextFormType.after.pos]!.text;

    await GetIt.instance.get<APIManager>().POST(APIManager.URI_DATE, DateUpdateReqDto(before, after).toJson());

    if(!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  void deleteButton() async {
    String createdOn = ctlList[_TextFormType.before.pos]!.text;

    await GetIt.instance.get<APIManager>().DELETE(APIManager.URI_DATE, DateDeleteReqDto(createdOn).toJson());

    if(!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
