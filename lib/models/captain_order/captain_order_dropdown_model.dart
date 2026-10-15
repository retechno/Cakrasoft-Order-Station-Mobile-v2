import 'package:point_of_sales/models/captain_order/compliment_type_model.dart';
import 'package:point_of_sales/models/captain_order/market_model.dart';
import 'package:point_of_sales/models/captain_order/marketing_model.dart';
import 'package:point_of_sales/models/captain_order/outlet_model.dart';
import 'package:point_of_sales/models/captain_order/sub_department_model.dart';
import 'package:point_of_sales/models/captain_order/table_model.dart';
import 'package:point_of_sales/models/captain_order/title_model.dart';
import 'package:point_of_sales/models/captain_order/waitress_model.dart';

class CaptainOrderDropdown {
  List<Titles>? title;
  List<ComplimentType>? complimentType;
  List<SubDepartment>? subDepartment;
  List<Outlet>? outlet;
  List<Tables>? table;
  List<Waitress>? waitress;
  List<Market>? market;
  List<Marketing>? marketing;

  CaptainOrderDropdown(
      {this.title,
      this.complimentType,
      this.subDepartment,
      this.outlet,
      this.table,
      this.waitress,
      this.market,
      this.marketing});

  CaptainOrderDropdown.fromJson(Map<String, dynamic> json) {
    CaptainOrderDropdown(
        title: title,
        complimentType: complimentType,
        subDepartment: subDepartment,
        outlet: outlet,
        table: table,
        waitress: waitress,
        market: market,
        marketing: marketing);
  }

  void convertFromJSON(json) {
    if (json['Title'] != null) {
      title = <Titles>[];
      json['Title'].forEach((v) {
        title!.add(Titles.fromJson(v));
      });
    }
    if (json['ComplimentType'] != null) {
      complimentType = <ComplimentType>[];
      json['ComplimentType'].forEach((v) {
        complimentType!.add(ComplimentType.fromJson(v));
      });
    }
    if (json['SubDepartment'] != null) {
      subDepartment = <SubDepartment>[];
      json['SubDepartment'].forEach((v) {
        subDepartment!.add(SubDepartment.fromJson(v));
      });
    }
    if (json['Outlet'] != null) {
      outlet = <Outlet>[];
      json['Outlet'].forEach((v) {
        outlet!.add(Outlet.fromJson(v));
      });
    }
    if (json['Table'] != null) {
      table = <Tables>[];
      json['Table'].forEach((v) {
        table!.add(Tables.fromJson(v));
      });
    }
    if (json['Waitress'] != null) {
      waitress = <Waitress>[];
      json['Waitress'].forEach((v) {
        waitress!.add(Waitress.fromJson(v));
      });
    }
    if (json['Market'] != null) {
      market = <Market>[];
      json['Market'].forEach((v) {
        market!.add(Market.fromJson(v));
      });
    }
    if (json['Marketing'] != null) {
      marketing = <Marketing>[];
      json['Marketing'].forEach((v) {
        marketing!.add(Marketing.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) {
      data['Title'] = title!.map((v) => v.toJson()).toList();
    }
    if (complimentType != null) {
      data['ComplimentType'] = complimentType!.map((v) => v.toJson()).toList();
    }
    if (subDepartment != null) {
      data['SubDepartment'] = subDepartment!.map((v) => v.toJson()).toList();
    }
    if (outlet != null) {
      data['Outlet'] = outlet!.map((v) => v.toJson()).toList();
    }
    if (table != null) {
      data['Table'] = table!.map((v) => v.toJson()).toList();
    }
    if (waitress != null) {
      data['Waitress'] = waitress!.map((v) => v.toJson()).toList();
    }
    if (market != null) {
      data['Market'] = market!.map((v) => v.toJson()).toList();
    }
    if (marketing != null) {
      data['Marketing'] = marketing!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  toList() {}
}
