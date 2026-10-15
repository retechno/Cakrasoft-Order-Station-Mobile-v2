import 'package:flutter/material.dart';
import 'package:point_of_sales/screens/pages/table_view/table_view.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Restaurant',
                ),
                Tab(
                  text: 'Room Service',
                ),
                Tab(
                  text: 'Banquet',
                ),
              ],
            ),
            title: const Text('Table View'),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const TabBarView(
              children: [TableView(), TableView(), TableView()],
            ),
          ),
        ),
      ),
    );
  }
}
