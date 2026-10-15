import 'package:get/get.dart';
import 'package:point_of_sales/models/order_model.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class OrdersController extends GetxController {
  RxList<Order> orderList = <Order>[].obs;
  RxInt captainOrderId = 0.obs;
  RxString outletCode = "".obs;
  RxString outletName = "".obs;
  RxDouble totalOrderPrice = 0.00.obs;

  loadArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      captainOrderId.value = argumentData[0]["captainOrderId"].value;
      orderList.clear();
      totalPrices();
    }
  }

  void totalPrices() {
    totalOrderPrice.value = 0;
    for (var element in orderList) {
      if (element.price > 0 && element.quantity > 0) {
        totalOrderPrice.value += (element.price * element.quantity);
      }
    }
    totalOrderPrice.refresh();
    orderList.refresh();
  }

  getTotalOrderPriceText() {
    return Formats.formatNumber(totalOrderPrice.value.toString());
  }

  void removeItemFromOrderList(product, isOrder) {
    var code = isOrder ? product.productCode : product.code;
    orderList.removeWhere((element) => element.productCode == code);
    totalPrices();
  }

  void removeItemOrder(product, isOrder) {
    var code = isOrder ? product.productCode : product.code;
    var index = orderList.indexWhere((element) => element.productCode == code);
    if (index >= 0) {
      if (orderList[index].quantity > 1) {
        orderList[index].quantity--;
      } else {
        orderList.remove(orderList[index]);
      }
      totalPrices();
    }
  }

  void addItemOrder(product, isOrder) {
    var code = isOrder ? product.productCode : product.code;
    var name = isOrder ? product.productName : product.name;
    var index = orderList.indexWhere((element) => element.productCode == code);
    if (index >= 0) {
      orderList[index].quantity++;
    } else {
      orderList.add(Order(
          productCode: code,
          productName: name,
          price: product.price,
          quantity: 1,
          categoryCode: product.categoryCode));
    }
    totalPrices();
  }

  void increase(product, isOrder) {
    addItemOrder(product, isOrder);
  }

  void decrease(product, isOrder) {
    removeItemOrder(product, isOrder);
  }
}
