import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/setting/setting_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class SettingScreen extends GetView<SettingController> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);

    return Obx(
      () => Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: size.height - 100,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Set Default Outlet",
                                style: Styles.headLineStyle2,
                              ),
                              SizedBox(height: 10),
                              outlets(),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (controller.outletCode.isEmpty) return;
                                  controller.saveSetting();
                                },
                                style: ButtonStyle(
                                    minimumSize:
                                        WidgetStateProperty.all<Size>(Size(
                                            size.width,
                                            Styles.defaultHeightButton)),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            Styles.primaryColor),
                                    shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Styles.defaultRadius),
                                    ))),
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Card outlets() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.defaultRadius)),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        height: Styles.defaultHeightButton,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Styles.defaultRadius),
            color: Colors.white),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            style: Styles.textStyle,
            hint: const Text(
              "Select Outlet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: "verdana_regular",
              ),
            ),
            items: controller.outletList.map((map) {
              return DropdownMenuItem<String>(
                value: map.code,
                child: Text(map.name,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList(),
            isExpanded: true,
            isDense: true,
            value: controller.outletCode.value,
            onChanged: (val) {
              controller.outletCode.value = val.toString();
              // _onRefresh();
            },
          ),
        ),
      ),
    );
  }
}
