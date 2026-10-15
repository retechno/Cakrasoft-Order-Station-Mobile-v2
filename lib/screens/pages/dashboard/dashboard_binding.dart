import 'package:get/instance_manager.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/screens/pages/order/category/category_controller.dart';
import 'package:point_of_sales/screens/pages/dashboard/dashboard_controller.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CaptainOrderItemController>(() => CaptainOrderItemController());
    Get.lazyPut(() => PaymentMethodController());
  }
}
