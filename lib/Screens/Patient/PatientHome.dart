import 'package:flutter/material.dart';
import 'package:physio/Screens/Account/Login.dart';
import 'package:physio/Widget/AppRoutes.dart';

import '../../Database/Database.dart';
import '../../Widget/AppButtons.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: AppButtons(
          onPressed: (){
            Database.logOut;
            AppRoutes.pushReplacementTo(context, Login());
          },
          text: 'LogOut',
        ),
      ),
    );
  }
}
