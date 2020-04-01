import 'dart:ui';

import 'data.dart' as data;
import 'dart:math' as math;

import 'package:draw_cover/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaseGeneration extends State<MyHomePage> {
  ValueNotifier<Matrix4> matrix4 = ValueNotifier(Matrix4.identity());
  Matrix4 original;
  MyPainter painter;
  String path;
  int count = 10;
  int lineStroke = 2;
  String lineStrokeLabel = "Nhỏ";
  bool isFirstPick = true;

  Color color = Colors.blue;

  BaseGeneration() {
    this.count = data.boxDefault.toInt();
    this.lineStroke = data.strokeDefault.toInt();

    this.painter = new MyPainter(context);
    this.painter.setCount(count);
    this.painter.setColor(color.value);
  }

  void applyMatrix4(Matrix4 matrix4) {
//    print(matrix4);
    if (isFirstPick) {
      isFirstPick = false;
      original = matrix4;
    }
    this.matrix4.value = matrix4;
    painter.setMatrix4(matrix4);
  }

  void applyCount(int count) {
    this.count = count;
    painter.setCount(count);
    saveDrawData(path);
  }

  void triggerTag() {
    if (painter.isShowTag) {
      painter.hideTag();
    } else {
      painter.showTag();
    }
  }

  void applyLineStroke(int size) {
    this.lineStroke = size;
    this.lineStrokeLabel = lineStroke.round() <= 2
        ? 'Nhỏ'
        : lineStroke.round() <= 4 ? 'Trung bình' : 'Lớn';
    painter.setStroke(size);
    saveDrawData(path);
  }

  void applyColor(int color) {
//    print(color);
    this.color = Color(color);
    painter.setColor(color);
    saveDrawData(path);
  }

  void increaseCount() {
    count++;
    applyCount(count);
  }

  void decreaseCount() {
    count--;
    applyCount(count);
  }

  void saveDrawData(String path) {
    if (path != null && path.length > 0) {
      this.path = path;
      data.DrawData drawData = new data.DrawData();
      drawData.set(path, count, lineStroke, color.value);
      data.saveImage(drawData);
    }
  }

  void getImageProperties(Image i) {
    i.image.resolve(new ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          double w = screenWidth;
          double h = screenWidth * myImage.height / myImage.width;
          if (h > screenHeight) {
            h = screenHeight;
            w = h * myImage.width / myImage.height;
          }
//          print("imageProperties : w = " + w.toString());
//          print("imageProperties : h = " + h.toString());
//          print("imageProperties : s.w = " + screenWidth.toString());
//          print("imageProperties : s.h = " + screenHeight.toString());
//          print("imageProperties : i.w = " + myImage.width.toString());
//          print("imageProperties : i.h = " + myImage.height.toString());
          painter.setObjectSize(w.toInt(), h.toInt());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class MyPainter extends CustomPainter {
  String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  BuildContext context;
  Matrix4 matrix4;
  Paint p;
  int stroke = 2;
  int w = 0;
  int h = 0;
  int c = 0;
  bool isShowTag = false;

  MyPainter(BuildContext context) {
    this.context = context;
    this.p = Paint()
      ..color = Colors.blue
      ..strokeWidth = stroke.toDouble()
      ..strokeCap = StrokeCap.round;
  }

  void setMatrix4(Matrix4 matrix4) {
    this.matrix4 = matrix4;
  }

  void setColor(int value) {
    p.color = Color(value);
  }

  void showTag() {
    isShowTag = true;
  }

  void hideTag() {
    isShowTag = false;
  }

  void setObjectSize(int w, int h) {
    this.w = w;
    this.h = h;
//    print("setObjectSize : " + this.w.toString() + " - " + this.h.toString());
  }

  void setCount(int c) {
    this.c = c;
  }

  void setStroke(int size) {
    this.stroke = size;
    p.strokeWidth = this.stroke.toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (w == 0 || h == 0 || c == 0) {
      return;
    }

    final Paint p = new Paint()
      ..color = this.p.color
      ..strokeCap = this.p.strokeCap;
    if (matrix4 != null) {
      double value = matrix4.determinant();
      if (value >= 1) {
        p.strokeWidth = this.p.strokeWidth / value;
      } else {
        p.strokeWidth = this.p.strokeWidth * value;
//        p.strokeWidth = this.p.strokeWidth;
      }
    } else {
      p.strokeWidth = this.p.strokeWidth;
    }
//    print('test : ' +
//        (matrix4 != null ? matrix4.determinant().toString() : '1') +
//        ' - ' +
//        p.strokeWidth.toString() +
//        ' - ' +
//        this.p.strokeWidth.toString());

    double s = w / c;
    int horCount = (w / s).ceil();
    int verCount = (h / s).ceil();
    double horHalf = h / 2;
    double verHalf = w / 2;

    for (var i = 0; i <= horCount; i++) {
      Offset p1, p2;
      if (kIsWeb) {
        final pos = -verHalf + i * s;
        p1 = Offset(pos, -horHalf);
        p2 = Offset(pos, horHalf);
      } else {
        double hReal = verCount * s;
        final pos = i * s;
        p1 = Offset(pos, 0);
        p2 = Offset(pos, hReal < h ? h.toDouble() : hReal);
      }
      canvas.drawLine(p1, p2, p);
    }

    for (var i = 0; i <= verCount; i++) {
      Offset p1, p2;
      if (kIsWeb) {
        final pos = -horHalf + i * s;
        p1 = Offset(-verHalf, pos);
        p2 = Offset(verHalf, pos);
      } else {
        double wReal = horCount * s;
        final pos = i * s;
        p1 = Offset(0, pos);
        p2 = Offset(wReal < w ? w.toDouble() : wReal, pos);
      }
      canvas.drawLine(p1, p2, p);
    }

    if (isShowTag) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );
      for (var i = 0; i < horCount; i++) {
        for (var j = 0; j < verCount; j++) {
          final textSpan = TextSpan(
            text: (j + 1).toString() + '-${letters[i]}',
            style: TextStyle(
              color: p.color,
              fontSize: s * 0.3,
            ),
          );
          textPainter.text = textSpan;
          textPainter.layout();
          final posX = i * s + s / 2 - textPainter.width / 2;
          final posY = j * s + s / 2 - textPainter.height / 2;
          final offset = Offset(posX, posY);
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
