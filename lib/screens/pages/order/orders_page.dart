import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_screen.dart';
import 'package:point_of_sales/screens/pages/order/category/category_controller.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class OrderDetailScreen extends GetView<OrdersController> {
  OrderDetailScreen({Key? key}) : super(key: key);

  final ProductController productController = Get.put(ProductController());
  final CategoryController categoryController = Get.put(CategoryController());
  final CaptainOrderController captainOrderController =
      Get.put(CaptainOrderController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _loadDropdownData() async {
    if (controller.captainOrderId.value > 0) {
      captainOrderController.loadCaptainOrder(controller.captainOrderId.value);
    }
    captainOrderController.loadDropdown();
    if (captainOrderController.outletCode.isNotEmpty) {
      captainOrderController.loadTables();
    }
  }

  Future<void> _saveCaptainOrder(BuildContext context) async {
    int statusCode = await captainOrderController.createCaptainOrder(
        context, controller.captainOrderId.value);
    if (statusCode != 0) {
      return;
    }
    if (!context.mounted) return;
    controller.orderList.clear();
    controller.totalPrices();
    controller.captainOrderId.value = 0;
    Navigator.of(context).popUntil((route) => route.isFirst);
    Get.to(() => CaptainOrderTransactionScreen());
  }

  Future<void> _toCategoryPage(context) async {
    Navigator.of(context).pop();
    // Navigator.pushNamed(context, OrdersNavigation.categories);
    // Get.toNamed(OrdersNavigation.categories, id: OrdersNavigation.id);
    // Get.toNamed(OrdersNavigation.categories);
  }

  list(context, size) {
    if (controller.orderList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Order list is empty"),
            ElevatedButton.icon(
                onPressed: () {
                  _toCategoryPage(context);
                },
                style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(
                        Size(size.width / 3, Styles.defaultHeightButton)),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Styles.primaryColor),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Styles.defaultRadius),
                    ))),
                icon: const Icon(Icons.add),
                label: const Text("Add Items"))
          ],
        ),
      );
    }

    return ListView(
        children: List.generate(controller.orderList.length, (index) {
      return itemList(context, size, controller.orderList[index]);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: Obx(
        () => Container(
          width: size.width,
          padding: Styles.paddingBody,
          child: Column(
            children: [
              TitleHeaderWidget(
                context,
                title: controller.captainOrderId > 0
                    ? "Add Item CO#${controller.captainOrderId}"
                    : "New Order List",
                titleDetail: categoryController.outletName.value,
                child: InkWell(
                  onTap: () {
                    _toCategoryPage(context);
                  },
                  child: Row(
                    children: const [Icon(Icons.add), Text("Add Item")],
                  ),
                ),
              ),
              SizedBox(
                width: size.width,
                child: Text(
                  "Order Info",
                  textAlign: TextAlign.start,
                  style: Styles.headLineStyle4,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Items",
                    style: Styles.textDetailStyle2,
                  ),
                  Text(
                    "Price",
                    style: Styles.textDetailStyle2,
                  )
                ],
              ),
              Expanded(child: list(context, size)),
              SizedBox(height: 15),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 8),
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
                        Text(
                          controller.getTotalOrderPriceText(),
                          style: Styles.headLineStyle4,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _delete(context);
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: controller.orderList.isNotEmpty
                                ? Colors.black
                                : Styles.textInactive,
                          ),
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () {
                              displayDialogCaptainOrderForm(context, size);
                            },
                            style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all<Size>(
                                    Size(size.width / 3,
                                        Styles.defaultHeightButton)),
                                foregroundColor:
                                    WidgetStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(controller
                                            .orderList.isNotEmpty
                                        ? Styles.primaryColor
                                        : Styles.disabledColor),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Styles.defaultRadius),
                                ))),
                            child: const Text("Confirm")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void displayDialogCaptainOrderForm(context, size) async {
    await _loadDropdownData();
    showCaptainOrderForm(context, size);
  }

  Card itemList(BuildContext context, size, orderList) {
    return Card(
      child: Container(
        width: size.width,
        height: Styles.defaultHeightCard,
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(children: [
                const Image(
                  image: AssetImage('assets/images/image.png'),
                  height: 45,
                  width: 45,
                ),
                SizedBox(width: 7),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderList.productName,
                        style: Styles.textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      changeQuantityButton(context, orderList),
                    ],
                  ),
                ),
              ]),
            ),
            Row(children: [
              Text(
                Formats.formatNumber(
                    (orderList.quantity * orderList.price).toString()),
                style: Styles.textStyle,
              ),
              IconButton(
                icon: const Icon(Icons.cancel_rounded),
                color: Styles.disabledColor,
                onPressed: () {
                  controller.removeItemFromOrderList(orderList, true);
                },
              ),
            ])
          ],
        ),
      ),
    );
  }

  Container changeQuantityButton(BuildContext context, orderList) {
    return Container(
      padding: const EdgeInsets.all(1),
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Styles.primaryColor),
      child: Row(
        children: [
          InkWell(
              onTap: () {
                controller.decrease(orderList, true);
              },
              child: Icon(
                Icons.remove_circle,
                color: orderList.quantity > 1
                    ? Styles.dangerColor
                    : Styles.disabledColor,
                size: Styles.changeQuantityButtonSize,
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3), color: Colors.white),
            child: Text(
              orderList.quantity.toString(),
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
          InkWell(
              onTap: () {
                controller.increase(orderList, true);
              },
              child: Icon(
                Icons.add_circle,
                color: Styles.primaryColor,
                size: Styles.changeQuantityButtonSize,
              )),
        ],
      ),
    );
  }

  inputAdultChild(BuildContext context, String label, RxInt data) {
    return SizedBox(
      width: 110,
      child: Row(
        children: [
          Text(label, style: Styles.textDetailStyle2),
          SizedBox(height: 5),
          InkWell(
              onTap: () {
                if (data.value > 0) {
                  data.value--;
                }
              },
              child: Icon(
                Icons.remove_circle,
                color: data.value > 0 ? Colors.red : Styles.disabledColor,
                size: 24,
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3), color: Colors.white),
            child: Text(
              data.value.toString(),
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
          InkWell(
              onTap: () {
                data.value++;
              },
              child: Icon(
                Icons.add_circle,
                color: Styles.primaryColor,
                size: 24,
              )),
        ],
      ),
    );
  }

  TextFormField inputFormField(
      label, TextEditingController controller, bool validate,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      ),
      validator: (value) {
        if (!validate) return null;
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      },
    );
  }

  Column dropdownInputForm(dynamic dropdownValue, List items, label, disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
            isExpanded: true,
            decoration: InputDecoration(
                labelText: label,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                labelStyle: Styles.textStyle),
            initialValue: dropdownValue?.value,
            onChanged: disabled
                ? null
                : (newValue) {
                    dropdownValue?.value = newValue!;
                    if (label == "Outlet") {
                      captainOrderController.loadTables();
                    }
                  },
            items: items.map((map) {
              return DropdownMenuItem<String>(
                value: map.code,
                child: Text(map.name,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList()),
      ],
    );
  }

  Column dropdownInputFormTable(dynamic dropdownValue, List items, label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
            isExpanded: true,
            decoration: InputDecoration(
                labelText: label,
                enabled: false,
                labelStyle: Styles.textStyle,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0)),
            initialValue: dropdownValue?.value,
            onChanged: (newValue) {
              dropdownValue?.value = newValue!;
            },
            items: items.map((map) {
              return DropdownMenuItem<String>(
                value: map.number,
                child: Text(map.number,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList()),
      ],
    );
  }

  showCaptainOrderForm(context, size) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Obx(
            () => AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    10.0,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.all(
                10.0,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.captainOrderId.value > 0
                        ? "Update Captain Order"
                        : "Create Captain Order",
                    style: Styles.headLineStyle4,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: FractionalOffset.topRight,
                      child: GestureDetector(
                        child: const Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
                ],
              ),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: size.width,
                  // height: 400,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        inputFormField("Customer",
                            captainOrderController.customerController, false,
                            keyboardType: TextInputType.text),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            inputAdultChild(
                                context, "Adult", captainOrderController.adult),
                            inputAdultChild(
                                context, "Child", captainOrderController.child),
                          ],
                        ),
                        dropdownInputForm(
                            captainOrderController.complimentTypeCode,
                            captainOrderController.complimentTypeList,
                            "Compliment",
                            controller.captainOrderId > 0),
                        subDepartment(),
                        dropdownInputForm(captainOrderController.outletCode,
                            captainOrderController.outletList, "Outlet", true),
                        dropdownInputFormTable(
                            captainOrderController.tableNumber,
                            captainOrderController.tableList,
                            "Table"),
                        dropdownInputForm(
                            captainOrderController.waitressCode,
                            captainOrderController.waitressList,
                            "Waitress",
                            false),
                        dropdownInputForm(captainOrderController.marketCode,
                            captainOrderController.marketList, "Market", false),
                        inputFormField("Remark",
                            captainOrderController.remarkController, false),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize:
                          WidgetStateProperty.all<Size>(Size(size.width, 38)),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Styles.primaryColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Styles.defaultRadius),
                      ))),
                  onPressed: captainOrderController.isSavingOrder.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _saveCaptainOrder(context);
                          }
                        },
                  child: captainOrderController.isSavingOrder.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                )
              ],
            ),
          );
        });
  }

  subDepartment() {
    if (captainOrderController.complimentTypeCode.value == "N") {
      return const Gap(1);
    } else {}
    return dropdownInputForm(
        captainOrderController.subDepartmentCode,
        captainOrderController.subDepartmentList,
        "Sub Department",
        captainOrderController.complimentTypeCode.value == "N");
  }

  Future<dynamic> showFormCaptainOrder(context, size) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: size.width,
                height: size.height * 0.9,
                // height: 400,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      inputFormField("Customer",
                          captainOrderController.customerController, true,
                          keyboardType: TextInputType.text),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: size.width / 4,
                              child: inputFormField("Adult",
                                  captainOrderController.adultController, true,
                                  keyboardType: TextInputType.number)),
                          SizedBox(
                              width: size.width / 4,
                              child: inputFormField("Child",
                                  captainOrderController.childController, true,
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                      dropdownInputForm(
                          captainOrderController.complimentTypeCode,
                          captainOrderController.complimentTypeList,
                          "Compliment",
                          false),
                      dropdownInputForm(
                          captainOrderController.subDepartmentCode,
                          captainOrderController.subDepartmentList,
                          "Sub Department",
                          captainOrderController.complimentTypeCode.value ==
                              "N"),
                      dropdownInputForm(captainOrderController.outletCode,
                          captainOrderController.outletList, "Outlet", true),
                      dropdownInputFormTable(captainOrderController.tableNumber,
                          captainOrderController.tableList, "Table"),
                      dropdownInputForm(
                          captainOrderController.waitressCode,
                          captainOrderController.waitressList,
                          "Waitress",
                          false),
                      dropdownInputForm(captainOrderController.marketCode,
                          captainOrderController.marketList, "Market", false),
                      inputFormField("Remark",
                          captainOrderController.remarkController, false),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
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
                    controller.orderList.clear();
                    controller.totalPrices();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }
}
