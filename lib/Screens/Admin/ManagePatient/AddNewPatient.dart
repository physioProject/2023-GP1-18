import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:physio/Widget/generalWidget.dart';

import '../../../Database/Database.dart';
import '../../../Widget/AppBar.dart';
import '../../../Widget/AppButtons.dart';
import '../../../Widget/AppColor.dart';
import '../../../Widget/AppConstants.dart';
import '../../../Widget/AppDropList.dart';
import '../../../Widget/AppLoading.dart';
import '../../../Widget/AppMessage.dart';
import '../../../Widget/AppTextFields.dart';
import '../../../Widget/AppValidator.dart';

class AddNewPatient extends StatefulWidget {
  const AddNewPatient({Key? key}) : super(key: key);

  @override
  State<AddNewPatient> createState() => _AddNewPatientState();
}

class _AddNewPatientState extends State<AddNewPatient> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailPathController = TextEditingController();
  DateTime? selectedDateOfBirth;
  GlobalKey<FormState> addKey = GlobalKey();
  String? selectedCondition;
  String? generatedPassword;

  static const String dateOfBirthLabel = 'Date of Birth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: AppMessage.addPatient),
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
                controller: firstNameController,
                labelText: AppMessage.firstName,
                validator: (v) => AppValidator.validatorName(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextFields(
                controller: lastNameController,
                labelText: AppMessage.lastName,
                validator: (v) => AppValidator.validatorName(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextFields(
                controller: emailPathController,
                labelText: AppMessage.emailTx,
                validator: (v) => AppValidator.validatorEmail(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextFields(
                controller: phoneController,
                labelText: AppMessage.phoneTx,
                validator: (v) => AppValidator.validatorPhone(v),
                obscureText: false,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextFields(
                controller: TextEditingController(
                  text: selectedDateOfBirth != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDateOfBirth!)
                      : '',
                ),
                labelText: dateOfBirthLabel,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          primaryColor: Colors.black,
                        ),
                        child: child!,
                      );
                    },
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        this.selectedDateOfBirth = selectedDate;
                      });
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppMessage.mandatoryTx;
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              AppDropList(
                listItem: AppConstants.conditionMenu,
                validator: (v) {
                  if (v == null) {
                    return AppMessage.mandatoryTx;
                  } else {
                    return null;
                  }
                },
                onChanged: (selectedItem) {
                  setState(() {
                    selectedCondition = selectedItem;
                  });
                  print('selectedCondition: $selectedCondition');
                },
                hintText: AppMessage.condition,
                dropValue: selectedCondition,
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
                    generatedPassword = AppWidget.randomUpper(1) +
                        AppWidget.randomLower(1) +
                        AppWidget.randomCode(1) +
                        AppWidget.randomNumber(5);
                    AppLoading.show(context, '', 'lode');
                    Database.patientSingUp(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailPathController.text,
                      password: generatedPassword!,
                      phone: phoneController.text,
                      dateOfBirth: selectedDateOfBirth,
                      condition: selectedCondition!,
                    ).then((v) {
                      if (v == "done") {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        AppLoading.show(context, AppMessage.add, AppMessage.done);
                      } else if (v == 'email-already-in-use') {
                        Navigator.pop(context);
                        AppLoading.show(
                            context, AppMessage.add, AppMessage.emailFound);
                      } else {
                        Navigator.pop(context);
                        AppLoading.show(
                            context, AppMessage.add, AppMessage.error);
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

