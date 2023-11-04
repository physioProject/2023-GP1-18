import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:physio/Screens/Therapist/ViewPatientPlan.dart';
import 'package:physio/Widget/AppTextFields.dart';
import '../../../Widget/AppBar.dart';
import '../../../Database/Database.dart';
import '../../../Widget/AppMessage.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppDropList.dart';
import '../../Widget/AppLoading.dart';

class AddNewExercise extends StatefulWidget {
  final String PatientId;

  const AddNewExercise({Key? key, required this.PatientId}) : super(key: key);

  @override
  State<AddNewExercise> createState() => _AddNewExerciseState();
}

class _AddNewExerciseState extends State<AddNewExercise> {
  GlobalKey<FormState> addKey = GlobalKey();
  String? selectedExercise;
  TextEditingController startDateController = TextEditingController();
  TextEditingController finishDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  void dispose() {
    startDateController.dispose();
    finishDateController.dispose();
    durationController.dispose();
    super.dispose();
  }
  void calculateDuration() {
    if (startDateController.text.isNotEmpty && finishDateController.text.isNotEmpty) {
      DateTime startDate = DateTime.parse(startDateController.text);
      DateTime finishDate = DateTime.parse(finishDateController.text);
      Duration duration = finishDate.difference(startDate);
      durationController.text = duration.inDays.toString();
    } else {
      durationController.text = '';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: AppMessage.Addingexercise),
      body: Form(
        key: addKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: ListView(
            children: [
              SizedBox(
                height: 20.h,
              ),

              AppTextFields(
                controller: startDateController,

                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData(

                          colorScheme: ColorScheme.light().copyWith(
                            primary: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        startDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        calculateDuration();
                      });
                    }
                  });
                },
                labelText: AppMessage.startDate,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppMessage.mandatoryTx;
                  }
                  // Check if start date is before finish date
                  if (finishDateController.text.isNotEmpty) {
                    DateTime startDate = DateTime.parse(value);
                    DateTime finishDate = DateTime.parse(finishDateController.text);
                    if (startDate.isAfter(finishDate)) {
                      return 'Start date must be before finish date';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextFields(
                controller: finishDateController,

                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(

          colorScheme: ColorScheme.light().copyWith(
            primary: Colors.black,
          ),
        ),
        child: child!,
      );
    } ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        finishDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        calculateDuration();
                      });
                    }
                  });
                },

                labelText: AppMessage.finishDate,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppMessage.mandatoryTx;
                  }
                  // Check if finish date is after start date
                  if (startDateController.text.isNotEmpty) {
                    DateTime startDate = DateTime.parse(startDateController.text);
                    DateTime finishDate = DateTime.parse(value);
                    if (finishDate.isBefore(startDate)) {
                      return 'Finish date must be after start date';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.h,
              ),
    AppTextFields(
      validator: (v) {
        if (v == null) {
          return AppMessage.mandatoryTx;
        } else {
          return null;
        }
      },

      obscureText: false,
      enable:false,

     controller: durationController, labelText: '${AppMessage.duration} days')
         , SizedBox(
          height: 10.h,
        ),
    AppDropList(
    listItem: AppConstants.ExerciseList,
    validator: (v) {
    if (v == null) {
    return AppMessage.mandatoryTx;
    } else {
    return null;
    }
    },
    onChanged: (selectedItem) {
    setState(() {
    selectedExercise = selectedItem;
    });
    print('selectedCondition: $selectedExercise');
    },
    hintText: AppMessage.exerciseList,
    dropValue: selectedExercise,
    ),
    SizedBox(
    height: 10.h,
    ),
      AppButtons(
        text: AppMessage.add,
        bagColor: AppColor.iconColor,
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          if (addKey.currentState?.validate() == true) {
            // add operation
            Database.AddNewExercise(
              exercise: selectedExercise!,
startDate:startDateController.text,
              finishDate: finishDateController.text,
              duration:durationController.text,
              userId:widget.PatientId
            ).then((v) {
              if (v == "done") {
                Navigator.pop(context);
                AppLoading.show(context, AppMessage.add, AppMessage.done);

              } else {
                Navigator.pop(context);
                AppLoading.show(context, AppMessage.add, AppMessage.error);
              }
            });
          }
        },
      ),
                ],
             ),
            ),
          ),
        );
       }
     }

