import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slf_front/manager/chicken_manager.dart';
import 'package:slf_front/manager/date_manager.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({Key? key}) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {

  late DateManager _dateManager;
  late ChickenManager _chickenManager;

  @override
  Widget build(BuildContext context) {
    _dateManager = Provider.of<DateManager>(context, listen: false);
    _chickenManager = Provider.of<ChickenManager>(context, listen: false);

    return Container(
      child: Center(
        child: Row(
          children: [
            Text(
                _dateManager.selectTime,
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
            const SizedBox(width: 16.0,),
            IconButton(onPressed: () => onSelectDate(),
                icon: const Icon(Icons.date_range))
          ],
        ),
      ),
    );
  }

  void onSelectDate() async {
    final DateTime? selected = await showDatePicker(context: context,
      initialDate: _dateManager.selectTime == "" ? DateTime.now() : DateTime.parse(_dateManager.selectTime),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if(selected != null) {
      setState(() {
        _dateManager.selectTime = DateFormat("yyyy-MM-dd").format(selected);
      });
    }

    _chickenManager.clear();
    _dateManager.updateView();
  }
}
