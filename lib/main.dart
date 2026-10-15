import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_screen.dart';
import 'package:point_of_sales/screens/pages/config/config_controller.dart';
import 'package:point_of_sales/screens/pages/config/url_screen.dart';
import 'package:point_of_sales/screens/pages/dashboard/dashboard.dart';
import 'package:point_of_sales/screens/pages/dashboard/dashboard_binding.dart';
import 'package:point_of_sales/screens/pages/login/login_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_page.dart';
import 'package:point_of_sales/screens/pages/order/product/product_screen.dart';
import 'package:point_of_sales/screens/pages/setting/setting_binding.dart';
import 'package:point_of_sales/screens/pages/setting/setting_screen.dart';
import 'package:point_of_sales/screens/splash_screen/splash_binding.dart';
import 'package:point_of_sales/screens/splash_screen/splash_screen.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String host = "";

  _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      host = prefs.getString("host") ?? "";
    });
  }

  @override
  void initState() {
    _loadConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Point of Sales',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Styles.bgColor,
          primarySwatch: Colors.blueGrey,
        ),
        initialRoute: "/splash",
        initialBinding: SplashBinding(),
        getPages: [
          GetPage(
              name: '/splash',
              page: () => SplashScreen(),
              binding: SplashBinding()),
          GetPage(
              name: '/setting',
              page: () => SettingScreen(),
              binding: SettingBinding()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(
              name: '/',
              page: () => const Dashboard(),
              binding: DashboardBinding()),
          GetPage(name: '/products', page: () => ProductScreen()),
          GetPage(name: '/orders', page: () => OrderDetailScreen()),
          GetPage(
              name: '/captainOrderTransaction',
              page: () => CaptainOrderTransactionScreen()),
          GetPage(
              name: '/urlSetup',
              page: () => UrlSetupScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<ConfigController>(
                  () => ConfigController(),
                );
              }))
        ]);
  }
}
