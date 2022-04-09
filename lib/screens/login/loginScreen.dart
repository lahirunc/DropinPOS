import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/screens/login/displayPane.dart';
import 'package:dropin_pos_v2/widgets/dateTimeDisp.dart';
import 'package:dropin_pos_v2/widgets/iconLastButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetWidget<AuthController> {
  const LoginScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: DisplayPane(),
            ),
            Expanded(
              flex: 1,
              child: LoginForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final authController = Get.find<AuthController>();

    TextEditingController _userController = TextEditingController();
    TextEditingController _pwdController = TextEditingController();

    String _validatorFunc(String value, String message, Pattern pattern) {
      if (value == null || value.isEmpty && pattern == null) {
        return message;
      } else if (pattern != null) {
        RegExp regex = new RegExp(pattern);

        if (!regex.hasMatch(value) || value == null) {
          return message;
        }
      }
      return null;
    }

    return Container(
      margin: EdgeInsets.all(screenSize.width * 0.06),
      child: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.14),
                //username
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _userController,
                  validator: (value) {
                    Pattern pattern =
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?)*$";

                    return _validatorFunc(value, 'Username required!', pattern);
                  },
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                      fontSize: screenSize.width * 0.014,
                    ),
                    hintText: 'Username',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                  ),
                  style: TextStyle(fontSize: screenSize.width * 0.020),
                ),
                SizedBox(height: screenSize.width * 0.04),
                // password
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: _pwdController,
                  validator: (value) {
                    return _validatorFunc(value, 'Password required!', null);
                  },
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                      fontSize: screenSize.width * 0.014,
                    ),
                    hintText: 'Password',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.black),
                    ),
                  ),
                  style: TextStyle(fontSize: screenSize.width * 0.020),
                ),
                SizedBox(height: screenSize.height * 0.05),
                // buttons
                Row(
                  children: [
                    // Sign in button
                    IconLastButton(
                      icon: Icons.arrow_forward,
                      iconColor: Palette.white,
                      text: 'Sign in',
                      borderRadius: 12.0,
                      color: Palette.primaryColor,
                      screenSize: screenSize,
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          authController.signIn(_userController.text.trim(),
                              _pwdController.text.trim());
                        }
                      },
                    ),
                    Spacer(),
                    // forgot button
                    // TextButton(
                    //   onPressed: () {
                    //     setState(() {});
                    //     print('forgot');
                    //   },
                    //   child: Text(
                    //     'Forgot Password?',
                    //     style: TextStyle(
                    //       fontSize: screenSize.width * 0.014,
                    //       color: Palette.darkGrey,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.1),
                // DateTime
                DateTimeDisp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
