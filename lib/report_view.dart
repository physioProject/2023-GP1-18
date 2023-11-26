// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:physio/Database/Database.dart';
import 'package:physio/Screens/Account/Login.dart';
import 'package:physio/Screens/Patient/ChangePass.dart';
import 'package:physio/Widget/AppBar.dart';
import 'package:physio/Widget/AppColor.dart';
import 'package:physio/Widget/AppIcons.dart';
import 'package:physio/Widget/AppMessage.dart';
import 'package:physio/Widget/AppPopUpMen.dart';
import 'package:physio/Widget/AppRoutes.dart';
import 'package:physio/Widget/GeneralWidget.dart';

class ReportView extends StatefulWidget {
  final String name;
  final String patientId;
  const ReportView({
    Key? key,
    required this.name,
    required this.patientId,
  }) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: AppMessage.PatientReport,
        leading: AppPopUpMen(
          icon: CircleAvatar(
            backgroundColor: AppColor.black,
            child: Icon(AppIcons.menu),
          ),
          menuList: AppWidget.itemList(
            onTapChangePass: () =>
                AppRoutes.pushTo(context, const ChangePass()),
            isChangePassword: true,
            helloName: 'Hello Patient ${widget.name}',
            action: () {
              Database.logOut();
              AppRoutes.pushReplacementTo(context, const Login());
            },
          ),
        ),
      ),
      body: Center(
        child: Text(AppMessage.PatientReport),
      ),
    );
  }
}
