import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail/controller/application_controller.dart';

class DocumentReorder extends StatelessWidget {
  const DocumentReorder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApplicationController>(
        init: ApplicationController(),
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: BottomAppBar(
                child: Container(
                    padding: const EdgeInsets.all(30),
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
                          onTap: controller.onReorderApprove,
                          child: const Icon(
                            Icons.check_circle_outlined,
                            size: 40,
                          ),
                        ),
                      ],
                    ))),
            body: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: ReorderableListView(
                onReorder: controller.onReorder,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: <Widget>[
                  for (int index = 0;
                      index < controller.reOrderedImages.length;
                      index += 1)
                    Container(
                      height: 100,
                      width: 70,
                      key: Key('$index'),
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                      child:
                          Image.file(File(controller.reOrderedImages[index])),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
