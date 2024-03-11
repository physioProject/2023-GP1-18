

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Widget/AppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Patient/patientExercise.dart';
import '../../Database/Database.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppIcons.dart';
import '../../Widget/AppImage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:physio/Screens/Therapist/TherapistHome.dart';
import '../../../Widget/AppBar.dart';
import '../../../Widget/AppMessage.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppPopUpMen.dart';
import '../../Widget/AppRoutes.dart';
import '../../Widget/AppSize.dart';
import '../../Widget/AppText.dart';
import '../../Widget/AppTextFields.dart';
import '../../Widget/AppValidator.dart';
import '../../Widget/GeneralWidget.dart';
import '../Account/Login.dart';


import '../../../Widget/AppMessage.dart';
class reportPage extends StatefulWidget {
  final String planId;
  final String userId;
  final String level;
  final String exercise;
  final String date;

  const reportPage({Key? key, required this.planId, required this.userId,required this.level,required this.exercise,required this.date}) : super(key: key);

  @override
  State<reportPage> createState() => _reportPageState();
}

late ImageProvider exerciseImg = AssetImage(AppImage.scoring);

class _reportPageState extends State<reportPage> {
  Set<String> displayedDates = Set<String>();

  String  planName='';
  int total=0;



  @override
  void initState() {
    super.initState();
    fetchPlanName();
  }

  Future<void> fetchPlanName() async {
    final planSnapshot = await FirebaseFirestore.instance.collection('plan').doc(widget.planId).get();
    final planData = planSnapshot.data() as Map<String, dynamic>?;
    if (planData != null) {
      setState(() {
        planName = planData['planName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Report Page'),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final reportData = snapshot.data?.data() as Map<String, dynamic>?;

          if (reportData == null || reportData.isEmpty) {
            return Center(
              child: Text(
                'No data',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final exercises = reportData.entries
              .where((entry) => entry.key != 'score')
              .map((entry) => entry.value)
              .toList();

          if (exercises.isEmpty) {
            return Center(
              child: Text(
                'No exercises found',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final filteredExercises = exercises.where((score) {
            return score['planId'] == widget.planId &&
                score['exercise'] == widget.exercise &&
                score['level'] == widget.level &&
                score['date'] == widget.date;
          }).toList();
total=filteredExercises.length;
          if (filteredExercises.isEmpty) {
            return Center(
              child: Text(
                'No data found for the specified exercise',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final scores = filteredExercises.map((exerciseData) => exerciseData['score']).toList();
          final scoresString = scores.join(', ');

          return SingleChildScrollView(
            child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 100,
                        child: ClipOval(
                          child: Image(
                            image: exerciseImg,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                AppTextFields(
                  controller: TextEditingController(text: planName),
                  labelText: 'Plan Name',
                  validator: (v) => AppValidator.validatorName(v),
                  obscureText: false,
                  enable: false,
                ),
                SizedBox(height: 10.h),
                AppTextFields(
                  controller: TextEditingController(text: widget.exercise),
                  labelText: 'Exercise Type',
                  validator: (v) => AppValidator.validatorName(v),
                  obscureText: false,
                  enable: false,
                ),
                SizedBox(height: 10.h),
                AppTextFields(
                  controller: TextEditingController(text: widget.level),
                  labelText: 'Exercise Level',
                  validator: (v) => AppValidator.validatorEmpty(v),
                  obscureText: false,
                  enable: false,
                ),
                SizedBox(height: 10.h),

                AppTextFields(
                  controller: TextEditingController(text: widget.date),
                  labelText: 'Exercise Date',
                  validator: (v) => AppValidator.validatorEmpty(v),
                  obscureText: false,
                  enable: false,
                ),
                SizedBox(height: 10.h),
                      AppTextFields(
                        controller: TextEditingController(text: total.toString()),
                        labelText: 'total exercise ',
                        validator: (v) => AppValidator.validatorEmpty(v),
                        obscureText: false,
                        enable: false,
                      ),
                      SizedBox(height: 10.h),
                AppTextFields(
                  controller: TextEditingController(text: scoresString),
                  labelText: 'Scores',
                  validator: (v) => AppValidator.validatorEmpty(v),
                  obscureText: false,
                  enable: false,
                ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          _shareAsPdf(scoresString, total);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(AppColor.black),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Share File '),
                            Icon(AppIcons.share),
                          ],
                        ),
                      ),

              ],
            ),
          ),
          ),
          );
        },
      ),
    );}
  Future<void> _shareAsPdf(String scoresString, int total) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Plan Name: $planName', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Exercise Type: ${widget.exercise}', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Exercise Level: ${widget.level}', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Date: ${widget.date}', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Total: $total', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Scores: $scoresString', style: pw.TextStyle(fontSize: 20)),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    Printing.sharePdf(bytes: bytes, filename: 'exercise_report.pdf');
  }}
