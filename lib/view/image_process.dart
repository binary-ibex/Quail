import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail/controller/application_controller.dart';

class ImageProcess extends StatelessWidget {
  const ImageProcess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApplicationController>(
        init: ApplicationController(),
        builder: (controller) {
          return Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: controller.decrementPreviewIndex,
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
                        child: GestureDetector(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: Get.height * 0.8,
                                    maxWidth: Get.width * .8),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10)
                                ]),
                                margin: const EdgeInsets.only(
                                    top: 40.0, bottom: 20),
                                child: Image.file(File(controller
                                    .filterPreview[
                                        controller.filteredPreviewIndex]
                                    .filePath)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(controller
                                    .filterPreview[
                                        controller.filteredPreviewIndex]
                                    .filterName),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.incrementImagePreviewCounter,
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
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(
                              Icons.highlight_off_outlined,
                              size: 40,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.applyFilter,
                            child: const Icon(
                              Icons.check_circle_outlined,
                              size: 40,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }
}
