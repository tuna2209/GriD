import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:draw_cover/base.dart';

class WebGeneration extends BaseGeneration {
  String name = '';
  String error;
  Uint8List data;

  @override
  Widget build(BuildContext context) {
    return initMainView();
  }

  Widget initMainView() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          error != null
              ? Text(error)
              : data != null ? createImage() : Text('No Image Selected...'),
          CustomPaint(
            painter: painter,
          ),
        ],
      ),
//      floatingActionButton: initActionView(),
    );
  }

  Widget createImage() {
    Image image = Image.memory(
      data,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
    getImageProperties(image);
    return image;
  }

//  Widget initActionView() {
//    return new SpeedDial(
//      child: Icon(Icons.menu),
//      animatedIcon: AnimatedIcons.menu_close,
//      closeManually: true,
//      children: [
//        SpeedDialChild(
//          child: Icon(Icons.image),
//          label: "Change Image",
//          onTap: changeImage,
//        ),
//        SpeedDialChild(
//          child: Icon(Icons.color_lens),
//          label: "Change Color",
//          onTap: changeColor,
//        ),
//        SpeedDialChild(
//          child: Icon(Icons.remove),
//          label: "Decrease",
//          onTap: decreaseCount,
//        ),
//        SpeedDialChild(
//          child: Icon(Icons.add),
//          label: "Increase",
//          onTap: increaseCount,
//        ),
//      ],
//    );
//  }

  void changeImage() {
//    final html.InputElement input = html.FileUploadInputElement();
//    input
//      ..type = 'file'
//      ..multiple = false
//      ..accept = 'image/*';
//
//    input.onChange.listen((e) {
//      if (input.files.isEmpty) return;
//      final reader = html.FileReader();
//      reader.readAsDataUrl(input.files[0]);
//      reader.onError.listen((err) => setState(() {
//            error = err.toString();
//          }));
//      reader.onLoad.first.then((res) {
//        final encoded = reader.result as String;
//        // remove data:image/*;base64 preambule
//        final stripped =
//            encoded.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
//
//        setState(() {
//          name = input.files[0].name;
//          data = base64.decode(stripped);
//          error = null;
//        });
//      });
//    });
//
//    input.click();
  }
}
