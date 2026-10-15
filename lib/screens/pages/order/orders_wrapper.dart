import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/order/category/category_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_page.dart';
import 'package:point_of_sales/screens/pages/order/orders_navigation.dart';
import 'package:point_of_sales/screens/pages/order/product/product_screen.dart';

class OrdersWrapper extends StatelessWidget {
  const OrdersWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(OrdersNavigation.id),
      onGenerateRoute: (route) {
        switch (route.name) {
          case OrdersNavigation.categories:
            return GetPageRoute(
              routeName: OrdersNavigation.categories,
              page: () => CategoryScreen(),
            );
          case OrdersNavigation.products:
            return GetPageRoute(
              routeName: OrdersNavigation.products,
              page: () => ProductScreen(),
            );
          case OrdersNavigation.orders:
            return GetPageRoute(
              routeName: OrdersNavigation.orders,
              page: () => OrderDetailScreen(),
            );

          default:
            return GetPageRoute(
              routeName: OrdersNavigation.orders,
              page: () => CategoryScreen(),
            );
        }
      },
    );
  }
}
