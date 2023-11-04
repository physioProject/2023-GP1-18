import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Widget/AppIcons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:flutter/gestures.dart';

import '../../../Widget/AppBar.dart';
import '../../../Widget/AppText.dart';
import '../../../Widget/AppMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPatientInfo extends StatefulWidget {
  final String PatientId;
  const ViewPatientInfo({Key? key,required this.PatientId}) : super(key: key);

  @override
  State<ViewPatientInfo> createState() => _ViewPatientInfoState();
}class _ViewPatientInfoState extends State<ViewPatientInfo> {
  String patientName = '';
  String patientCondition = '';
  String patientEmail = '';
  String age = '';

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.PatientId)
        .get();

    setState(() {
      final document = querySnapshot.docs.first;
      patientName = '${document['firstName']} ${document['lastName']}';
      age = document['age'].toString();
      patientCondition = document['condition'];
      patientEmail = document['email'];
    });
  }

  void openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: patientEmail,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('could not launch email');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: AppMessage.PatientInfo),
      body: Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.1, 
              vertical: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
            ),
            child: ListView(
              children: [
                Row(
                  children: [
                    const AppText(
                      text: 'Name: ',
                      fontSize: 20,
                    ),
                    Icon(AppIcons.name),
                    AppText(
                      text: '$patientName',
                      fontSize: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppText(
                      text: 'Age: ',
                      fontSize: 20,
                    ),
                    Icon(AppIcons.calendar),
                    AppText(
                      text: '$age',
                      fontSize: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const AppText(
                      text: 'Condition: ',
                      fontSize: 20,
                    ),
                    Icon(AppIcons.condition),
                    AppText(
                      text: '$patientCondition',
                      fontSize: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const AppText(
                      text: 'Email: ',
                      fontSize: 20,
                    ),
                    InkWell(
                      onTap: openEmail,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(AppIcons.email),
                            ),
                            TextSpan(
                              text: '$patientEmail',
                              style: TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = openEmail,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
