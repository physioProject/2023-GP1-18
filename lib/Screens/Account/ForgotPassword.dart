import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
//new class
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}
  class _ForgotPasswordState extends State<ForgotPassword> {

    final _emailController = TextEditingController();

    @override
    void dispose() {
      _emailController.dispose();
      super.dispose();
    }

    Future passReset() async {
      // class start
      try { // try starts
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.trim());
        showDialog(context: context, builder: (context) {
          return AlertDialog(content: Text(
              'The reset link has been sent to your email. Please check it.'),
          );
        },
        );
      } //try ends

      on FirebaseAuthException catch (e) { //catch
        print(e);
        showDialog(context: context, builder: (context) {
          return AlertDialog(content: Text(e.message.toString()),
          );
        });
      } //catch
    } //class ends

    @override
    Widget build(BuildContext context) {
      // class starts
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child:
              Text('Please enter your email so we can send you a reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                  borderRadius: BorderRadius.circular(12),
                ),
                  hintText: 'Email',
                  fillColor: Colors.grey,
                  filled: true,
                ),
              ),
            ),
            SizedBox(height: 10),
            MaterialButton(
              onPressed: passReset,
              child: Text('Reset password'),
              color: Colors.blueGrey,
            ),
          ],
        ),
      );
    }




}

