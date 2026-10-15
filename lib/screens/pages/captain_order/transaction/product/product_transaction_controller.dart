import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_navigation.dart';
import 'package:point_of_sales/utils/request.dart';

class ProductTransactionController extends GetxController {
  TextEditingController filterController = TextEditingController();
  RxString outletCode = Get.find<OrdersController>().outletCode;
  RxList<Products> productList = <Products>[].obs;
  RxList<Products> productListFilters = <Products>[].obs;

  RxInt id = 0.obs;
  RxString categoryCode = "".obs;
  RxString categoryName = "".obs;
  void toOrderDetailPage(context, onProductPage) {
    onProductPage ? Navigator.popAndPushNamed(context, OrdersNavigation.orders) : Get.toNamed(OrdersNavigation.orders);
  }

  void loadProductList() async {
    Request request = Request(url: 'GetProducts?categoryCode=$categoryCode&outletCode=$outletCode');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"];
        productList.value = jsonResponse.map((e) => Products.fromJson(e)).toList();
        filterProduct();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  void filterProduct() {
    List<Products> result = [];
    if (filterController.text.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      result = productList;
    } else {
      result = productList
          .where((category) => category.name.toLowerCase().contains(filterController.text.toLowerCase()))
          .toList();
    }
    productListFilters.value = result;
  }
}
