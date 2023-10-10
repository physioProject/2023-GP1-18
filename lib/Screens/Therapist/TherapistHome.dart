import 'package:flutter/material.dart';
import 'package:physio/Database/Database.dart';
import 'package:physio/Widget/AppButtons.dart';

import '../../Widget/AppRoutes.dart';
import '../Account/Login.dart';

class TherapistHome extends StatefulWidget {
  const TherapistHome({Key? key}) : super(key: key);

  @override
  State<TherapistHome> createState() => _TherapistHomeState();
}

class _TherapistHomeState extends State<TherapistHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
