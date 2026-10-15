import 'package:flutter/material.dart';

import '../utils/app_utils.dart';

class TitleHeaderWidget extends StatelessWidget {
  final String title;
  final String? titleDetail;
  final Widget? child;
  final BuildContext parentContext;
  final PopupMenuButton? options;

  const TitleHeaderWidget(
    this.parentContext, {
    Key? key,
    required this.title,
    this.child,
    this.titleDetail,
    this.options,
  }) : super(key: key);

  Column getTitle() {
    if (titleDetail != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: Styles.headLineStyle,
          ),
          Text(
            titleDetail!,
            style: Styles.headLineStyle4,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: Styles.headLineStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 35),
      height: 100,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              child ??
                  InkWell(
                      onTap: () {
                        Navigator.of(parentContext).pop();
                      },
                      child: const Icon(Icons.west)),
              Expanded(child: getTitle()),
              options ??
                  SizedBox(
                    width: 0,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
