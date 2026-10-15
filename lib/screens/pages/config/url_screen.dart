import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/config/config_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class UrlSetupScreen extends GetView<ConfigController> {
  @override
  final ConfigController controller = Get.put(ConfigController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UrlSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Center(
            child: SizedBox(
              height: size.height,
              child: Container(
                padding: EdgeInsets.all(Styles.defaultPadding),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Service API", style: Styles.headLineStyle2),
                        SizedBox(height: 10),
                        inputText(controller.hostController,
                            controller.hostValidator, "Host", "127.0.0.1"),
                        SizedBox(height: 10),
                        inputText(controller.portController,
                            controller.portValidator, "Port", "8080"),
                        Obx(() => SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Use HTTPS"),
                              subtitle: const Text(
                                  "Server harus mendukung TLS pada port ini"),
                              value: controller.useHttps.value,
                              onChanged: (v) => controller.useHttps.value = v,
                            )),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.saveConfig(context);
                            }
                          },
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(Size(
                                size.width, Styles.defaultHeightInputField)),
                            foregroundColor:
                                WidgetStateProperty.all<Color>(Colors.white),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Styles.primaryColor),
                            shape: WidgetStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Styles.defaultRadius),
                            )),
                          ),
                          child: controller.connecting.value
                              ? connectingText()
                              : const Text("Connect"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget connectingText() {
    // Specify the return type explicitly
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitWave(
          color: Colors.white,
          size: 10.0,
        ),
        Gap(5),
        Text("Connecting..."),
      ],
    );
  }

  Widget inputText(controller, validator, label, hint) {
    // Specify the return type explicitly
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      // initialValue: controller.host.value,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 33, 28, 28), width: 0.3),
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.primaryColor, width: 0.8),
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        if (validator != null) {
          return validator(value);
        }

        return null;
      },
    );
  }
}
