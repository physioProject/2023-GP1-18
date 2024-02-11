import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Notification/GetAlert.dart';
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
import 'ChangePass.dart';
import '../Notification/AddAlert.dart';

class PatientPlanView extends StatefulWidget {
  final String name;
  final String patientId;
  const PatientPlanView({
    Key? key,
    required this.name,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientPlanView> createState() => _PatientPlanViewState();
}

class _PatientPlanViewState extends State<PatientPlanView> {
  late ImageProvider exerciseImg = AssetImage(AppImage.exercise);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: AppMessage.myPlan,
        leading:
        AppPopUpMen(
          icon: CircleAvatar(
            backgroundColor: AppColor.black,
            child: Icon(AppIcons.menu,color: AppColor.white,),
          ),
          menuList: AppWidget.itemList(
            onTapChangePass: () =>
                AppRoutes.pushTo(context, const ChangePass()),
            onTapSetNotification: () =>
                AppRoutes.pushTo(context, const GetAlert()),
            isChangePassword: true,
            isShowNotification: true,
            helloName: 'Hello Patient ${widget.name}',
            action: () {
              Database.logOut();
              AppRoutes.pushReplacementTo(context, const Login());
            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: AppConstants.exerciseCollection
            .where('userId', isEqualTo: widget.patientId)
            .where('finishDate', isGreaterThan: DateTime.now().toString())
            .orderBy('finishDate')
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
        },
      ),
    );
  }

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
                        leading: CircleAvatar(
                          radius: 25.sp,
                          child: ClipOval(
                            child: Image(
                              image: exerciseImg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        trailing: SizedBox(
                          width: 70,
                          height: 30,
                        ),
                        onTap: () {
                          var selectedPlan =
                              snapshot.data.docs[i].data()['planId'];
                          AppRoutes.pushTo(
                            context,
                            patientExercise(planId: selectedPlan),
                          );
                        },
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan Name:', // Header text
                              style: TextStyle(
                                fontSize: AppSize.subTextSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5), // Add spacing
                            Text(
                              data['planName'].toString(),
                              style: TextStyle(
                                fontSize: AppSize.subTextSize,
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
          )
        : Center(
            child: AppText(
                text: AppMessage.noData,
                fontSize: AppSize.subTextSize,
                fontWeight: FontWeight.bold),
          );
  }
}
