import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio/Screens/Account/ForgotPassword.dart';
import 'package:physio/Screens/Admin/AdminHome.dart';
import 'package:physio/Widget/AppImage.dart';
import 'package:physio/Widget/AppRoutes.dart';
import '../../Database/Database.dart';
import '../../Database/sqlLite.dart';
import '../../Widget/AppButtons.dart';
import '../../Widget/AppColor.dart';
import '../../Widget/AppConstants.dart';
import '../../Widget/AppDropList.dart';
import '../../Widget/AppLoading.dart';
import '../../Widget/AppMessage.dart';
import '../../Widget/AppTextFields.dart';
import '../../Widget/AppValidator.dart';
import '../Patient/PatientHome.dart';
import '../Therapist/ViewPatients.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Image bcImage;
  TextEditingController emailController =
      TextEditingController(text: "vrpatient@gmail.com");
  TextEditingController passwordController =
      TextEditingController(text: "Ep#50682");
  GlobalKey<FormState> logKey = GlobalKey();
  String? selectedType;
  final storage = new FlutterSecureStorage();
  var patientId;
  int failedAttempts = 0;
  bool isAccountLocked = false;
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
                  isMultiSelect: false,
                  multiSelectSeparator: ", ",
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ForgotPassword();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),

//===============================Add Button===============================================================
                AppButtons(
                  text: AppMessage.loginTx,
                  bagColor: AppColor.iconColor,
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    if (logKey.currentState?.validate() == true) {
                      AppLoading.show(context, '', 'lode');
                      Database.loggingToApp(
                        email: emailController.text,
                        password: passwordController.text,
                      ).then((v) async {
//on error============================================================================================================

                        if (v == 'error') {
                          Navigator.pop(context);
                          AppLoading.show(
                              context, AppMessage.loginTx, AppMessage.error);
                        }
//on user-not-found============================================================================================================
                        else if (v == 'user-not-found') {
                          // int de= await DatabaseHelper.deleteLogCounter();
                          // print('database deleted $de');

                           (await DatabaseHelper.getLogCounter()).isEmpty
                              ? await DatabaseHelper.addLogCounter(1)
                              : await DatabaseHelper.updateLogCounter(
                                  (await DatabaseHelper.getLogCounter())
                                          .first['logCont'] +
                                      1);
                          print(
                              'Counter length in wrong email-pass is: ${(await DatabaseHelper.getLogCounter())}');
                          if (!mounted) return;
                          Navigator.pop(context);

                          ///if user login mor than 3 time will block
                          if ((await DatabaseHelper.getLogCounter())
                              .isNotEmpty) {
                            (await DatabaseHelper.getLogCounter())
                                        .first['logCont'] >=
                                    3
                                ? AppLoading.show(context, AppMessage.loginTx,
                                    AppMessage.exceededLoginLimit)
                                : AppLoading.show(context, AppMessage.loginTx,
                                    AppMessage.userNotFound);
                          } else {
                            AppLoading.show(context, AppMessage.loginTx,
                                AppMessage.userNotFound);
                          }

//IF found============================================================================================================
                        } else {
                          if (!mounted) return;

                          List cont = await DatabaseHelper.getLogCounter();

                          ///check if user reset password or not
                          if (cont.isNotEmpty) {
                            if (cont.first['logCont'] > 3) {
                              AppLoading.show(context, AppMessage.loginTx,
                                  AppMessage.exceededLoginLimit);
                            } else {
                              viewResult(v);
                            }
                          } else {
                            viewResult(v);
                          }
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

  void viewResult(v) {
    FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: v)
        .get()
        .then((typeFromDB) async {
      Navigator.pop(context);
      for (var element in typeFromDB.docs) {
        if (element.data()['type'] == selectedType &&
            element.data()['activeUser'] == true) {
          if (element.data()['type'] == AppConstants.typeIsPatient) {
            String patientId = element.data()['userId'];
            AppRoutes.pushReplacementTo(
                context,
                PatientHome(
                  name: element.data()['firstName'] +
                      ' ' +
                      element.data()['lastName'],
                  patientId: patientId,
                ));
          } else if (element.data()['type'] == AppConstants.typeIsTherapist) {
            if (selectedType == AppConstants.typeIsTherapist) {
              String therapistId = element.data()['userId'];
              AppRoutes.pushReplacementTo(
                  context,
                  ViewPatients(
                    therapistId: therapistId,
                    name: element.data()['firstName'] +
                        ' ' +
                        element.data()['lastName'],
                  ));
            } else {
              AppRoutes.pushReplacementTo(
                  context,
                  ViewPatients(
                    therapistId: '',
                    name: element.data()['firstName'] +
                        ' ' +
                        element.data()['lastName'],
                  ));
            }
          } else {
            AppRoutes.pushReplacementTo(context, const AdminHome());
          }
        } else {
          (await DatabaseHelper.getLogCounter()).isEmpty
              ? await DatabaseHelper.addLogCounter(1)
              : await DatabaseHelper.updateLogCounter(
                  (await DatabaseHelper.getLogCounter()).first['logCont'] + 1);
          print('getLogCounter is: ${(await DatabaseHelper.getLogCounter())}');

          ///if user login mor than 3 time will block
          if ((await DatabaseHelper.getLogCounter()).isNotEmpty) {
            (await DatabaseHelper.getLogCounter()).first['logCont'] >= 3
                ? AppLoading.show(
                    context, AppMessage.loginTx, AppMessage.exceededLoginLimit)
                : AppLoading.show(
                    context, AppMessage.loginTx, AppMessage.userNotFound);
          } else {
            AppLoading.show(
                context, AppMessage.loginTx, AppMessage.userNotFound);
          }
        }
      }
    });
  }
}
