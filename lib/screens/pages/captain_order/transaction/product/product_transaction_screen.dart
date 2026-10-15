import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/product/product_transaction_controller.dart';
import 'package:point_of_sales/models/order_model.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/button_order.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class ProductTransactionScreen extends GetView<ProductTransactionController> {
  OrdersController orderController = Get.put(OrdersController());

  ProductTransactionScreen({Key? key}) : super(key: key);

  Future<void> _pullRefresh() async {
    controller.loadProductList();
  }

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Styles.bgColor,
        body: Obx(
          () => RefreshIndicator(
            onRefresh: _pullRefresh,
            child: Container(
              padding: Styles.paddingBody,
              child: Column(
                children: [
                  TitleHeaderWidget(context,
                      title: controller.categoryName.value),
                  filter(),
                  Expanded(
                      child: controller.productListFilters.isNotEmpty
                          ? ListView(
                              children: List.generate(
                                  controller.productListFilters.length,
                                  (index) {
                              return productItem(context, size,
                                  controller.productListFilters[index]);
                            }))
                          : const Center(
                              child: Text("No data found"),
                            )),
                  ButtonOrder(
                    context,
                    onProductPage: true,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Card filter() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.defaultRadius)),
      child: Container(
          padding: const EdgeInsets.only(left: 15, right: 0, top: 4, bottom: 4),
          height: Styles.defaultHeightButton,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Styles.defaultRadius),
              color: Colors.white),
          child: TextFormField(
            controller: controller.filterController,
            onChanged: (value) {
              controller.filterProduct();
            },
            cursorColor: Colors.black,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.search),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Search"),
          )),
    );
  }

  Card productItem(context, size, dynamic product) {
    return Card(
      child: Container(
          height: Styles.defaultHeightCard,
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Image(
                    image: AssetImage('assets/images/image.png'),
                    height: 40,
                    width: 40,
                  ),
                  SizedBox(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          product.name,
                          style: Styles.textStyle,
                        ),
                        Text(
                          Formats.formatNumber(product.price.toString()),
                          style: Styles.textDetailStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              buttonAdd(context, size, product)
            ],
          )),
    );
  }

  InkWell addButton(dynamic product) {
    return InkWell(
      onTap: () {
        orderController.addItemOrder(product, false);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Styles.primaryColor),
        child: const Text(
          "Add",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  buttonAdd(context, size, dynamic product) {
    if (orderController.orderList.isNotEmpty) {
      int index = orderController.orderList
          .indexWhere((element) => element.productCode == product.code);
      if (index >= 0) {
        return changeQuantityButton(
            context, size, product, orderController.orderList[index]);
      }
    }
    return addButton(product);
  }

  Row changeQuantityButton(context, size, dynamic product, Order orderList) {
    TextEditingController notesController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    quantityController.text =
        orderList.quantity > 1 ? orderList.quantity.toString() : "1";
    notesController.text = orderList.remark ?? "";
    return Row(
      children: [
        InkWell(
          onTap: () {
            showModalBottomNotes(context, size, notesController, orderList);
          },
          child: Container(
              height: 24,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey)),
              child: Row(children: [
                Icon(
                  orderList.remark != null
                      ? Icons.edit_note
                      : Icons.note_add_outlined,
                  size: 16,
                ),
                Text(
                  "Notes",
                  style: Styles.textDetailStyle2,
                )
              ])),
        ),
        SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Styles.primaryColor),
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    orderController.decrease(product, false);
                  },
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  )),
              Container(
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white),
                child: IntrinsicWidth(
                  child: TextField(
                    style: Styles.textStyle,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: orderList.quantity.toString(),
                        selection: TextSelection.collapsed(
                            offset: orderList.quantity.toString().length),
                      ),
                    ),
                    decoration: null,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      orderList.quantity =
                          value.isNotEmpty ? int.parse(value) : 1;
                      orderController.totalPrices();
                    },
                  ),
                ),
              ),
              InkWell(
                  onTap: () {
                    orderController.increase(product, false);
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> showModalBottomNotes(
      context, size, TextEditingController notesController, Order orderList) {
    return showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                children: <Widget>[
                  Text(
                    "Add notes",
                    style: Styles.headLineStyle,
                  ),
                  const Divider(),
                  TextFormField(
                    // autofocus: true,
                    controller: notesController,
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        // contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Example: Make it spicy!"),
                    maxLength: 200,
                    minLines:
                        8, // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const Divider(),
                  SizedBox(
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Styles.primaryColor),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Styles.defaultRadius)))),
                          child: const Text('Save'),
                          onPressed: () {
                            orderList.remark = notesController.text;
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
