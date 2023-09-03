import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'masking.dart';
export 'package:flutter/material.dart';
export 'dart:io';
export 'masking.dart';

List days = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

Future<File> rGetFile() async {
  var path = await getApplicationDocumentsDirectory();
  File file = File('${path.path}/$mFileName');
  await file.exists() ? null : await file.create();
  (await file.readAsString()).isEmpty ? file.writeAsString("{}") : null;
  return file;
}

Future<void> rSaveDataToDb(File file) async {
  var fileData = jsonDecode(await file.readAsString());
  List data = [];
  List sliderStates = [];
  for (int i = 0; i < 24; i++) {
    data.add(mFormatString(i));
    sliderStates.add([-1.0, -1.0, -1.0]);
  }
  var date = DateTime.now();

  debugPrint(date.weekday.toString());
  if (file.readAsStringSync() == "{}") {
    fileData["${date.toString().substring(0, 10)} ${days[date.weekday - 1]}"] =
        {};
    fileData["${date.toString().substring(0, 10)} ${days[date.weekday - 1]}"]
        ["times"] = data;
    fileData["${date.toString().substring(0, 10)} ${days[date.weekday - 1]}"]
        ["sliderStates"] = sliderStates;
    await file.writeAsString(jsonEncode(fileData));
  }
}

Future<void> rAddDataToDb(File file) async {
  List data = [];
  List sliderStates = [];
  for (int i = 0; i < 24; i++) {
    data.add(mFormatString(i));
    sliderStates.add([-1.0, -1.0, -1.0]);
  }
  dynamic fileData = jsonDecode(await file.readAsString());
  dynamic prevDate =
      fileData.keys.last.toString().replaceAll(" ", "-").split("-");
  prevDate = DateTime(
      int.parse(prevDate[0]), int.parse(prevDate[1]), int.parse(prevDate[2]));
  String nextDate = "";
  int n = 0;
  int dayIndex = 0;
  while (true) {
    n += 1;
    dayIndex = int.parse((((prevDate.weekday + n - 1) % 7)).toString());
    nextDate =
        "${prevDate.add(Duration(days: n)).toString().substring(0, 10)} ${days[dayIndex]}";
    if (!fileData.keys.toList().contains(nextDate)) {
      break;
    }
  }
  fileData[nextDate] = {};
  fileData[nextDate]["times"] = data;
  fileData[nextDate]["sliderStates"] = sliderStates;
  await file.writeAsString(jsonEncode(fileData));
}

Future<int> addTodaysData(File file) async {
  var fileData = json.decode(await file.readAsString());
  String dateToday = DateTime.now().toString().substring(0, 10);
  List data = [];
  var date = DateTime.now();
  if (!fileData.keys
      .toList()
      .contains("$dateToday ${days[date.weekday - 1]}")) {
    for (int i = 0; i < 24; i++) {
      data.add(mFormatString(i));
    }
    fileData["$dateToday ${days[date.weekday - 1]}"] = data;
    await file.writeAsString(jsonEncode(fileData));
  }
  return fileData.keys.toList().indexOf("$dateToday ${days[date.weekday - 1]}");
}

class RowContainer extends StatelessWidget {
  final String col1Text, col2Text, col3Text, col4Text;
  final String rowType;
  final Color rowColor;

  const RowContainer(
      {super.key,
      required this.col1Text,
      required this.col2Text,
      required this.col3Text,
      required this.col4Text,
      required this.rowType,
      required this.rowColor});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        color: rowColor,
        height:
            height / (rowType == 'body' ? mBodyRowHeight : mHeaderRowHeight),
        width: width,
        child: SizedBox(
          height: 40,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: width / 7,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(col1Text,
                            style: TextStyle(
                                fontWeight: rowType == 'body'
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: rowType == 'body' ? 12 : 16)))),
                SizedBox(
                    width: width / 12,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        col2Text,
                        fit: BoxFit.contain,
                      ),
                    )),
                SizedBox(
                    width: width / 12,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(col3Text, fit: BoxFit.contain),
                    )),
                SizedBox(
                    width: width / 12,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(col4Text, fit: BoxFit.contain),
                    )),
              ]),
        ));
  }
}
