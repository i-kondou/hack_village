import 'package:dietitian/recources/user_data_catalog.dart';
import 'package:dietitian/utils/show_message.dart';

bool isAllDataValid(Map<String, dynamic> userData, context, mounted) {
  bool _isValidNumber(String key) {
    if (userDataCatalog[key]!.minimum != null) {
      if (userDataCatalog[key]!.type == Type.int) {
        return (userData[key] as int) >= userDataCatalog[key]!.minimum!;
      } else if (userDataCatalog[key]!.type == Type.double) {
        return (userData[key] as double) >= userDataCatalog[key]!.minimum!;
      }
    }
    return true;
  }

  for (var key in userDataCatalog.keys) {
    if (userDataCatalog[key]!.inputMethod == InputMethod.text) {
      if (userData[key] == null ||
          userData[key] == userDataCatalog[key]!.noData ||
          !_isValidNumber(key)) {
        showSnackBarMessage(
          '${userDataCatalog[key]!.displayName}を正しく入力してください。',
          context,
          mounted,
        );
        return false;
      }
    } else if (userDataCatalog[key]!.inputMethod == InputMethod.dropdown) {
      if (userData[key] == null ||
          userData[key] == userDataCatalog[key]!.noData) {
        showSnackBarMessage(
          '${userDataCatalog[key]!.displayName}を選択してください。',
          context,
          mounted,
        );
        return false;
      }
    }
  }
  return true;
}
