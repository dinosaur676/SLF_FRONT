import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/company.dart';
import 'package:slf_front/model/dto/buy/buy_resp_dto.dart';
import 'package:slf_front/model/dto/work/work_resp_dto.dart';
import 'package:slf_front/model/dto/work/work_update_request_dto.dart';
import 'package:slf_front/util/constant.dart';

enum _TextFormType {
  workName("작업처", 0),
  workTime("작업일자", 1),
  count("수량", 2),
  price("가격", 3);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class WorkUpdateDialog extends StatefulWidget {
  WorkRespDto dto;

  WorkUpdateDialog({
    Key? key,
    required this.dto,
  }) : super(key: key);

  @override
  State<WorkUpdateDialog> createState() => _WorkUpdateDialogState();
}

class _WorkUpdateDialogState extends State<WorkUpdateDialog> {
  late BuyRespDto buyRespDto;
  List<Company> companyList = [];
  final List<_TextFormType> types = _TextFormType.values.map((e) => e).toList();

  late Map<int, TextEditingController> ctlList = {
    for (var element in types) element.pos: TextEditingController()
  };

  @override
  void initState() {
    super.initState();

    ctlList[_TextFormType.workName.pos]!.text = widget.dto.name;
    ctlList[_TextFormType.workTime.pos]!.text = widget.dto.workTime;
    ctlList[_TextFormType.count.pos]!.text = widget.dto.count.toString();
    ctlList[_TextFormType.price.pos]!.text = widget.dto.price.toString();

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: getCompanyList(), builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FractionallySizedBox(
            widthFactor: 0.4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                buyBody(),
                workBody(),
                buttons()
              ]),
            ),
          );
      })
    );
  }

  Future<void> getCompanyList() async {
    final result = await GetIt.instance.get<APIManager>().GET(
        APIManager.URI_COMPANY, {"name": ""}) as List;

    companyList = result.map((e) => Company.byResult(e)).toList();

    final buyResult = await GetIt.instance.get<APIManager>().GET("${APIManager.URI_BUY}/id", {"id" : widget.dto.buyId});
    buyRespDto = BuyRespDto.byResult(buyResult);

    return;
  }
  
  Widget buyBody() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.black
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              getLabel("구매처", buyRespDto.name),
              getLabel("구매일자", buyRespDto.buyTime),
              getLabel("호수", buyRespDto.size.toString()),
              getLabel("수량", buyRespDto.count.toString()),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget workBody() {
    return Column(
      children: [
        getDropDown(_TextFormType.workName),
        getDateSeletor(_TextFormType.workTime),
        getInput(_TextFormType.count),
        getInput(_TextFormType.price),
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
  Widget getLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                label,
                textAlign: TextAlign.end,
                style: StyleConstant.textStyle,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Text(
              value,
              style: StyleConstant.textStyle
            ),
          )
        ],
      ),
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
                  items: companyList
                      .map(
                        (e) =>
                        DropdownMenuItem(
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

  void onBuyDateSelect() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );

    if (selected != null) {
      setState(() {
        ctlList[_TextFormType.workTime.pos]!.text =
            DateFormat("yyyy-MM-dd").format(selected);
      });
    }
  }
  
  void deleteButton() async {
    await GetIt.instance.get<APIManager>().DELETE(APIManager.URI_WORK, {"id": widget.dto.id});

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(null);
  }

  void addButton() async {
    String name = ctlList[_TextFormType.workName.pos]!.text;
    String workTime = ctlList[_TextFormType.workTime.pos]!.text;
    int price = int.parse(ctlList[_TextFormType.price.pos]!.text);
    int count = int.parse(ctlList[_TextFormType.count.pos]!.text);

    WorkRespDto workRespDto = widget.dto;

    WorkUpdateRequestDto dto = WorkUpdateRequestDto(
        workRespDto.id,
        name,
        workTime,
        buyRespDto.size,
        count,
        price,
        count * price);

    await GetIt.instance.get<APIManager>().POST(APIManager.URI_WORK, dto.toJson());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(null);
  }
}
