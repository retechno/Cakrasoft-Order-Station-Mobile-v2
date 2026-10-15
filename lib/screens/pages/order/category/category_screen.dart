import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/category_model.dart';
import 'package:point_of_sales/screens/pages/order/category/category_controller.dart';
import 'package:point_of_sales/screens/pages/order/product/product_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/button_order.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class CategoryScreen extends GetView<CategoryController> {
  CategoryScreen({Key? key}) : super(key: key);

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
                      ? ListView.builder(
                          itemCount: controller.categoryListFilters.length,
                          itemBuilder: (context, index) {
                            return categoryItem(
                                context, controller.categoryListFilters[index]);
                          },
                        )
                      : const Center(
                          child: Text("No data found"),
                        ),
                ),
                ButtonOrder(
                  context,
                  onProductPage: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card categoryItem(context, Categories category) {
    return Card(
      child: InkWell(
        onTap: () {
          _toProduct(context, category.code, category.name);
        },
        child: Container(
          height: Styles.defaultHeightCard,
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  category.imageLink.isNotEmpty
                      ? Image.network(
                          category.imageLink,
                          width: 45,
                          height: 45,
                          errorBuilder: (context, error, stackTrace) {
                            // Display a placeholder image in case of an error
                            return Image.asset(
                              'assets/images/image.png',
                              width: 45,
                              height: 45,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/image.png',
                          width: 45,
                          height: 45,
                        ),
                  SizedBox(width: 7),
                  Text(
                    category.name,
                    style: Styles.headLineStyle4,
                  ),
                ],
              ),
              getTotalItemEachCategory(category.code),
            ],
          ),
        ),
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
          height: 25,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Text(
                outlet.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.white : Styles.textInactive,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchInput extends GetView<CategoryController> {
  const SearchInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Styles.defaultRadius),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: Styles.defaultHeightButton,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
          color: Colors.white,
        ),
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
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 0, top: 7, right: 15),
            hintText: "Search",
          ),
        ),
      ),
    );
  }
}
