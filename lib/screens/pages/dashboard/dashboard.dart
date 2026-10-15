import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/dashboard/dashboard_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_screen.dart';
import 'package:point_of_sales/screens/pages/home/home_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_wrapper.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class Dashboard extends GetView<DashboardController> {
  const Dashboard({Key? key}) : super(key: key);

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    // TableScreen(),
    const OrdersWrapper(),
    CaptainOrderScreen()
  ];

  Future<bool> _promptExit(context) async {
    bool canExit = false;

    AwesomeDialog dlg = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.bottomSlide,
        title: "Exit",
        desc: "Are you sure to exit?",
        dismissOnTouchOutside: true,
        btnCancelOnPress: () => canExit = false,
        btnOkOnPress: () => canExit = true,
        btnOkText: "Yes",
        btnCancelText: "No");

    await dlg.show();
    return Future.value(canExit);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _promptExit(context);
      },
      child: GetBuilder<DashboardController>(builder: (controller) {
        return Scaffold(
          body: SafeArea(
              child: IndexedStack(
                  index: controller.tabIndex, children: _widgetOptions)),
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: controller.tabIndex,
              elevation: 10,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedItemColor: Colors.black,
              unselectedItemColor: Styles.primaryColor,
              // type: BottomNavigationBarType.fixed,
              onTap: controller.changeTabIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                // BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Table"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart), label: "Orders"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.file_present), label: "CO")
              ]),
        );
      }),
    );
  }
}
