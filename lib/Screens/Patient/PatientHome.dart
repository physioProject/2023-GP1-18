import 'package:flutter/material.dart';
import 'package:physio/Screens/Patient/patient_plan_view.dart';
import 'package:physio/Screens/Patient/report_view.dart';
import 'package:physio/Widget/AppMessage.dart';

import '../../Widget/AppColor.dart';
import '../../Widget/AppIcons.dart';

class PatientHome extends StatefulWidget {
  final String name;
  final String patientId;
  const PatientHome({Key? key,required this.patientId ,required this.name,  }) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int selectedIndex = 0;
  late String SelectedUser;
  PageController? pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
    SelectedUser=widget.patientId;


    // pageController = PageController(initialPage: currentIndex);
  }
@override
Widget build(BuildContext context) {
  List<Widget> page = [PatientPlanView(patientId:widget.patientId,name:widget.name,), ReportView(patientId:widget.patientId,name:widget.name,)];
  return Scaffold(

    body: PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: page,
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColor.iconColor,
      selectedFontSize: 14,
      selectedItemColor: AppColor.white,
      unselectedItemColor: Colors.grey[500],
      unselectedFontSize: 11,
      currentIndex: selectedIndex,
      onTap: onTabTapped,
      items: [
        BottomNavigationBarItem(
            icon: Icon(AppIcons.managePatient),
            label: AppMessage.myPlan,
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.manageAccounts),
            label: AppMessage.PatientReport,
          ),
      ],
    ),
  );
}void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    pageController?.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInCirc);
  }
}

