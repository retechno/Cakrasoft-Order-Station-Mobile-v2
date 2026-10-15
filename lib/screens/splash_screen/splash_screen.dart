import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/splash_screen/splash_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends GetView<SplashScreenController> {
  final SplashScreenController controller = Get.find<SplashScreenController>();
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    const spinkit = SpinKitWave(
      color: Colors.white,
      size: 20.0,
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 120, 1),
      body: Center(
        child: SizedBox(
          height: size.height / 2,
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: size.width / 3,
                  width: size.width / 3,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100)),
                  child: SizedBox(
                    width: size.width / 4,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Image(
                        image: const AssetImage("assets/images/logo.png"),
                        width: size.width / 5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                const Text(
                  "Cakrasoft Point of Sales",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                spinkit
              ],
            ),
          ),
        ),
      ),
    );
  }
}
