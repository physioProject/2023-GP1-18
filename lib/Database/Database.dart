import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../Widget/AppConstants.dart';


class Database {
  static final GoogleSignIn _googleSignIn =
  GoogleSignIn(scopes: ['https://mail.google.com/']);
//=======================patient SingUp ======================================
  static Future<String> patientSingUp(
      {required String firstName,
        required String lastName,
        required String email,
        required String password,
        required String phone,
        required int age,

        required String condition}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      if (userCredential.user != null) {
        await AppConstants.userCollection.add({
          'firstName': firstName,
          'lastName': lastName,
          'userId': userCredential.user?.uid,
          'password': password,
          'email': email,
          'age': age,
          'phone': phone,
          'condition': condition,
          'therapistName':'undefined',
          'therapistId':'undefined',
          'type': 'patient',
          'status': 0
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

//=======================therapist SingUp ======================================
  static Future<String> therapistSingUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,

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
          'password': password,
          'email': email,
          'phone': phone,
          'type': 'therapist',
          'status': 0
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
        required int age,

        required String condition}) async {
    try {
      await AppConstants.userCollection.doc(docId).update({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'phone': phone,

        'condition': condition,
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
  }) async {
    try {
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
//=======================Active account======================================

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

  static deleteAccount(BuildContext context,{required String docId}) async {
    try {
      showDialog(context: context, builder:(BuildContext context) {
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
                await FirebaseAuth.instance.currentUser!.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },);


    } catch (e) {

    }
  }


}
