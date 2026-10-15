import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/home/home_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();
  int tabIndex = 0;
  int currentIndex = 0;
  Color inActiveColor = Colors.grey;

  void changeTabIndex(int index) {
    tabIndex = index;
    if (tabIndex == 1) {
      // Order
      var captainOrderController = Get.find<OrdersController>();
      captainOrderController.captainOrderId.value = 0;
    } else if (tabIndex == 0) {
      // Dashboard
      var homeController = Get.find<HomeController>();
      homeController.loadData();
    } else if (tabIndex == 2) {
      //Captain Order List
      var captainOrderItemController = Get.find<CaptainOrderItemController>();
      captainOrderItemController.loadCaptainOrderList();
    }
    update();
  }

  // Navigator key 생성
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> onWillPop() async {
    return !await navigatorKey.currentState!.maybePop();
  }

  Future<bool> _promptExit(context) async {
    bool canExit = false;

    var dlg = showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to clear the order list?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    canExit = true;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    canExit = false;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
    await dlg;
    return Future.value(canExit);
  }
}
