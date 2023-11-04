import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widget/AppBar.dart';

import '../../../Widget/AppMessage.dart';
import '../../Database/Database.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppIcons.dart';
import '../../Widget/AppLoading.dart';
import '../../Widget/AppRoutes.dart';
import 'package:physio/Screens/Therapist/AddNewExercise.dart';

import '../../Widget/AppSize.dart';
import '../../Widget/AppText.dart';

class ViewPatientPlan extends StatefulWidget {
  final String PatientId;
  const ViewPatientPlan({Key? key,required this.PatientId}) : super(key: key);

  @override
  State<ViewPatientPlan> createState() => _ViewPatientPlanState();
}

class _ViewPatientPlanState extends State<ViewPatientPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(text: AppMessage.PatientPlan),
        floatingActionButton: FloatingActionButton(
            backgroundColor: AppColor.iconColor,
            elevation: 10,
            child: Icon(AppIcons.add),
          onPressed: () {
            AppRoutes.pushTo(context, AddNewExercise(PatientId: widget.PatientId));
          },),
        body: StreamBuilder(
            stream: AppConstants.exerciseCollection
                .where('userId', isEqualTo:widget.PatientId)

                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              if (snapshot.hasData) {
                return body(context, snapshot);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

//=======================================================================
  Widget body(context, snapshot) {
    return snapshot.data.docs.length > 0
        ? ListView.builder(
      itemCount: snapshot.data.docs.length,
      itemBuilder: (context, i) {
        var data = snapshot.data.docs[i].data();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: SizedBox(
            height: 100.h,
            width: double.maxFinite,
            child: Card(
              elevation: 5,
              child: Center(
                child: ListTile(

                  tileColor: AppColor.white,
                 

//delete icon==================================================================================================
                  trailing: InkWell(

                      //write delete code her

                    child: Icon(
                      AppIcons.delete,
                      size: 30.spMin,
                      color: AppColor.errorColor,
                    ),
                  ),
//name icon==================================================================================================
                  title: AppText(
                    text: data['exercise'] ,
                    fontSize: AppSize.subTextSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    )
        : Center(
      child: AppText(
          text: AppMessage.noData,
          fontSize: AppSize.subTextSize,
          fontWeight: FontWeight.bold),
    );
  }
}



//=========================================

