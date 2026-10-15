import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_navigation.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sales/utils/secure_store.dart';

class ProductController extends GetxController {
  OrdersController orderController = Get.put(OrdersController());
  TextEditingController filterController = TextEditingController();
  RxString outletCode = Get.find<OrdersController>().outletCode;
  RxList<Products> productList = <Products>[].obs;
  RxList<Products> productListFilters = <Products>[].obs;

  RxInt id = 0.obs;
  RxString categoryCode = "".obs;
  RxString categoryName = "".obs;
  RxString updateUIText = "".obs;

  RxMap<String, Image> productImages = <String, Image>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductImages();
  }

  // Link yang sedang/sudah diambil: cegah fetch ganda tiap ketikan filter.
  final Set<String> _requestedImages = <String>{};

  Future<void> fetchProductImages() async {
    for (var product in List<Products>.from(productListFilters)) {
      final link = product.imageLink;
      if (link.isEmpty ||
          link.startsWith("assets/") ||
          containsHttpOrHttps(link) ||
          productImages.containsKey(link) ||
          _requestedImages.contains(link)) {
        continue;
      }
      _requestedImages.add(link);
      try {
        productImages[link] = await fetchImage(link);
      } catch (e) {
        // gagal: izinkan dicoba lagi pada pemanggilan berikutnya
        _requestedImages.remove(link);
      }
    }
  }

  bool containsHttpOrHttps(String input) {
    return input.contains("http://") || input.contains("https://");
  }

  Future<Image> fetchImage(String imageLink) async {
    final String token = await TokenStore.read();
    final urlBase = '${await ServerConfig.baseUrl()}Image/';
    final url = Uri.parse(urlBase + imageLink);
    // Send a GET request with the required headers
    final response = await http.get(
      url,
      headers: {"token": token},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes, width: 45, height: 45);
    } else {
      // Handle error cases, for example, return a placeholder image
      return Image.asset('assets/images/image.png', width: 45, height: 45);
    }
  }

  void toOrderDetailPage(context, onProductPage) {
    onProductPage
        ? Navigator.popAndPushNamed(context, OrdersNavigation.orders)
        : Get.toNamed(OrdersNavigation.orders);
  }

  void loadProductList() async {
    Request request = Request(
        url: 'GetProducts?categoryCode=$categoryCode&outletCode=$outletCode');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"];
        productList.value =
            jsonResponse.map((e) => Products.fromJson(e)).toList();
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
          .where((category) => category.name
              .toLowerCase()
              .contains(filterController.text.toLowerCase()))
          .toList();
    }
    productListFilters.value = result;
    fetchProductImages();
  }

  updateUI() {
    if (updateUIText.isEmpty) {
      updateUIText.value = ".";
    } else {
      updateUIText.value = "";
    }
  }
}
