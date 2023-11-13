import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Account/Login.dart';
import 'package:physio/Screens/Patient/ChangePass.dart';
import 'package:physio/Widget/AppLoading.dart';
import 'package:physio/Widget/AppRoutes.dart';
import 'package:physio/Widget/AppTextFields.dart';

import '../../Database/Database.dart';
import '../../Widget/AppBar.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppIcons.dart';
import '../../Widget/AppMessage.dart';
import '../../Widget/AppPopUpMen.dart';
import '../../Widget/AppSize.dart';
import '../../Widget/AppText.dart';
import '../../Widget/AppValidator.dart';
import '../../Widget/GeneralWidget.dart';

class PatientHome extends StatefulWidget {
  final String name;
  const PatientHome({Key? key, required this.name}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          text: 'Patient Home',
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
                  }))),
      body: Center(
        child: AppButtons(
          onPressed: () {
            Database.logOut;
            AppRoutes.pushReplacementTo(context, Login());
          },
          text: 'LogOut',
        ),
      ),
    );
  }
}
