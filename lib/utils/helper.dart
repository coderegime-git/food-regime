import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  static final Helper _helper = Helper._internal();

  factory Helper() {
    return _helper;
  }

  Helper._internal();

  String validString(String? strText) {
    try {
      if (strText == null) {
        return "";
      }
      if (strText.trim().isEmpty) {
        return "";
      }
      return strText.trim();
    } catch (e) {
      Helper().printMessage(e);
      return "";
    }
  }

  void hideKeyBoard(BuildContext context) {
    try {
      FocusScope.of(context).unfocus();
    } catch (e) {
      Helper().printMessage(e);
    }
  }

  void printMessage(message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  void launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void showToast(context, message, code) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: code == 1 ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 15);
    /* toastification.show(
      context: context,
      type: code == 1 || code == 2
          ? ToastificationType.success
          : ToastificationType.error,
      title: Text(
        message,
        maxLines: 3,
      ),
      showProgressBar: false,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 2),
    );*/
  }

  void closeApp() {
    exit(0);
  }

  Future<Uint8List> getBytesFromCanvas(
      int width, int height, String text, bool isSelect) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = (isSelect ? Colors.teal[900] : Colors.teal)!;
    const Radius radius = Radius.circular(100);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);

    TextPainter painter = TextPainter();
    painter.text = TextSpan(
      text: text,
      style: const TextStyle(fontSize: 20.0, color: Colors.white),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

Future<Uint8List> loadNetworkImage(path) async {
  final completed = Completer<ImageInfo>();
  var image = NetworkImage(path);
  image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((info, _) => completed.complete(info)));
  final imageInfo = await completed.future;
  final byteData =
      await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
