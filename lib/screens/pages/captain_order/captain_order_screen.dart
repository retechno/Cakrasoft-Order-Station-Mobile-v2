import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/captain_order/captain_order.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/uppercase_formatter.dart';
import 'package:point_of_sales/widget/skeleton_list_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CaptainOrderScreen extends GetView<CaptainOrderItemController> {
  CaptainOrderScreen({Key? key}) : super(key: key);

  Future<void> _onRefresh() async {
    controller.loadCaptainOrderList();
  }

  final GlobalKey<FormState> _formKeyUserAccess = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: _onRefresh,
        child: Scaffold(
          backgroundColor: Styles.bgColor,
          body: Container(
            padding: Styles.paddingBody,
            child: Column(
              children: [
                TitleHeaderWidget(
                  context,
                  title: "Captain Orders",
                  child: SizedBox(height: 5),
                ),
                outlets(),
                Expanded(
                  child: controller.isLoading.value
                      ? ItemListSkeleton(
                          itemCount: 5,
                          itemHeight: Styles.defaultHeightCard,
                          itemPadding: EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: Styles.defaultPadding / 2),
                          listPadding: EdgeInsets.only(
                              top: Styles.defaultPadding,
                              bottom: Styles.defaultPadding,
                              left: 5,
                              right: 5),
                          isHorizontal: false,
                        )
                      : controller.captainOrderItemList.isNotEmpty
                          ? ListView(
                              shrinkWrap: true,
                              children: List.generate(
                                  controller.captainOrderItemList.length,
                                  (index) {
                                return captainOrderItem(context,
                                    controller.captainOrderItemList[index]);
                              }))
                          : const Center(
                              child: Text("No data found"),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future showContextMenu(
      BuildContext context, size, CaptainOrder captainOrder) async {
    // if (controller.isLoadingIndicator.value) return;
    // await controller.getIsCaptainOrderStatusOpen(context);
    // if (!controller.isCaptainOrderStatusOpen.value) {
    //   return controller.showAlert(context);
    // }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
            title: Text(
              "Options",
              style: Styles.headLineStyle2,
            ),
            content: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        controller
                            .toCaptainOrderTransactionPage(captainOrder.idLog);
                      },
                      child: optionButton(context, " Transaction",
                          icon: const Icon(Icons.attach_money))),
                  InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        showModalAccess(
                            context,
                            captainOrder,
                            controller.specialAccessController.userSpecialAccess
                                .cancelCaptainOrder);
                      },
                      child: optionButton(context, "Cancel CO",
                          icon: const Icon(Icons.delete_outline))),
                ],
              ),
            ),
          );
        });
  }

  Container optionButton(BuildContext context, String text,
      {Future? onPressed, required Icon icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          icon,
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }

  Future<void> showModalAccess(context, CaptainOrder captainOrder, accessMode) {
    controller.userController.text = "";
    controller.passwordController.text = "";
    return showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Obx(
            () => FractionallySizedBox(
              heightFactor: 0.9,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          const Icon(Icons.key_outlined),
                          const SizedBox(height: 5),
                          Text(
                            "Authorize",
                            style: Styles.headLineStyle3,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Form(
                            key: _formKeyUserAccess,
                            child: Flexible(
                                child: Column(
                              children: [
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  style: Styles.textStyle,
                                  controller: controller.userController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5, 15, 5, 0),
                                    hintText: "User ID",
                                    prefixIcon:
                                        Icon(Icons.person_outline_rounded),
                                  ),
                                  validator: (String? value) {
                                    if (value!.trim().isEmpty) {
                                      return 'User ID is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                    style: Styles.textStyle,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: controller.hidePassword.value,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    controller: controller.passwordController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                5, 15, 5, 0),
                                        hintText: "Password",
                                        prefixIcon: const Icon(
                                            Icons.lock_outline_rounded),
                                        suffixIcon: InkWell(
                                            onTapDown: (detail) {
                                              controller.hidePassword.value =
                                                  !controller
                                                      .hidePassword.value;
                                            },
                                            onTapUp: (detail) {
                                              controller.hidePassword.value =
                                                  !controller
                                                      .hidePassword.value;
                                            },
                                            child: const Icon(Icons
                                                .remove_red_eye_outlined))),
                                    validator: (String? value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password is too short.';
                                      }
                                      return null;
                                    }),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKeyUserAccess.currentState!
                                        .validate()) {
                                      Navigator.pop(context);
                                      await controller.saveSpecialAccess(
                                          context, captainOrder, accessMode);
                                    }
                                  },
                                  style: ButtonStyle(
                                      minimumSize:
                                          WidgetStateProperty.all<Size>(Size(
                                              double.infinity,
                                              Styles.defaultHeightButton)),
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Styles.primaryColor),
                                      shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Styles.defaultRadius),
                                      ))),
                                  child: const Text("Confirm"),
                                ),
                                Text(
                                  controller.accessStatus.value,
                                  style: TextStyle(color: Styles.dangerColor),
                                  textAlign: TextAlign.start,
                                )
                              ],
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Card outlets() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.defaultRadius)),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        height: Styles.defaultHeightButton,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Styles.defaultRadius),
            color: Colors.white),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            style: Styles.textStyle,
            hint: const Text(
              "Select Outlet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: "verdana_regular",
              ),
            ),
            items: controller.outletList.map((map) {
              return DropdownMenuItem<String>(
                value: map.code,
                child: Text(map.name,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList(),
            isExpanded: true,
            isDense: true,
            value: controller.outletCode.value,
            onChanged: (val) {
              controller.outletCode.value = val.toString();
              _onRefresh();
            },
          ),
        ),
      ),
    );
  }

  Widget captainOrderItem(BuildContext context, CaptainOrder item) {
    String totalAmount = Formats.formatNumber(item.totalAmount.toString());

    final size = AppLayout.getSize(context);
    return Card(
        child: InkWell(
      onLongPress: () => {showContextMenu(context, size, item)},
      onTap: () => {controller.toCaptainOrderTransactionPage(item.idLog)},
      child: Container(
          height: Styles.defaultHeightCard,
          padding: EdgeInsets.only(
              top: Styles.defaultPadding,
              bottom: Styles.defaultPadding,
              left: 15,
              right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CO #${item.idLog}',
                    style: Styles.headLineStyle3,
                  ),
                  Row(
                    children: [
                      Text(
                        "Table ${item.tableNumber}",
                        style: Styles.textDetailStyle,
                      ),
                      SizedBox(height: 5),
                      const Icon(
                        Icons.radio_button_on_rounded,
                        size: 8,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Guest ${item.adult! + (item.child ?? 0)}",
                        style: Styles.textDetailStyle,
                      ),
                    ],
                  )
                ],
              ),
              Text(totalAmount)
            ],
          )),
    ));
  }
}
