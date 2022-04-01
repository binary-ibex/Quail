import 'dart:io';
import 'dart:isolate';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quail/helper/dialog_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:quail/view/document_reorder.dart';
import 'package:quail/view/image_process.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/image_processing.dart';

class ApplicationController extends GetxController {
  List<String> images = [];
  int currentImage = 0;
  int filteredPreviewIndex = 0;
  List<String> reOrderedImages = [];
  List<FilteredPreview> filterPreview = [];
  String tempDir = '';

  @override
  onInit() async {
    super.onInit();
    images.clear();
    tempDir = (await getTemporaryDirectory()).path;
  }

  pickFiles() async {
    currentImage = 0;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      images.addAll(result.paths.map((path) => path!));
      update();
    } else {
      // User canceled the picker
    }
  }

  applyFilter() async {
    var receivePort = ReceivePort();
    DialogHelper.showLoading("Applying filter...");
    if (filterPreview[filteredPreviewIndex].key == 'grey_scale') {
      await Isolate.spawn(
          greyScaleIsolate, DecodeParam(images, receivePort.sendPort, tempDir));
    } else if (filterPreview[filteredPreviewIndex].key == 'black_white') {
      await Isolate.spawn(blackandWhiteIsolate,
          DecodeParam(images, receivePort.sendPort, tempDir));
    } else if (filterPreview[filteredPreviewIndex].key ==
        'averaged_grey_scale') {
      await Isolate.spawn(averageGreyScaleIsolate,
          DecodeParam(images, receivePort.sendPort, tempDir));
    } else {
      await Isolate.spawn(invertedBlackAndWhiteScaleIsolate,
          DecodeParam(images, receivePort.sendPort, tempDir));
    }
    images = await receivePort.first as List<String>;
    DialogHelper.hideLoading();
    Get.back();
    update();
  }

  moveToImageProcessingPreviewScreen() async {
    filteredPreviewIndex = 0;
    if (images.isNotEmpty) {
      DialogHelper.showLoading("Preapering preview...");
      var receivePort = ReceivePort();
      await Isolate.spawn(imagePreviewIsolate,
          DecodeParam([images[currentImage]], receivePort.sendPort, tempDir));
      filterPreview = await receivePort.first as List<FilteredPreview>;
      DialogHelper.hideLoading();
      Get.to(() => const ImageProcess());
    } else {
      DialogHelper.hideLoading();
      DialogHelper.showErroDialog(
          description: "select atleast one image to do processing");
    }
  }

  moveToReorderScreen() {
    reOrderedImages = [...images];
    if (images.isNotEmpty && images.length > 1) {
      Get.to(() => const DocumentReorder());
    } else {
      DialogHelper.showErroDialog(
          description: "You need atleast two images to reorder them");
    }
  }

  onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    String item = reOrderedImages.removeAt(oldIndex);
    reOrderedImages.insert(newIndex, item);
    update();
  }

  onReorderApprove() {
    images = [...reOrderedImages];
    currentImage = 0;
    Get.back();
    update();
  }

  incrementImagePreviewCounter() {
    if (filteredPreviewIndex < filterPreview.length - 1) {
      filteredPreviewIndex += 1;
    }
    update();
  }

  decrementPreviewIndex() {
    if (filteredPreviewIndex > 0) {
      filteredPreviewIndex -= 1;
    }
    update();
  }

  incrementImageCounter() {
    if (currentImage < images.length - 1) {
      currentImage += 1;
    }
    update();
  }

  decreamentImageCounter() {
    if (currentImage > 0) {
      currentImage -= 1;
    }
    update();
  }

  captureImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 2480, maxHeight: 3508);
    if (photo != null) {
      images.add(photo.path);
      currentImage = images.indexOf(photo.path);
      update();
    }
  }

  clearAllImages() {
    currentImage = 0;
    images.clear();
    update();
  }

  removeImage(value) {
    images.removeWhere((element) => element == value);
    currentImage = 0;
    update();
  }

  convertImagesToPdf() async {
    final pdf = pw.Document();

    try {
      Directory? appDocDir = await getApplicationDocumentsDirectory();

      String storeFilePath =
          appDocDir.path + '/output${DateTime.now().toIso8601String()}.pdf';
      if (images.isEmpty) {
        DialogHelper.showErroDialog(
            description: "please select the images to generate pdf");
      } else {
        DialogHelper.showLoading();

        for (var image in images) {
          pdf.addPage(pw.Page(
              margin: const pw.EdgeInsets.all(10),
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                    child: pw.Image(
                  pw.MemoryImage(
                    File(image).readAsBytesSync(),
                  ),
                )); // Center
              }));
        }

        final file = File(storeFilePath);
        await file.writeAsBytes(await pdf.save());
        OpenFile.open(storeFilePath);
        DialogHelper.hideLoading();
      }
    } catch (e) {
      DialogHelper.hideLoading();
      DialogHelper.showErroDialog(description: "Unable to generate the pdf");
    }
  }

  appBarMenu(value) async {
    try {
      if (value == 'PRIVACY_POLICY') {
        String _url = "https://sites.google.com/view/quailprivacypolicy";
        if (!await launch(_url)) throw 'Could not launch $_url';
      }
    } catch (e) {
      DialogHelper.showErroDialog(description: e as String);
    }
  }
}
