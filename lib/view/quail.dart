import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail/controller/application_controller.dart';

class Quail extends StatelessWidget {
  const Quail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetBuilder<ApplicationController>(
          init: ApplicationController(),
          builder: (controller) {
            return Scaffold(
              backgroundColor: const Color(0xfff7f7f7),
              bottomNavigationBar: BottomAppBar(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: controller.moveToReorderScreen,
                            child: const Icon(
                              Icons.layers_outlined,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.clearAllImages,
                            child: const Icon(
                              Icons.delete_outline_outlined,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                controller.moveToImageProcessingPreviewScreen,
                            child: const Icon(
                              Icons.palette_outlined,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.captureImage,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Color.fromARGB(255, 86, 54, 161),
                                    Color.fromARGB(255, 195, 37, 216),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.pickFiles,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Color.fromARGB(255, 86, 54, 161),
                                    Color.fromARGB(255, 195, 37, 216),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.collections_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ))),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: PopupMenuButton(
                    offset: Offset(0.0, appBarHeight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: const Icon(
                      Icons.more_vert_outlined,
                      color: Colors.black,
                    ),
                    onSelected: controller.appBarMenu,
                    itemBuilder: (context) => [
                          const PopupMenuItem(
                            child: Text("Privacy policy"),
                            value: "PRIVACY_POLICY",
                          ),
                        ]),
                actions: [
                  if (controller.images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            primary: const Color(0xff3731d6)),
                        onPressed: controller.convertImagesToPdf,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.done_all,
                              color: Color(0xff3731d6),
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Done"),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              body: SizedBox(
                height: Get.height,
                width: Get.width,
                child: controller.images.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Hey,it looks like you don't have any files here yet!",
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Hit the camera button to select the image file",
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: controller.decreamentImageCounter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chevron_left_outlined,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.black,
                                  constraints: BoxConstraints(
                                      maxHeight: Get.height * .5,
                                      maxWidth: Get.width * .8),
                                  margin: const EdgeInsets.only(
                                      top: 40.0, bottom: 40),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.file(
                                          File(controller
                                              .images[controller.currentImage]),
                                          gaplessPlayback: true),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.removeImage(
                                                controller.images[
                                                    controller.currentImage]);
                                          },
                                          child: Container(
                                            decoration: const ShapeDecoration(
                                                color: Colors.black,
                                                shape: StadiumBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: Colors.black))),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.0, right: 10),
                                                  child: Text(
                                                    "clear",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.incrementImageCounter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chevron_right_outlined,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            );
          }),
    );
  }
}
