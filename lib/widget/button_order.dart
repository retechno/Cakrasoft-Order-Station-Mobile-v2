import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class ButtonOrder extends StatelessWidget {
  final orderController = Get.find<OrdersController>();
  final productController = Get.find<ProductController>();
  final bool onProductPage;
  final BuildContext parentContext;
  ButtonOrder(this.parentContext, {Key? key, required this.onProductPage})
      : super(key: key);

  getTotalItemBadge() {
    int total = 0;
    for (var element in orderController.orderList) {
      total += int.tryParse(element.quantity.toString()) ?? 0;
    }
    return Text(
      'Order ($total)',
      style: Styles.textButton2,
    );
  }

  void _delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to clear the order list?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    orderController.orderList.clear();
                    orderController.totalPrices();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = AppLayout.getSize(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total",
                    style: Styles.textStyle,
                  ),
                  SizedBox(height: 2),
                  Text(orderController.getTotalOrderPriceText(),
                      style: Styles.headLineStyle4)
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      orderController.orderList.isNotEmpty
                          ? _delete(parentContext)
                          : null;
                    },
                    child: Icon(
                      Icons.delete_outline,
                      color: orderController.orderList.isNotEmpty
                          ? Colors.black
                          : Styles.textInactive,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: () {
                        orderController.orderList.isNotEmpty
                            ? productController.toOrderDetailPage(
                                parentContext, onProductPage)
                            : null;
                      },
                      style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all<Size>(
                              Size(size.width / 3, 38)),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              orderController.orderList.isNotEmpty
                                  ? Styles.primaryColor
                                  : Styles.disabledColor),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Styles.defaultRadius),
                          ))),
                      child: getTotalItemBadge()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
