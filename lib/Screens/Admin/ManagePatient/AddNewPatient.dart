import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  TextEditingController ageController = TextEditingController();
  GlobalKey<FormState> addKey = GlobalKey();
  String? selectedCondition;
  String? generatedPassword;
  String? docId;
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
//==============================first name===============================================================
              AppTextFields(
                controller: firstNameController,
                labelText: AppMessage.firstName,
                validator: (v) => AppValidator.validatorName(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
//==============================last name===============================================================
              AppTextFields(
                controller: lastNameController,
                labelText: AppMessage.lastName,
                validator: (v) => AppValidator.validatorName(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
//==============================email name===============================================================
              AppTextFields(
                controller: emailPathController,
                labelText: AppMessage.emailTx,
                validator: (v) => AppValidator.validatorEmail(v),
                obscureText: false,
              ),
              SizedBox(
                height: 10.h,
              ),
//==============================phone number===============================================================
              AppTextFields(
                  controller: phoneController,
                  labelText: AppMessage.phoneTx,
                  validator: (v) => AppValidator.validatorPhone(v),
                  obscureText: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number),
              SizedBox(
                height: 10.h,
              ),
//==============================age name===============================================================
              AppTextFields(
                  controller: ageController,
                  labelText: AppMessage.age,
                  validator: (v) => AppValidator.validatorEmpty(v),
                  obscureText: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number),
              SizedBox(
                height: 10.h,
              ),
//==============================condition Menu===============================================================
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
                  selectedCondition = selectedItem;
                  print('selectedCondition: $selectedCondition');
                },
                hintText: AppMessage.condition,
                dropValue: selectedCondition,
              ),
              SizedBox(
                height: 10.h,
              ),

//==============================Add Button===============================================================
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
                      age: int.parse(ageController.text),
                      condition: selectedCondition!,
                    ).then((v) {
                      if (v == "done") {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        AppLoading.show(
                            context, AppMessage.add, AppMessage.done);
                      } else if (v == 'email-already-in-use') {
                        Navigator.pop(context);
                        AppLoading.show(context, 'inactive User',
                            AppMessage.emailFoundActiveUser, showButtom: true,
                            noFunction: () {
                          Navigator.pop(context);
                        }, yesFunction: () async {
                          await AppConstants.userCollection
                              .where('email',
                                  isEqualTo: emailPathController.text)
                              .get()
                              .then((value) {
                            for (var element in value.docs) {
                              docId = element.id;
                              setState(() {});
                            }
                          });

                          await Database.updateActiveUser(
                              docId: docId!, activeUser: true);
                          print(
                              'objectobjectobjectobjectobjectobjectobjectobjectobjectobjectobjectobject');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      } else {
                        Navigator.pop(context);
                        AppLoading.show(
                            context, AppMessage.add, AppMessage.error);
                      }
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
