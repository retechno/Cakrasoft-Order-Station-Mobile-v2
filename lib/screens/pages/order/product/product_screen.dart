import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/models/order_model.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/button_order.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';
import 'package:point_of_sales/utils/secure_store.dart';

class ProductScreen extends GetView<ProductController> {
  ProductScreen({Key? key}) : super(key: key);

  // Map<String, Image> productImages = {};

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
                    title:
                        "${controller.updateUIText.value.toString()}${controller.categoryName.value.toString()}"),
                filter(),
                Expanded(
                  child: controller.productListFilters.isNotEmpty
                      ? ListView.builder(
                          itemCount: controller.productListFilters.length,
                          itemBuilder: (context, index) {
                            final product =
                                controller.productListFilters[index];
                            return productItem(context, size, product);
                          },
                        )
                      : const Center(
                          child: Text("No data found"),
                        ),
                ),
                ButtonOrder(
                  context,
                  onProductPage: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card filter() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Styles.defaultRadius),
      ),
      child: Container(
        height: Styles.defaultHeightButton,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
          color: Colors.white,
        ),
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
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 0, top: 7, right: 15),
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Search",
          ),
        ),
      ),
    );
  }

  Widget productItem(BuildContext context, Size size, Products product) {
    final imageLink = product.imageLink.isNotEmpty
        ? controller.productImages[product.imageLink] ??
            Image.asset('assets/images/image.png', width: 45, height: 45)
        : Image.asset('assets/images/image.png', width: 45, height: 45);

    return Card(
      child: Container(
        height: Styles.defaultHeightCard,
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  imageLink,
                  SizedBox(width: 7),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: Styles.textStyle,
                          overflow: TextOverflow.ellipsis,
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
            ),
            buttonAdd(context, size, product),
          ],
        ),
      ),
    );
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
    );

    if (response.statusCode == 200) {
      return Image.memory(response.bodyBytes, width: 45, height: 45);
    } else {
      // Handle error cases, for example, return a placeholder image
      return Image.asset('assets/images/image.png', width: 45, height: 45);
    }
  }

  InkWell addButton(Products product) {
    return InkWell(
      onTap: () {
        controller.updateUI();
        controller.orderController.addItemOrder(product, false);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Styles.primaryColor),
        child: const Text(
          "ADD",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buttonAdd(BuildContext context, size, Products product) {
    if (controller.orderController.orderList.isNotEmpty) {
      int index = controller.orderController.orderList
          .indexWhere((element) => element.productCode == product.code);
      if (index >= 0) {
        return changeQuantityButton(context, size, product,
            controller.orderController.orderList[index]);
      }
    }
    return addButton(product);
  }

  Widget changeQuantityButton(
      BuildContext context, size, Products product, Order orderList) {
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
            child: Row(
              children: [
                Icon(
                  orderList.remark != null
                      ? Icons.edit_note
                      : Icons.note_add_outlined,
                  size: 16,
                ),
                Text(
                  "Notes",
                  style: Styles.textDetailStyle2,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                controller.updateUI();
                controller.orderController.decrease(product, false);
              },
              child: Icon(
                Icons.remove_circle,
                color: Styles.dangerColor,
                size: Styles.changeQuantityButtonSize,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: Colors.white),
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
                    // Use the controller's updateQuantity method to update the quantity
                    // controller.orderController.updateQuantity(orderList, int.parse(value));
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                controller.updateUI();
                controller.orderController.increase(product, false);
              },
              child: Icon(
                Icons.add_circle,
                color: Styles.primaryColor,
                size: Styles.changeQuantityButtonSize,
              ),
            ),
          ],
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
                      hintText: "Example: Make it spicy!",
                    ),
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
                                      Styles.defaultRadius)),
                            ),
                          ),
                          child: const Text('Save'),
                          onPressed: () {
                            orderList.remark = notesController.text;
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
