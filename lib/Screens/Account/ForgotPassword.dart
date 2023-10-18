import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio/Widget/AppButtons.dart';
import 'package:physio/Widget/AppTextFields.dart';
import '../../Widget/AppMessage.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> passReset() async {
    final email = emailController.text.trim();

    //===================================== Check the email format=================================
    if (!isEmailValid(email)) {
      showSnackBar(AppMessage.sureEmail);
      return;
    }
//=============================Check if the user is registered===============================
    try {
      if (await isEmailRegistered(email)) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showSuccessDialog(AppMessage.sendEmail);
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(AppMessage.userNotFound),
            );
          },
        );
      }
    }
    //===========================Catch other exceptions =============================
    on FirebaseAuthException catch (e) {
      showAlertDialog('Error: ${e.message}');
    } catch (e) {
      showAlertDialog('An unexpected error occurred.');
    }
  }

  bool isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  Future<bool> isEmailRegistered(String email) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Please enter your email so we can send you a reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),

          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: AppMessage.emailTx,
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),

          SizedBox(height: 15),
          SizedBox(
            width: 200.0,
            height: 40.0,
            child: AppButtons(
              onPressed: passReset,
              text: 'Reset password',
            ),
          )
        ],
      ),
    );
  }
}