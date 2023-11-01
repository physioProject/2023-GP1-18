import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widget/AppBar.dart';

import '../../../Widget/AppMessage.dart';

class ViewPatientReport extends StatefulWidget {
  final String PatientId;
  const ViewPatientReport({Key? key,required this.PatientId}) : super(key: key);

  @override
  State<ViewPatientReport> createState() => _ViewPatientReportState();
}

class _ViewPatientReportState extends State<ViewPatientReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(text: AppMessage.PatientReport),
        body: Form(

            child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w),
                child: ListView(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                    ]
                ) ) ) ); }
}

