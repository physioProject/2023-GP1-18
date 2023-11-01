import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widget/AppBar.dart';

import '../../../Widget/AppMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ViewPatientInfo extends StatefulWidget {
  final String PatientId;
  const ViewPatientInfo({Key? key,required this.PatientId}) : super(key: key);

  @override
  State<ViewPatientInfo> createState() => _ViewPatientInfoState();
}

class _ViewPatientInfoState extends State<ViewPatientInfo> {
  String patientName = '';
  String patientCondition = '';
  String patientEmail = '';
  String Age = '';

  @override
  void initState() {
    super.initState();
    fetchPatientData();}
  Future<void> fetchPatientData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.PatientId)
        .get();

    setState(() {
      final document = querySnapshot.docs.first;
      patientName ='${document['firstName']} ${document['lastName']}';
      Age = document['age'].toString();
      patientCondition = document['condition'];
      patientEmail = document['email'];
    });
  }




  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(text: AppMessage.PatientInfo),
        body: Form(

            child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w),
                child: ListView(

                    children: [
                      Text('Name: $patientName'),
                      Text('Age: $Age'),
                      Text('Condition: $patientCondition'),
                      Text('Email: $patientEmail'),

                      SizedBox(
                        height: 20.h,
                      ),
                    ]
                ) ) ) ); }
}
