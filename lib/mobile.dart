import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:draw_cover/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'data.dart' as data;

import 'package:draw_cover/base.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

import 'util.dart';

class MobileGeneration extends BaseGeneration
    with SingleTickerProviderStateMixin {
  double screenWidth = 0;
  double screenHeight = 0;

  File image;
  List<File> images;

  DateTime currentBackPressTime;
  Matrix4 matrix;
  Color initialColor = Colors.blue;
  BarColorPicker colorPicker;
  PanelController panelController;
  PageController pageController;
  bool result = false;
  bool isOpenPanel = false;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (!result) requestPermission();

    return initMainView();
  }

  void requestPermission() async {
    result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      List<AssetEntity> assetEntities = new List();
      for (int i = 0; i < assetPaths.length; i++) {
        assetEntities.addAll(await assetPaths[i].assetList);
      }
      for (int i = 0; i < assetEntities.length; i++) {
        File f = await assetEntities[i].file;
        images.add(f);
      }
      setState(() {});
    } else {
      PhotoManager.openSetting();
    }
  }

  @override
  void initState() {
    super.initState();
    matrix = Matrix4.identity();
    images = new List();
    panelController = new PanelController();
    pageController = new PageController(initialPage: 0, viewportFraction: 0.7);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget initMainView() {
    return Scaffold(
      backgroundColor: Color(0xff2f2f2f),
      body: DoubleBackToCloseApp(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              SlidingUpPanel(
                minHeight: image == null ? 0 : data.bottomSizeMin,
                maxHeight: data.bottomSizeMax,
                controller: panelController,
                defaultPanelState: PanelState.CLOSED,
                panel: image == null ? initPanelNoImage() : initPanel(),
                body: image == null ? initNoImagePanel() : initImagePanel(),
              ),
            ],
          ),
        ),
        snackBar: const SnackBar(
          content: Text(
            'Nhấn back dể thoát ứng dụng',
          ),
        ),
      ),
    );
  }

  Widget initNoImagePanel() {
    return GestureDetector(
      onTap: () {
        triggerPanel();
      },
      child: Stack(
        children: <Widget>[
          Container(
            color: Color(0xffffffff),
            width: screenWidth,
            height: screenHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: screenWidth * 0.6,
                    height: 48,
                    child: FlatButton(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        triggerPanel();
                      },
                      padding: new EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(48),
                        side: BorderSide(
                          color: Color(0xff3cb878),
                        ),
                      ),
                      textColor: Colors.white,
                      color: Color(0xff3cb878),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Nhấn bất kỳ chỗ nào để chọn ảnh',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff848484),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: isOpenPanel ? Color(0x88000000) : Color(0x00000000),
          ),
        ],
      ),
    );
  }

  Widget initImagePanel() {
    LayoutBuilder builder = new LayoutBuilder(
      builder: (context, constraints) {
//        var width = screenWidth;
//        var height = constraints.smallest.height;
//        MinBoxer boxer = MinBoxer(Rect.fromLTWH(0, 0, width, height),
//            Offset.zero & constraints.biggest);
        return MatrixGestureDetector(
          shouldRotate: false,
          shouldTranslate: true,
          shouldScale: true,
          clipChild: true,
          onMatrixUpdate: (m, tm, sm, rm) {
//            matrix = MatrixGestureDetector.compose(matrix, tm, sm, null);
//            boxer.clamp(matrix);
//            setState(() {
//              applyMatrix4(matrix);
//            });
            applyMatrix4(m);
          },
          child: AnimatedBuilder(
            animation: matrix4,
            builder: (ctx, child) {
              return Transform(
                transform: matrix4.value,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(0),
                      width: double.infinity,
                      child: Image.file(
                        image,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    CustomPaint(
                      painter: painter,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    return builder;
  }

  Future<Widget> getSlideImage(AssetEntity item) async {
    File file = await item.file;
    return Image.file(file);
  }

  Widget initPanelNoImage() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            (images != null && images.length > 0)
                ? Container(
                    margin: EdgeInsets.only(top: 2),
                    width: screenWidth,
                    height: data.bottomPhotoSize,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return new Container(
                          width: screenWidth * 0.6,
                          height: double.infinity,
                          margin: index == images.length - 1
                              ? EdgeInsets.all(0)
                              : EdgeInsets.only(right: 2),
                          child: Container(
                            color: Color(0xffd9d9d9),
                            child: InkWell(
                              onTap: () async {
                                File image = await ImageCropper.cropImage(
                                    sourcePath: images[index].path);
                                calculatorImage(image);
                              },
                              child: Image.file(
                                images[index],
                                fit: BoxFit.cover,
                                width: screenWidth * 0.6,
                                cacheWidth: (screenWidth * 0.6).toInt(),
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 2),
                    width: screenWidth,
                    height: data.bottomPhotoSize,
                  ),
            SizedBox(height: 8),
            Container(
              width: screenWidth * 0.55,
              height: 48,
              child: FlatButton(
                child: Text(
                  'Thư viện ảnh',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  getImageFromGallery();
                },
                padding: new EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(48),
                  side: BorderSide(
                    color: Color(0xff3cb878),
                  ),
                ),
                textColor: Colors.white,
                color: Color(0xff3cb878),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: screenWidth * 0.55,
              height: 48,
              child: FlatButton(
                child: Text(
                  'Ảnh mới mở',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  showHistory();
                },
                padding: new EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(48),
                  side: BorderSide(
                    color: Color(0xff3cb878),
                  ),
                ),
                textColor: Colors.white,
                color: Color(0xff3cb878),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: screenWidth * 0.55,
              height: 48,
              child: FlatButton(
                child: Text(
                  'Chụp Ảnh',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  getImageFromCam();
                },
                padding: new EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(48),
                  side: BorderSide(
                    color: Color(0xff3cb878),
                  ),
                ),
                textColor: Colors.white,
                color: Color(0xff3cb878),
              ),
            ),
          ],
        ),
//        Align(
//          alignment: Alignment.bottomRight,
//          child: IconButton(
//            padding: new EdgeInsets.only(right: 8, bottom: 8),
//            icon: Image.asset(
//              'assets/images/camera_grey.png',
//              width: data.bottomIconSize,
//              height: data.bottomIconSize,
//            ),
//            onPressed: () {
//              getImageFromCam();
//            },
//          ),
//        ),
      ],
    );
  }

  Widget initPanel() {
    colorPicker = BarColorPicker(
      width: screenWidth * 0.7,
      thumbRadius: 10,
      thumbColor: Color(0xff3cb878),
      cornerRadius: 10,
      initialColor: initialColor,
      pickMode: PickMode.Color,
      colorListener: (int value) {
        setState(() {
          applyColor(value);
        });
      },
    );
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => triggerPanel(),
          child: Container(
            width: screenWidth,
            height: data.bottomSizeMin,
            child: Icon(Icons.more_horiz),
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              height: 8,
            ),
            colorPicker,
            Container(
              height: 10,
            ),
            Text(
              'Mầu dòng kẻ',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff848484),
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              width: screenWidth * 0.84,
              child: SliderTheme(
                data: initSliderTheme(),
                child: new Slider(
                  value: count.toDouble(),
                  min: data.boxMin,
                  max: data.boxMax,
                  divisions: 100,
                  label: '${count.round()}',
                  onChanged: (double newValue) {
                    setState(() {
                      applyCount(newValue.round());
                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '${newValue.round()}';
                  },
                ),
              ),
            ),
            Text(
              'Tùy chỉnh dòng kẻ ( $count )',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff848484),
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              width: screenWidth * 0.84,
              child: SliderTheme(
                data: initSliderTheme(),
                child: new Slider(
                  value: lineStroke.toDouble(),
                  min: data.strokeMin,
                  max: data.strokeMax,
                  divisions: 100,
                  label: lineStrokeLabel,
                  onChanged: (double newValue) {
                    setState(() {
                      applyLineStroke(newValue.round());
                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '${newValue.round()}';
                  },
                ),
              ),
            ),
            Text(
              'Kích thước dòng kẻ ( $lineStrokeLabel )',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff848484),
              ),
            ),
            Container(
              height: 24,
            ),
            initPanelAction(),
          ],
        ),
      ],
    );
  }

  Widget initPanelAction() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: IconButton(
            padding: new EdgeInsets.only(
              left: 16.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
            ),
            onPressed: () {
              getImageFromGallery();
            },
            alignment: Alignment.centerLeft,
            icon: Image.asset(
              'assets/images/gallery.png',
              width: data.bottomIconSize,
              height: data.bottomIconSize,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: IconButton(
            padding: new EdgeInsets.only(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
            ),
            onPressed: () {
              triggerTag();
            },
            alignment: Alignment.center,
            icon: Image.asset(
              'assets/images/location.png',
              width: data.bottomIconSize,
              height: data.bottomIconSize,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: IconButton(
            padding: new EdgeInsets.only(
              left: 0.0,
              top: 0.0,
              right: 16.0,
              bottom: 0.0,
            ),
            onPressed: () {
              getImageFromCam();
            },
            alignment: Alignment.centerRight,
            icon: Image.asset(
              'assets/images/camera.png',
              width: data.bottomIconSize,
              height: data.bottomIconSize,
            ),
          ),
        ),
      ],
    );
  }

  SliderThemeData initSliderTheme() {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: Color(0xffcccccc),
      inactiveTrackColor: Color(0xffcccccc),
      trackHeight: 8,
      thumbColor: Color(0xff3cb878),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
    );
  }

  void triggerPanel() {
    if (panelController.isPanelOpen) {
      panelController.close();
      isOpenPanel = false;
    } else {
      panelController.open();
      isOpenPanel = true;
    }
    setState(() {});
  }

  Future<Widget> checkImage() async {
    return new Center(
      child: image == null ? Text('No image selected') : Image.file(image),
    );
  }

  Future<Widget> getImageFromCam() async {
    File origin = await ImagePicker.pickImage(source: ImageSource.camera);
    File image = await ImageCropper.cropImage(sourcePath: origin.path);
    calculatorImage(image);
  }

  Future<Widget> getImageFromGallery() async {
    File origin = await ImagePicker.pickImage(source: ImageSource.gallery);
    File image = await ImageCropper.cropImage(sourcePath: origin.path);
    calculatorImage(image);
  }

  void calculatorImage(File image) {
    getImageProperties(Image.file(image));
    setState(() {
      this.image = image;
      if (original != null) {
        matrix4.value = Matrix4.copy(original);
      }
    });
    saveDrawData(image.path);
  }

  void showHistory() async {
    List<data.DrawData> images = await data.getImages();
    return showDialog(
      context: context,
      barrierDismissible: true,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: (images != null && images.length > 0)
            ? Container(
                height: 300,
                child: GridView.builder(
                  padding: EdgeInsets.all(2),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return new InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        data.DrawData d = images[index];
                        File file = new File(d.path);
                        calculatorImage(file);
                        setState(() {
                          applyCount(d.line);
                          applyLineStroke(d.stroke);
                          applyColor(d.color);
                          initialColor = Color(d.color);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: Image.file(
                          File(images[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('Chưa có ảnh nào'),
              ),
      ),
    );
  }
}
