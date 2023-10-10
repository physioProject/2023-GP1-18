import 'package:flutter/material.dart';

import '../../../Database/Database.dart';
import '../../../Widget/AppBar.dart';
import '../../../Widget/AppColor.dart';
import '../../../Widget/AppIcons.dart';
import '../../../Widget/AppMessage.dart';
import '../../../Widget/AppPopUpMen.dart';
import '../../../Widget/AppRoutes.dart';
import '../../../Widget/GeneralWidget.dart';
import '../../Account/Login.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({Key? key}) : super(key: key);

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          text: AppMessage.manageAccountB,
          leading: AppPopUpMen(
              icon: CircleAvatar(
                backgroundColor: AppColor.black,
                child: Icon(AppIcons.menu),
              ),
              menuList: AppWidget.itemList(action: () {
                Database.logOut();
                AppRoutes.pushReplacementTo(context, const Login());
              }))),
      body: Center(
        child: Text('ManageAccount'),
      ),
    );
  }
}
