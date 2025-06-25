import 'package:flutter/material.dart';

class DataField {
  final String dataName;
  final String displayName;
  final dynamic noData;
  final InputMethod inputMethod;
  final TextInputType? keyboardType;
  final Type type;
  final double? minimum;
  final IconData icon;
  final List<String>? dropdownOptions;

  const DataField({
    required this.dataName,
    required this.displayName,
    required this.noData,
    required this.inputMethod,
    this.keyboardType,
    required this.type,
    this.minimum,
    required this.icon,
    this.dropdownOptions,
  });
}

enum InputMethod { text, dropdown }

enum Type { string, int, double }

final userDataCatalog = <String, DataField>{
  "name": DataField(
    dataName: "name",
    displayName: "名前",
    noData: "",
    inputMethod: InputMethod.text,
    keyboardType: TextInputType.text,
    type: Type.string,
    icon: Icons.person,
  ),
  "age": DataField(
    dataName: "age",
    displayName: "年齢",
    noData: -1,
    inputMethod: InputMethod.text,
    keyboardType: TextInputType.number,
    type: Type.int,
    minimum: 0,
    icon: Icons.calendar_today,
  ),
  "sex": DataField(
    dataName: "sex",
    displayName: "性別",
    noData: "未選択",
    inputMethod: InputMethod.dropdown,
    keyboardType: null,
    type: Type.string,
    icon: Icons.transgender,
    dropdownOptions: ["未選択", "男性", "女性", "その他"],
  ),
  "height": DataField(
    dataName: "height",
    displayName: "身長(cm)",
    noData: 0.0,
    inputMethod: InputMethod.text,
    keyboardType: TextInputType.number,
    type: Type.double,
    minimum: 0.0,
    icon: Icons.height,
  ),
  "weight": DataField(
    dataName: "weight",
    displayName: "体重(kg)",
    noData: 0.0,
    inputMethod: InputMethod.text,
    keyboardType: TextInputType.number,
    type: Type.double,
    minimum: 0.0,
    icon: Icons.scale,
  ),
};
