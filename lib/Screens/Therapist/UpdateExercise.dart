import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:physio/Database/Database.dart';
import 'package:physio/Widget/AppButtons.dart';
import 'package:physio/Widget/AppColor.dart';
import 'package:physio/Widget/AppConstants.dart';
import 'package:physio/Widget/AppDropList.dart';
import 'package:physio/Widget/AppLoading.dart';
import 'package:physio/Widget/AppTextFields.dart';

class UpdateExercise extends StatefulWidget {
  final String exerciseId;

  UpdateExercise({required this.exerciseId});

  @override
  State<UpdateExercise> createState() => _UpdateExerciseState();
}

class _UpdateExerciseState extends State<UpdateExercise> {
  GlobalKey<FormState> updateKey = GlobalKey();
  String? selectedExercise;
  TextEditingController startDateController = TextEditingController();
  TextEditingController finishDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchExerciseDetails();
  }

  void fetchExerciseDetails() async {
    try {
      var exerciseDetails = await Database.getExerciseDetails(widget.exerciseId);
      if (exerciseDetails != null) {
        setState(() {
          startDateController.text = exerciseDetails['startDate'];
          finishDateController.text = exerciseDetails['finishDate'];
          durationController.text = exerciseDetails['duration'];
          selectedExercise = exerciseDetails['exercise'];
        });
      }
    } catch (e) {
      print('Error fetching exercise details: $e');
    }
  }

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
      appBar: AppBar(
        title: Text(
          'Update Exercise',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey,
      ),
      body: Form(
        key: updateKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: ListView(
            children: [
              SizedBox(
                height: 20.h,
              ),
              TextFormField(
                controller: startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Start Date is required';
                  }
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
                    },
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        finishDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        calculateDuration();
                      });
                    }
                  });
                },
                labelText: 'Finish Date',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Finish Date is required';
                  }
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
                controller: durationController,
                labelText: 'Duration (days)',
                obscureText: false,
                enable: false,
                validator: (v) {
                  if (v == null) {
                    return 'Duration is required';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              // Removed AppDropList widget
              SizedBox(
                height: 10.h,
              ),
              AppButtons(
                text: 'Update',
                bagColor: AppColor.iconColor,
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (updateKey.currentState?.validate() == true) {
                    updateExercise();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateExercise() async {
    try {
      calculateDuration();
      await Database.updateExercise(widget.exerciseId, {
        'exercise': selectedExercise!,
        'startDate': startDateController.text,
        'finishDate': finishDateController.text,
        'duration': durationController.text,
      });

      Navigator.pop(context);
      AppLoading.show(context, 'Update', 'Done');
    } catch (e) {
      print('Error updating exercise: $e');
      AppLoading.show(context, 'Update', 'Error');
    }
  }
}
