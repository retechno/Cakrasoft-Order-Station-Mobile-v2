import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/home/home_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.put(HomeController());
  late TooltipBehavior _tooltipBehavior;

  Future<void> _onRefresh() async {
    controller.loadData();
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Container(
          padding: Styles.paddingBody,
          child: Column(
            children: [
              SizedBox(height: 15),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dashboard",
                      style: Styles.headLineStyle2,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.user.value,
                              style: Styles.headLineStyle3,
                            ),
                            Text(
                              controller.userGroup.value,
                              style: Styles.textDetailStyle,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: InkWell(
                            onTap: () {
                              _logoutConfirm(context);
                            },
                            child: const Icon(
                              Icons.logout_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  staticText("Finished", controller.finished.value.toString(),
                      Colors.green),
                  staticText("Pending", controller.pending.value.toString(),
                      Colors.amber),
                  staticText("Cancelled", controller.cancelled.value.toString(),
                      Colors.red),
                ],
              ),
              SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 212, 212, 212)),
                  borderRadius: BorderRadius.circular(Styles.defaultRadius),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Cash Balance :"),
                    Text(
                      Formats.formatNumber(controller.cashBalance.value),
                      style: Styles.headLineStyle3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(
                      text: 'Weekly sales analysis',
                      textStyle: Styles.textDetailStyle),
                  // Enable legend
                  legend: Legend(isVisible: false),
                  // Enable tooltip
                  tooltipBehavior: _tooltipBehavior,
                  series: List.generate(
                    controller.outletRevenueList.length,
                    (index) {
                      return StackedAreaSeries<SalesData, String>(
                        color: controller.colorList[index],
                        name: controller.outletRevenueList[index].name,
                        dataSource: List.generate(
                          controller.outletRevenueList[index].revenue!.length,
                          (index2) {
                            return SalesData(
                              Formats.formatDateMonth(
                                controller.outletRevenueList[index]
                                    .revenue![index2].auditDate,
                              ),
                              controller.outletRevenueList[index]
                                  .revenue![index2].revenue,
                            );
                          },
                        ),
                        xValueMapper: (SalesData sales, _) => sales.date,
                        yValueMapper: (SalesData sales, _) => sales.sales,
                        // Enable data label
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column staticText(label, value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  void _logoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                controller.logout();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

class SalesData {
  SalesData(this.date, this.sales);
  final String? date;
  final num? sales;
}
