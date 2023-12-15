import 'package:flutter/material.dart';

import 'login_page.dart';
import 'sign_up_page.dart';


class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key});

  @override
  State<LoginAndSignup> createState() => _LoginAndSignupState();
}

class _LoginAndSignupState extends State<LoginAndSignup> {
  bool islogin = true;
  void togglepage() {
    setState(() {
      islogin = !islogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (islogin) {
      return Loginpage(
        onPressed: togglepage,
      );
    } else {
      return Signup(
        onPressed: togglepage,
      );
    }
  }
}
