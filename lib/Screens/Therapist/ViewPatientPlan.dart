import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Widget/AppImage.dart';
import '../../../Widget/AppBar.dart';
import '../../../Widget/AppMessage.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppIcons.dart';
import '../../Widget/AppLoading.dart';
import '../../Widget/AppRoutes.dart';
import 'package:physio/Screens/Therapist/AddNewExercise.dart';
import '../../Widget/AppSize.dart';
import '../../Widget/AppText.dart';
import 'package:physio/Screens/Therapist/UpdateExercise.dart';
class ViewPatientPlan extends StatefulWidget {
  final String PatientId;
  const ViewPatientPlan({Key? key, required this.PatientId}) : super(key: key);

  @override
  State<ViewPatientPlan> createState() => _ViewPatientPlanState();
}
class _ViewPatientPlanState extends State<ViewPatientPlan> {
  late ImageProvider exerciseImg= AssetImage(AppImage.exercise);
  Future<void> deleteExercise(String documentId) async {
    try {
      await AppConstants.exerciseCollection.doc(documentId).delete();
    } catch (e) {
      print('Error deleting exercise: $e');
    }
  }

  Future<void> showDeleteConfirmationDialog(String documentId) async {
    AppLoading.show(
      context,
      'Delete exercise',
      'Do you want to delete this exercise for this patient?',
      showButtom: true,
      noFunction: () {

      },
      yesFunction: () async {
        Navigator.pop(context);
        await deleteExercise(documentId);

      },
    );
  }

  void navigateToUpdateExercise(String documentId) {
    AppRoutes.pushTo(context, UpdateExercise(exerciseId: documentId));
  }

  Widget body(context, snapshot) {
    return snapshot.data.docs.length > 0
        ? ListView.builder(
      itemCount: snapshot.data.docs.length,
      itemBuilder: (context, i) {
        var data = snapshot.data.docs[i].data();
        var documentId = snapshot.data.docs[i].id;

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
                    radius: 30.sp,
                    child: ClipOval(
                      child: Image(
                        image: exerciseImg,
                        fit: BoxFit.cover,

                      ),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      showDeleteConfirmationDialog(documentId);
                    },
                    child: Icon(
                      AppIcons.delete,
                      size: 30.spMin,
                      color: AppColor.errorColor,
                    ),
                  ),
                  title: InkWell(
                    onTap: () {
                      navigateToUpdateExercise(documentId);
                    },
                    child: AppText(
                      text: data['exercise'],
                      fontSize: AppSize.subTextSize,
                    ),
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
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: AppMessage.PatientPlan),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.iconColor,
        elevation: 10,
        child: Icon(AppIcons.add
        ),
        onPressed: () {
          AppRoutes.pushTo(context, AddNewExercise(PatientId: widget.PatientId));
        },
      ),
      body: StreamBuilder(
        stream: AppConstants.exerciseCollection
            .where('userId', isEqualTo: widget.PatientId)
            .where('finishDate', isGreaterThan: DateTime.now().toString())
            .orderBy('finishDate')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
}
