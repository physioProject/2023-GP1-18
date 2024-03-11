
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Therapist/reportPage.dart';

import '../../../Widget/AppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Patient/patientExercise.dart';
import '../../Database/Database.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppIcons.dart';
import '../../Widget/AppImage.dart';

import 'package:physio/Screens/Therapist/TherapistHome.dart';
import '../../../Widget/AppBar.dart';
import '../../../Widget/AppMessage.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppPopUpMen.dart';
import '../../Widget/AppRoutes.dart';
import '../../Widget/AppSize.dart';
import '../../Widget/AppText.dart';
import '../../Widget/GeneralWidget.dart';
import '../Account/Login.dart';


import '../../../Widget/AppMessage.dart';
class exerciseDate extends StatefulWidget {
  final String planId;
  final String userId;
  final String level;
  final String exercise;

  const exerciseDate({Key? key, required this.planId, required this.userId,required this.level,required this.exercise}) : super(key: key);

  @override
  State<exerciseDate> createState() => _exerciseDateState();
}

late ImageProvider exerciseImg = AssetImage(AppImage.date);

class _exerciseDateState extends State<exerciseDate> { // مجموعة لتتبع الـ exercises التي تم عرضها
  Set<String> displayedDates = Set<String>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Exercise date'),
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
              .where((entry) => entry.key != 'date')
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

          final filteredExercises = exercises.where((exercise) {


              return exercise['planId'] == widget.planId &&
                  exercise['exercise'] == widget.exercise &&
                  exercise['level'] == widget.level;

          }).toList();

          if (filteredExercises.isEmpty) {
            return Center(
              child: Text(
                'No date found for the specified exercise',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final exerciseData = filteredExercises[index];

              final date = exerciseData['date'];
    if(displayedDates.contains(date)) {
    return SizedBox.shrink();
    }else {
    displayedDates.add(date);}

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: SizedBox(
                  height: 100.0,
                  width: double.maxFinite,
                  child: Card(
                    elevation: 5,
                    child: Center(
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                          radius: 25.0,

                             child: Image(
                              image: exerciseImg,
                            ),

                        ),
                        trailing: SizedBox(
                          width: 70,
                          height: 30,
                        ),
                        onTap: () {
                          var selectedexercise =date;


                          AppRoutes.pushTo(
                            context,
                            reportPage(exercise: widget.exercise,planId:widget.planId,userId:widget.userId,level:widget.level,date:selectedexercise),
                          );
                        },
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(
                            'Exercise Date:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                            SizedBox(height: 5.0),
                            Text(
                              '$date',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
