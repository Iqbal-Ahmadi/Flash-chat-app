// ignore_for_file: prefer_const_constructors

import 'package:flash_chat_flutter/constants.dart';
import 'package:flash_chat_flutter/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/components/RoundButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showspinner = false;
  String warningMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: KTextFeildDecoration),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: KTextFeildDecoration.copyWith(
                      hintText: 'Enter your password')),
              Text(
                warningMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  text: 'Log In',
                  color: Colors.lightBlueAccent,
                  onTap: () async {
                    setState(() {
                      showspinner = true;
                    });
                    try {
                      final userData = await _auth.signInWithEmailAndPassword(
                          email: email!, password: password!);
                      // final userID = userData.user!.uid;

                      if (userData != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      } else {
                        setState(() {
                          warningMessage =
                              'please enter your email and password';
                          showspinner = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        warningMessage = 'email or password is incorrect';
                        showspinner = false;
                      });
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
