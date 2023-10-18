import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_resp_dto.dart';
import 'package:slf_front/model/dto/work/work_insert_request_dto.dart';
import 'package:slf_front/util/constant.dart';
import 'package:slf_front/widget/buy/dialog/buy_update_dialog.dart';

import '../../model/dto/work/work_resp_dto.dart';

enum _TextFormType {
  workName("작업처", 0),
  workTime("작업일자", 1),
  count("수량", 2),
  price("가격", 3);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class WorkItemInDialog extends StatefulWidget {
  BuyRespDto buyRespDto;
  List<Company> companyList;
  WorkRespDto? workRespDto;

  WorkItemInDialog(
      {Key? key,
      required this.buyRespDto,
      this.workRespDto,
      required this.companyList})
      : super(key: key);

  @override
  State<WorkItemInDialog> createState() => _WorkItemInDialogState();
}

class _WorkItemInDialogState extends State<WorkItemInDialog> {
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  late BuyUpdateDialogState buyUpdateDialogState = context.findAncestorStateOfType<BuyUpdateDialogState>()!;


  @override
  void initState() {
    super.initState();

    if(widget.workRespDto != null) {
      ctlList[_TextFormType.workName.pos]!.text = widget.workRespDto!.name;
      ctlList[_TextFormType.workTime.pos]!.text = widget.workRespDto!.workTime;
      ctlList[_TextFormType.count.pos]!.text = widget.workRespDto!.count.toString();
      ctlList[_TextFormType.price.pos]!.text = widget.workRespDto!.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Container(child: widget.workRespDto == null ? addItem() : hasItem()));
  }

  Widget addItem() {
    return Column(
      children: [
        getDropDown(_TextFormType.workName),
        getDateSeletor(_TextFormType.workTime),
        getInput(_TextFormType.count),
        getInput(_TextFormType.price),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        )
      ],
    );
  }

  Widget hasItem() {
    return Column(
      children: [
        getDropDown(_TextFormType.workName),
        getDateSeletor(_TextFormType.workTime),
        getInput(_TextFormType.count),
        getInput(_TextFormType.price),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: addButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
              ),
              child: Text(
                "수정",
                style: StyleConstant.buttonTextStyle,
              ),
            ),
            ElevatedButton(
              onPressed: deleteButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                "삭제",
                style: StyleConstant.buttonTextStyle,
              ),
            ),
          ],
        )
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
                    onPressed: () => onWorkDateSelect(type),
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

  void onWorkDateSelect(_TextFormType type) async {
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

  void addButton() async {
    int count = int.parse(ctlList[_TextFormType.count.pos]!.text);
    int price = int.parse(ctlList[_TextFormType.price.pos]!.text);

    WorkInsertReqDto workInsertReqDto = WorkInsertReqDto(
      ctlList[_TextFormType.workName.pos]!.text,
      ctlList[_TextFormType.workTime.pos]!.text,
      widget.buyRespDto.size,
      count,
      price,
      count * price,
      widget.buyRespDto.createdOn,
      widget.buyRespDto.id,
    );

    await GetIt.instance.get<APIManager>().PUT(APIManager.URI_WORK, workInsertReqDto.toJson());
    
    buyUpdateDialogState.setState(() {
      
    });
  }

  void deleteButton() async {
    await GetIt.instance.get<APIManager>().DELETE(APIManager.URI_WORK, {"id": widget.workRespDto!.id});

    buyUpdateDialogState.setState(() {

    });
  }
}
