import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:image/image.dart';

String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class FilteredPreview {
  String filePath;
  String key;
  String filterName;

  FilteredPreview({this.filePath = '', this.filterName = '', this.key = ''});
}

class DecodeParam {
  final String tempDir;
  final List<String> images;
  final SendPort sendPort;
  DecodeParam(this.images, this.sendPort, this.tempDir);
}

Image blackAndWhite(Image src, int threshold) {
  final p = src.getBytes();
  for (var i = 0, len = p.length; i < len; i += 4) {
    if (p[i] < threshold) {
      p[i] = 0;
      p[i + 1] = 0;
      p[i + 2] = 0;
    } else {
      p[i] = 250;
      p[i + 1] = 250;
      p[i + 2] = 250;
    }
  }
  return src;
}

Image invertedblackAndWhite(Image src, int threshold) {
  final p = src.getBytes();
  for (var i = 0, len = p.length; i < len; i += 4) {
    if (p[i] < threshold) {
      p[i] = 250;
      p[i + 1] = 250;
      p[i + 2] = 250;
    } else {
      p[i] = 0;
      p[i + 1] = 0;
      p[i + 2] = 0;
    }
  }
  return src;
}

Image averageFilter(Image src) {
  final p = src.getBytes();
  for (var i = 0, len = p.length; i < len; i += 4) {
    final l = ((p[i] + p[i + 1] + p[i + 2]) / 3).round();
    p[i] = l;
    p[i + 1] = l;
    p[i + 2] = l;
  }
  return src;
}

void greyScaleIsolate(DecodeParam param) {
  List<String> results = [];
  for (String imagePath in param.images) {
    File file = File(imagePath);
    var image = decodeImage(file.readAsBytesSync())!;
    Image image1 = grayscale(image);
    String outputPath = param.tempDir + getRandomString(10) + ".jpg";
    File(outputPath).writeAsBytesSync(encodeJpg(image1));
    results.add(outputPath);
  }
  param.sendPort.send(results);
}

void blackandWhiteIsolate(DecodeParam param) {
  List<String> results = [];
  for (String imagePath in param.images) {
    File file = File(imagePath);
    var image = decodeImage(file.readAsBytesSync())!;
    Image image1 = blackAndWhite(image, 100);
    String outputPath = param.tempDir + getRandomString(10) + ".jpg";
    File(outputPath).writeAsBytesSync(encodeJpg(image1));
    results.add(outputPath);
  }
  param.sendPort.send(results);
}

void averageGreyScaleIsolate(DecodeParam param) {
  List<String> results = [];
  for (String imagePath in param.images) {
    File file = File(imagePath);
    var image = decodeImage(file.readAsBytesSync())!;
    Image image1 = averageFilter(image);
    String outputPath = param.tempDir + getRandomString(10) + ".jpg";
    File(outputPath).writeAsBytesSync(encodeJpg(image1));
    results.add(outputPath);
  }
  param.sendPort.send(results);
}

void invertedBlackAndWhiteScaleIsolate(DecodeParam param) {
  List<String> results = [];
  for (String imagePath in param.images) {
    File file = File(imagePath);
    var image = decodeImage(file.readAsBytesSync())!;
    Image image1 = invertedblackAndWhite(image, 100);
    String outputPath = param.tempDir + getRandomString(10) + ".jpg";
    File(outputPath).writeAsBytesSync(encodeJpg(image1));
    results.add(outputPath);
  }
  param.sendPort.send(results);
}

void imagePreviewIsolate(DecodeParam param) {
  var image = decodeImage(File(param.images[0]).readAsBytesSync())!;
  List<FilteredPreview> results = [];

  Image image1 = grayscale(image.clone());
  String filePath = "${param.tempDir}/${getRandomString(10)}.jpg";
  File(filePath).writeAsBytesSync(encodeJpg(image1));
  results.add(FilteredPreview(
      filePath: filePath, key: 'grey_scale', filterName: "grey scaled"));

  Image image2 = blackAndWhite(image.clone(), 100);
  filePath = "${param.tempDir}/${getRandomString(10)}.jpg";
  File(filePath).writeAsBytesSync(encodeJpg(image2));
  results.add(FilteredPreview(
      filePath: filePath, key: 'black_white', filterName: "black and white"));
  Image image3 = averageFilter(image.clone());
  filePath = "${param.tempDir}/${getRandomString(10)}.jpg";
  File(filePath).writeAsBytesSync(encodeJpg(image3));
  results.add(FilteredPreview(
      filePath: filePath,
      key: 'averaged_grey_scale',
      filterName: "averaged grey scaled"));
  Image image4 = invertedblackAndWhite(image.clone(), 100);
  filePath = "${param.tempDir}/${getRandomString(10)}.jpg";
  File(filePath).writeAsBytesSync(encodeJpg(image4));
  results.add(FilteredPreview(
      filePath: filePath,
      key: 'inverted_black_white',
      filterName: "inverted black and white"));
  param.sendPort.send(results);
}
