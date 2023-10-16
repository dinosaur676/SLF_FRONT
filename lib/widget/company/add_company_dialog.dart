import 'package:flutter/material.dart';
import 'package:slf_front/util/constant.dart';

enum _TextFormType {
  name("이름", 0);

  const _TextFormType(this.label, this.pos);

  final String label;
  final int pos;
}

class CompanyAddDialog extends StatefulWidget {
  const CompanyAddDialog({Key? key}) : super(key: key);

  @override
  State<CompanyAddDialog> createState() => _CompanyAddDialogState();
}

class _CompanyAddDialogState extends State<CompanyAddDialog> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FractionallySizedBox(
        widthFactor: 0.3,
        heightFactor: 0.2,
        child: Column(
          children: [
            getInput(_TextFormType.name),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => onButtonPressed(controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                  ),
                  child: Text(
                    "추가",
                    style: StyleConstant.buttonTextStyle,
                  )
                ),
                ElevatedButton(
                  onPressed: () => onButtonPressed(null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    "취소",
                    style: StyleConstant.buttonTextStyle,
                  ),
                ),
              ],
            )
          ],
        ),
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
              controller: controller,
            ),
          )
        ],
      ),
    );
  }

  void onButtonPressed(String? name) {
    Navigator.of(context).pop(name);
  }
}
