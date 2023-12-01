import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:physio/Screens/Therapist/UpdateExercise.dart';
import '../Widget/AppConstants.dart';

class Database {
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['https://mail.google.com/']);

  //=======================patient SingUp ======================================
  static Future<String> patientSingUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required DateTime? dateOfBirth,
    required String condition,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);

      if (userCredential.user != null) {
        await AppConstants.userCollection.add({
          'firstName': firstName,
          'lastName': lastName,
          'userId': userCredential.user?.uid,
          'email': email,
          'dateOfBirth': dateOfBirth, // Update the type here
          'phone': phone,
          'condition': condition,
          'therapistName': 'undefined',
          'password':password,
          'therapistId': 'undefined',
          'type': 'patient',
          'status': 0,
          'activeUser': true,
        });

        return 'done';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        return 'weak-password';
      }
      if (e.code == 'email-already-in-use') {
        return 'email-already-in-use';
      }
    } catch (e) {
      return 'error';
    }

    return 'error';
  }


//=======================therapist SingUp ======================================
  static Future<String> therapistSingUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      if (userCredential.user != null) {
        await AppConstants.userCollection.add({
          'firstName': firstName,
          'lastName': lastName,
          'userId': userCredential.user?.uid,
          'email': email,
          'phone': phone,
          'password':password,
          'type': 'therapist',
          'status': 0,
          'activeUser': true,
        });
        return 'done';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        return 'weak-password';
      }
      if (e.code == 'email-already-in-use') {
        return 'email-already-in-use';
      }
    } catch (e) {
      return e.toString();
    }
    return 'error';
  }
//=======================Log in method======================================

  static Future<String> loggingToApp(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      if (userCredential.user != null) {
        return '${userCredential.user?.uid}';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        return 'user-not-found';
      }
      if (e.code == 'wrong-password') {
        return 'user-not-found';
      }
    } catch (e) {
      return 'error';
    }
    return 'error';
  }
  //=======================Log in method======================================

  static Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //=======================patient SingUp ======================================
    static Future<String> updatePatient(
      {required String firstName,
        required String lastName,
        required String docId,
        required String phone,

        required String condition}) async {
    try {
      await AppConstants.userCollection.doc(docId).update({
        'firstName': firstName,
        'lastName': lastName,

        'phone': phone,
        'condition': condition,
      });
      return 'done';
    } catch (e) {
      return 'error';
    }
  }

  //changPassword===================================================================================
  static Future<String> changPassword(
      {currentUser,
        required String email,
        required String oldPass,
        required String newPassword}) async {
    try {
      var cred = EmailAuthProvider.credential(email: email, password: oldPass);
      await currentUser!.reauthenticateWithCredential(cred).then((value) {
        currentUser!.updatePassword(newPassword);
      });
      return 'done';
    } catch (e) {
      return 'error';
    }
  }

//=======================therapist SingUp ======================================
  static Future<String> updateTherapist({
    required String firstName,
    required String lastName,
    required String phone,
    required String docId,
    required String therapistId,
  }) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('therapistId', isEqualTo: therapistId)
          .get();
      querySnapshot.docs.forEach((doc) async {
        final userId = doc.id;
        await updateTherapistName(
          docId: userId,
          therapistId: therapistId,
          therapistName: '$firstName $lastName',
        );
      });
      await AppConstants.userCollection.doc(docId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      });
      return 'done';
    } catch (e) {
      return 'error';
    }
  }
//=======================Active account when aend sms======================================

  static Future<String> updateAccountStatus({required String docId}) async {
    try {
      await AppConstants.userCollection.doc(docId).update({
        'status': 1,
      });
      return 'done';
    } catch (e) {
      return 'error';
    }
  }

  //=============================send password to user email=================================================
  static Future sendPasswordToUser({required Map<String, dynamic> data}) async {
    final user = await _googleSignIn.signIn();
    if (user == null) {
      return;
    }
    String email = user.email;
    final auth = await user.authentication;
    final String token = auth.accessToken!;
    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'Physio app')
      ..recipients.add(data['email'])
      ..subject = 'Hello ${data['firstName'] + ' ' + data['lastName']}'
      ..text = 'Your password is ${data['password']}';

    try {
      await send(message, smtpServer);
      return 'done';
    } on MailerException catch (e) {
      return 'error';
    }
  }

  //==============================LogOut from google account=================================================
  static Future singOutFromGoogleAccount() {
    return _googleSignIn.signOut();
  }

  //=======================delete account======================================

  static deleteAccount(BuildContext context,
      {required String docId,
        required String userId,
        required String type}) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete User'),
            content: const Text(
              "Are you sure you want to delete the user",
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Delete'),
                onPressed: () async {
                  await AppConstants.userCollection.doc(docId).delete();
//=======================update therapistName ======================================
                  if (type == 'therapist') {
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('therapistId', isEqualTo: userId)
                        .get();
                    querySnapshot.docs.forEach((doc) async {
                      final userId = doc.id;
                      await updateTherapistName(
                        docId: userId,
                        therapistId: 'undefined',
                        therapistName: 'undefined',
                      );
                    });
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {}
  }

  //=======================update the Therapist Name for specific patient ======================================
  static Future<String> updateTherapistName({
    required String therapistId,
    required String docId,
    required String therapistName,
  }) async {
    try {
      await AppConstants.userCollection.doc(docId).update({
        'therapistId': therapistId,
        'therapistName': therapistName,
      });
      return 'done';
    } catch (e) {
      return 'error';
    }
  }

  //=======================AddNewExercise ======================================
  static Future<String> AddNewExercise(
      {required String exercise,
        required String startDate,
        required String finishDate,
        required String userId,
        required String duration}) async {
    try {
      {
        await AppConstants.exerciseCollection.add({
          'exercise': exercise,
          'finishDate': finishDate,
          'startDate': startDate,
          'userId': userId,
          'duration': duration,
        });
        return 'done';
      }
    } on FirebaseException catch (e) {
    } catch (e) {
      return e.toString();
    }
    return 'error';
  }
//=======================Active user======================================
static Future<String> updateActiveUser(
      {required String docId, required bool activeUser,   userId,
        type}) async {
    try {
      await AppConstants.userCollection.doc(docId).update({
        'activeUser': activeUser,

      });


//=======================update therapistName ======================================
      if (type == 'therapist'&& activeUser==false) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('therapistId', isEqualTo: userId)
            .get();
        querySnapshot.docs.forEach((doc) async {
          final userId = doc.id;
          await updateTherapistName(
            docId: userId,
            therapistId: 'undefined',
            therapistName: 'undefined',
          );
        });
      }
      else if(type == 'patient'&& activeUser==false){
      await updateTherapistName(
      docId: docId,
      therapistId: 'undefined',
      therapistName: 'undefined',
      );}

      return 'done';
    } catch (e) {
      return 'error';
    }
  }
//=======================Get Exercise Details ======================================
  static Future<Map<String, dynamic>?> getExerciseDetails(String exerciseId) async {
    try {
      DocumentSnapshot exerciseSnapshot = await AppConstants.exerciseCollection.doc(exerciseId).get();

      if (exerciseSnapshot.exists) {
        return exerciseSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting exercise details: $e');
      return null;
    }
  }
  //=================================Update Exercise
  static Future<void> updateExercise(String exerciseId, Map<String, dynamic> data) async {
    try {
      // Your update logic goes here
      // For example, if you are using Firestore:
      await FirebaseFirestore.instance.collection('exercises').doc(exerciseId).update(data);
    } catch (e) {
      print('Error updating exercise: $e');
      // Handle errors as needed
      throw e; // Rethrow the error to notify the caller
    }
  }
  //========================Navigate to update
  static void navigateToUpdateExercise(BuildContext context, String exerciseId) async {
    Map<String, dynamic>? exerciseDetails = await Database.getExerciseDetails(exerciseId);

    if (exerciseDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateExercise(exerciseId: exerciseId),
        ),
      );
    }
  }
}


