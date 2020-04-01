library draw_cover.data;

import 'package:shared_preferences/shared_preferences.dart';

final double boxDefault = 10;
final double boxMin = 2;
final double boxMax = 24;

final double strokeDefault = 2;
final double strokeMin = 1;
final double strokeMax = 6;

final double bottomSizeMin = 26;
final double bottomSizeMax = 335;
final double bottomIconSize = 36;
final double bottomPhotoSize = 154;

class DrawData {
  String path;
  int line;
  int stroke;
  int color;

  set(String path, int line, int stroke, int color) {
    this.path = path;
    this.line = line;
    this.stroke = stroke;
    this.color = color;
  }

  String toString() {
    return '$path-$line-$stroke-$color';
  }

  void load(String data) {
    List<String> list = data.split('-');
    path = list[0];
    line = int.parse(list[1]);
    stroke = int.parse(list[2]);
    color = int.parse(list[3]);
  }
}

saveImage(DrawData data) async {
  SharedPreferences editor = await SharedPreferences.getInstance();
  await editor.setString(data.path, data.toString());
}

Future<List<DrawData>> getImages() async {
  List<DrawData> data = new List<DrawData>();
  SharedPreferences editor = await SharedPreferences.getInstance();
  Set<String> keys = editor.getKeys();
  for (String key in keys) {
    DrawData item = new DrawData();
    item.load(editor.getString(key));
    data.add(item);
  }
  return data;
}
