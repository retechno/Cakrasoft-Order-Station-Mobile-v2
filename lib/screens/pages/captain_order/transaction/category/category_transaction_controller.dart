import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/models/category_model.dart';
import 'package:point_of_sales/models/outlet_model.dart';
import 'package:point_of_sales/screens/pages/order/orders_navigation.dart';
import 'package:point_of_sales/utils/request.dart';

class CategoryTransactionController extends GetxController {
  RxList<Categories> categoryList = <Categories>[].obs;
  RxList<Categories> categoryListFilters = <Categories>[].obs;
  RxList<Outlets> outletList = <Outlets>[].obs;
  RxString name = "".obs;
  TextEditingController filterController = TextEditingController();

  final ProductController productController = Get.put(ProductController());

  var orderController = Get.find<OrdersController>();

  RxInt id = 0.obs;
  RxString outletCode = "NE".obs; //default outlet
  RxString categoryCode = "".obs;
  RxString outletName = "".obs;

  @override
  void onReady() {
    loadOutlets();
    loadCategoryList();
  }

  void toProductPage() async {
    productController.filterController.clear();
    productController.loadProductList();
    Get.toNamed(OrdersNavigation.products);
  }

  void loadCategoryList() async {
    Request request = Request(url: 'Categories?code=$outletCode');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"];
        categoryList.value = jsonResponse.map((e) => Categories.fromJson(e)).toList();
        filterCategory();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  void loadOutlets() async {
    Request request = Request(url: 'Outlets');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"];
        outletList.value = jsonResponse.map((e) => Outlets.fromJson(e)).toList();
        for (var element in outletList) {
          if (element.code == outletCode.value) {
            outletName.value = element.name;
          }
        }
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  void filterCategory() {
    List<Categories> result = [];
    if (filterController.text.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      result = categoryList;
    } else {
      result = categoryList
          .where((category) => category.name.toLowerCase().contains(filterController.text.toLowerCase()))
          .toList();
    }
    categoryListFilters.value = result;
  }
}
