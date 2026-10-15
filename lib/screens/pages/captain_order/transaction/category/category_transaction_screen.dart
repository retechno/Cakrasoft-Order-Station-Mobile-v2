// import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/category/category_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/order/category/category_controller.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/button_order.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class CategoryTransactionScreen extends GetView<CategoryTransactionController> {
  CategoryTransactionScreen({Key? key}) : super(key: key);

  final productController = Get.find<ProductController>();
  final orderController = Get.find<OrdersController>();

  Future<void> _pullRefresh(outletCode) async {
    if (outletCode != null) {
      controller.outletCode.value = outletCode;
    }
    controller.loadCategoryList();
  }

  Future<void> _toProduct(
      context, String categoryCode, String categoryName) async {
    productController.categoryCode.value = categoryCode;
    productController.categoryName.value = categoryName;
    controller.toProductPage();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () {
            return _pullRefresh(null);
          },
          child: Container(
            padding: Styles.paddingBody,
            child: Column(
              children: [
                TitleHeaderWidget(
                  context,
                  title: "Categories",
                  child: orderController.captainOrderId.value > 0
                      ? InkWell(
                          onTap: () {
                            orderController.captainOrderId.value = 0;
                            Get.back();
                          },
                          child: const Icon(Icons.west))
                      : const Icon(Icons.category),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Outlets :"),
                    SizedBox(
                      height: 35,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(controller.outletList.length,
                              (index) {
                            return outletList(
                                controller.outletList[index],
                                controller.outletList[index].code ==
                                    controller.outletCode.value);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SearchInput(),
                Expanded(
                    child: controller.categoryListFilters.isNotEmpty
                        ? ListView(
                            children: List.generate(
                                controller.categoryListFilters.length, (index) {
                              return categoryItem(context,
                                  controller.categoryListFilters[index]);
                            }),
                          )
                        : const Center(
                            child: Text("No data found"),
                          )),
                ButtonOrder(
                  context,
                  onProductPage: false,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card categoryItem(context, category) {
    return Card(
      child: InkWell(
        onTap: () {
          _toProduct(context, category.code, category.name);
        },
        child: Container(
            height: Styles.defaultHeightCard,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/image.png'),
                      height: 45,
                      width: 45,
                    ),
                    SizedBox(height: 7),
                    Text(
                      category.name,
                      style: Styles.headLineStyle4,
                    ),
                  ],
                ),
                getTotalItemEachCategory(category.code),
              ],
            )),
      ),
    );
  }

  getTotalItemEachCategory(categoryCode) {
    int total = 0;
    for (var element in orderController.orderList) {
      if (element.categoryCode == categoryCode) {
        total++;
      }
    }
    if (total > 0) {
      return Row(
        children: [
          Badge(
            label: Text(
              total.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      );
    }

    return const Icon(Icons.chevron_right);
  }

  outletList(outlet, isActive) {
    return InkWell(
        onTap: orderController.orderList.isEmpty
            ? () {
                _pullRefresh(outlet.code);
              }
            : null,
        child: Card(
          color: isActive ? Colors.blue : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
              height: 22,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(
                  child: Text(outlet.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              isActive ? Colors.white : Styles.textInactive)),
                ),
              )),
        ));
  }
}

class SearchInput extends GetView<CategoryController> {
  const SearchInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //     margin: EdgeInsets.symmetric(horizontal: 3),
    //     padding: EdgeInsets.only(left: 15, right: 0, top: 4, bottom: 4),
    //     height: Styles.defaultHeightButton,
    //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(Styles.defaultRadius), color: Colors.white),
    //     child: TextFormField(
    //       controller: controller.filterController,
    //       onChanged: (value) {
    //         controller.filterCategory();
    //       },
    //       cursorColor: Colors.black,
    //       decoration: const InputDecoration(
    //           suffixIcon: Icon(Icons.search),
    //           border: InputBorder.none,
    //           focusedBorder: InputBorder.none,
    //           enabledBorder: InputBorder.none,
    //           errorBorder: InputBorder.none,
    //           disabledBorder: InputBorder.none,
    //           // contentPadding: EdgeInsets.only(left: 15, bottom: 14, top: 12, right: 15),
    //           hintText: "Search"),
    //     ));
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.defaultRadius)),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.only(left: 15, right: 0, top: 4, bottom: 4),
          height: Styles.defaultHeightButton,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Styles.defaultRadius),
              color: Colors.white),
          child: TextFormField(
            controller: controller.filterController,
            onChanged: (value) {
              controller.filterCategory();
            },
            cursorColor: Colors.black,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.search),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                // contentPadding: EdgeInsets.only(left: 15, bottom: 14, top: 12, right: 15),
                hintText: "Search"),
          )),
    );
  }
}
