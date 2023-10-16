
import 'package:slf_front/manager/api_manager.dart';
import 'package:slf_front/model/dto/price/price_dto.dart';
import 'package:slf_front/util/param_keys.dart';

class ChickenParam {

  static Map getInfoParam(String mainKey, String subKey, String time) {
    Map param = {};

    param[ParamKeys.MAIN_KEY] = mainKey;
    param[ParamKeys.SUB_KEY] = subKey;
    param[ParamKeys.CREATE_ON] = time;


    return param;
  }

  static Map addItemParam(String mainKey, String subKey, ) {
    Map param = {};

    param[ParamKeys.MAIN_KEY] = mainKey;
    param[ParamKeys.SUB_KEY] = subKey;

    return param;
  }

  static Map deleteItemParam(int id) {
    Map param = {};

    param[ParamKeys.ID] = id;

    return param;
  }
}

class PriceParam {
  static Map getInfo(String createOn) {
    Map param = {};

    param[ParamKeys.CREATE_ON] = createOn;

    return param;
  }
}

class WidgetParam {

  static Map createTitle({required String title, String? event, required String part, required double mul}) {
    Map param = {};

    param[ParamKeys.TITLE] = title;
    param[ParamKeys.PARTS] = part;
    param[ParamKeys.MUL] = mul;

    event ??= title;
    
    param[ParamKeys.EVENT] = event;

    return param;
  }
}