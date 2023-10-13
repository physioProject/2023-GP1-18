import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Account/ForgotPassword.dart';
import 'package:physio/Screens/Admin/AdminHome.dart';
import 'package:physio/Widget/AppImage.dart';
import 'package:physio/Widget/AppRoutes.dart';

import '../../Database/Database.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppDropList.dart';
import '../../Widget/AppLoading.dart';
import '../../Widget/AppMessage.dart';
import '../../Widget/AppTextFields.dart';
import '../../Widget/AppValidator.dart';
import '../Patient/PatientHome.dart';
import '../Therapist/TherapistHome.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Image bcImage;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> logKey = GlobalKey();
  String? selectedType;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    bcImage = Image.asset(AppImage.backgroundImage);
  }

  @override
  void didChangeDependencies() {
    precacheImage(bcImage.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                image: bcImage.image,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.darken),
                fit: BoxFit.cover)),
        child: Form(
          key: logKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //==============================Type Menu===============================================================
                AppDropList(
                  listItem: AppConstants.typeMenu,
                  validator: (v) {
                    if (v == null) {
                      return AppMessage.mandatoryTx;
                    } else {
                      return null;
                    }
                  },
                  onChanged: (selectedItem) {
                    selectedType = selectedItem;
                  },
                  hintText: AppMessage.type,
                  dropValue: selectedType,
                  fillColor: AppColor.opacityFillColor,
                ),
                SizedBox(
                  height: 20.h,
                ),

//==============================Email===============================================================
                AppTextFields(
                  controller: emailController,
                  labelText: AppMessage.emailTx,
                  validator: (v) => AppValidator.validatorEmail(v),
                  obscureText: false,
                  fillColor: AppColor.opacityFillColor,
                ),
                SizedBox(
                  height: 10.h,
                ),
//==============================Password===============================================================
                AppTextFields(
                  controller: passwordController,
                  labelText: AppMessage.passwordTx,
                  validator: (v) => AppValidator.validatorPassword(v),
                  obscureText: true,
                  fillColor: AppColor.opacityFillColor,
                ),
                SizedBox(
                  height: 10.h,
                ),
//////==============================Forgot password ========================================================
              Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                     children: [ GestureDetector(
                       onTap:()
                      {
                         Navigator.push
                           (context,MaterialPageRoute(builder: (context) {return ForgotPassword();
                         },
                        ),
                        );
                     },
                      child: Text('Forgot password?' , style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                   ),
                      ),
                       ),
                 ],
                   ),
                ),
                SizedBox(
                 height: 10.h,
                ),
//Finish of the method


//==============================Add Button===============================================================
                AppButtons(
                  text: AppMessage.loginTx,
                  bagColor: AppColor.iconColor,
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (logKey.currentState?.validate() == true) {
                      AppLoading.show(context, '', 'lode');
                      Database.loggingToApp(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      ).then((v) {
                        if (v == 'error') {
                          Navigator.pop(context);
                          AppLoading.show(
                              context, AppMessage.loginTx, AppMessage.error);
                        } else if (v == 'user-not-found') {
                          Navigator.pop(context);
                          AppLoading.show(context, AppMessage.loginTx,
                              AppMessage.userNotFound);
                        } else {

                          FirebaseFirestore.instance
                              .collection('users')
                              .where('userId', isEqualTo: v)
                              .get()
                              .then((typeFromDB) {
                            Navigator.pop(context);
                            typeFromDB.docs.forEach((element) {

                              print('name is: ${element.data()['name']}');
                              print(element.data()['type'] == selectedType);
                              if (element.data()['type'] == selectedType) {
                                if (element.data()['type'] ==
                                    AppConstants.typeIsPatient) {
                                  AppRoutes.pushReplacementTo(
                                      context, const PatientHome());
                                } else if (element.data()['type'] ==
                                    AppConstants.typeIsTherapist) {
                                  AppRoutes.pushReplacementTo(
                                      context, const TherapistHome());
                                } else {
                                  AppRoutes.pushReplacementTo(
                                      context, const AdminHome());
                                }
                              } else {
                                AppLoading.show(context, AppMessage.loginTx,
                                    AppMessage.userNotFound);
                              }
                            });
                          });
                        }
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

