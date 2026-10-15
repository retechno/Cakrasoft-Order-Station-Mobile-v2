import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/folio.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/transfer_folio/transfer_folio_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/skeleton_list_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TransferToFolioScreen extends GetView<TransferToFolioController> {
  @override
  final controller = Get.put(TransferToFolioController());

  TransferToFolioScreen({Key? key}) : super(key: key);

  Future<void> _onRefresh() async {
    controller.loadFolioList();
  }

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
                TitleHeaderWidget(context,
                    title: controller.paymentController.accountName.value),
                folioTypes(),
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
                      : controller.folioList.isNotEmpty
                          ? ListView(
                              shrinkWrap: true,
                              children: List.generate(
                                  controller.folioList.length, (index) {
                                return FolioList(
                                    folio: controller.folioList[index]);
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

  Card folioTypes() {
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
              "Folio Type",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: "verdana_regular",
              ),
            ),
            items: controller.folioTypes.map((map) {
              return DropdownMenuItem<String>(
                value: map['code'],
                child: Text(map['name'],
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList(),
            isExpanded: true,
            isDense: true,
            value: controller.folioType.value,
            onChanged: (val) {
              controller.folioType.value = val.toString();
              _onRefresh();
            },
          ),
        ),
      ),
    );
  }
}

class FolioList extends StatelessWidget {
  final Folio folio;
  FolioList({Key? key, required this.folio}) : super(key: key);
  PaymentController paymentController = Get.find<PaymentController>();
  TransferToFolioController controller = Get.find<TransferToFolioController>();

  @override
  Widget build(BuildContext context) {
    String totalAmount = Formats.formatNumber(folio.balance);
    return Card(
        child: InkWell(
      onTap: () => {controller.processInputPayment(context, folio)},
      child: Container(
          height: Styles.defaultHeightCard,
          padding: EdgeInsets.only(
              top: Styles.defaultPadding,
              bottom: Styles.defaultPadding,
              left: 15,
              right: 15),
          child: Row(children: [
            folio.isLock == "-1" ? Icon(Icons.lock) : Icon(Icons.lock_open),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'F# ${folio.number}',
                    style: Styles.headLineStyle3,
                  ),
                  Row(
                    children: [
                      Text(
                        "Room# ${folio.roomNumber}",
                        style: Styles.textDetailStyle,
                      ),
                      SizedBox(height: 5),
                      const Icon(
                        Icons.radio_button_on_rounded,
                        size: 8,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Guest ${folio.fullName}",
                        style: Styles.textDetailStyle,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(totalAmount)
          ])),
    ));
  }
}
