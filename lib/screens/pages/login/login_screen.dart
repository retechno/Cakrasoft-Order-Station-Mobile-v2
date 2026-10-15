import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/login/login_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/uppercase_formatter.dart';

class LoginScreen extends GetView<LoginController> {
  @override
  final LoginController controller = Get.put(LoginController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({Key? key}) : super(key: key);

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
                  Container(
                      alignment: Alignment.topRight,
                      child: InkWell(
                          onTap: () => Get.offAndToNamed("/urlSetup"),
                          child: const Icon(Icons.settings_outlined))),
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
                                "Sign In",
                                style: Styles.headLineStyle2,
                              ),
                              Text(
                                "Welcome back",
                                style: Styles.textDetailStyle,
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                inputFormatters: [UpperCaseTextFormatter()],
                                style: Styles.textStyle,
                                controller: controller.userIDController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(5, 15, 5, 0),
                                  hintText: "User ID",
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                ),
                                validator: (String? value) {
                                  if (value!.trim().isEmpty) {
                                    return 'User ID is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 5),
                              TextFormField(
                                  style: Styles.textStyle,
                                  onFieldSubmitted: (value) {
                                    if (_formKey.currentState!.validate()) {
                                      controller.login(context);
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  obscureText: controller.hidePassword.value,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  controller: controller.passwordController,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          5, 15, 5, 0),
                                      hintText: "Password",
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: InkWell(
                                          onTapDown: (detail) {
                                            controller.toggleShowPassword();
                                          },
                                          onTapUp: (detail) {
                                            controller.toggleShowPassword();
                                          },
                                          child: const Icon(
                                              Icons.remove_red_eye_outlined))),
                                  validator: (String? value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password is too short.';
                                    }
                                    return null;
                                  }),
                              SizedBox(height: 10),
                              IntrinsicWidth(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Shift: ', // Label text
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: DropdownButtonFormField<String>(
                                            initialValue: controller.shift.value,
                                            onChanged: (String? newValue) {
                                              if (controller
                                                  .shiftDisabled.value) {
                                              } else {
                                                controller.shift.value =
                                                    newValue!;
                                              }
                                            },
                                            items: ['A', 'B', 'C', 'D']
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            validator: (String? value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Shift is required';
                                              }
                                              return null;
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    controller.login(context);
                                  }
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
                                child: const Text("Login"),
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
}
