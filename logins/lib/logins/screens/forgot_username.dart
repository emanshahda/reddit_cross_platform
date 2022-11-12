import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../widgets/text_input.dart';
import '../widgets/upper_bar.dart';
import '../widgets/upper_text.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:email_validator/email_validator.dart';
import '../models/status.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotUserName extends StatefulWidget {
  static const routeName = '/ForgotUserName';
  final String url =
      'https://abf8b3a8-af00-46a9-ba71-d2c4eac785ce.mock.pstmn.io';

  /// variable to check if the backend finish the actual server of work with the mock
  final bool isMock = true;
  @override
  State<ForgotUserName> createState() => _ForgotUserNameState();
}

class _ForgotUserNameState extends State<ForgotUserName> {
  // const ForgotUserName({Key? key}) : super(key: key);
  bool isFinished = false;

  TextEditingController inputEmailController = TextEditingController();

  void changeInput() {
    isFinished = (!inputEmailController.text.isEmpty) &&
        (validateEmail() == InputStatus.sucess);
  }

  InputStatus inputEmailStatus = InputStatus.original;
  String emailErrorMessage = '';
  InputStatus validateEmail() {
    // print(EmailValidator.validate(inputEmailController.text.toLowerCase()));
    if (inputEmailController.text.isEmpty)
      return InputStatus.original;
    else if (EmailValidator.validate(inputEmailController.text.toLowerCase()))
      return InputStatus.sucess;
    else {
      emailErrorMessage = 'Not a valid email address';
      return InputStatus.failed;
    }
  }

  void controlEmailStatus(hasFocus) {
    if (hasFocus)
      inputEmailStatus = InputStatus.taped;
    else
      inputEmailStatus = validateEmail();
  }

  bool isError = false;
  bool isSubmit = false;
  String errorMessage = '';
  void submitForgorUserName() {
    Uri URL = Uri.parse(widget.url +
        '/users/forgot_username' +
        ((widget.isMock) ? '/400' : ''));
    http
        .post(URL,
            body: json.encode({
              "email": inputEmailController.text,
            }))
        .then((response) {
      setState(() {
        isSubmit = true;
        if (response.statusCode == 204) {
          isError = false;
        } else if (response.statusCode == 400) {
          isError = true;
          errorMessage = json.decode(response.body)['errorMessage'];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //GestureDetector to hide the soft keyboard
      //by clicking outside of TextField or anywhere on the screen
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          children: [
            UpperBar(UpperbarStatus.login),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UpperText('Recover username'),
                    TextInput(
                        lable: 'Email',
                        ontap: (hasFocus) {
                          setState(() {
                            controlEmailStatus(hasFocus);
                          });
                        },
                        currentStatus: inputEmailStatus,
                        changeInput: () {
                          setState(() {
                            changeInput();
                          });
                        },
                        inputController: inputEmailController),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          style: TextStyle(color: Colors.black54),
                          'Unfortunately, if you have never given us your email, we will not able to reset your password'),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(
                            text: 'Having trouble? ',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                //on tap code here, you can navigate to other page or URL
                                String url =
                                    "https://www.reddithelp.com/hc/en-us/articles/205240005";
                                var urllaunchable = await canLaunch(
                                    url); //canLaunch is from url_launcher package
                                if (urllaunchable) {
                                  await launch(
                                      url); //launch is from url_launcher package to launch URL
                                } else {
                                  print("URL can't be launched.");
                                }
                              },
                          ),
                        ))
                  ]),
            )),
            if (isSubmit && isError)
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Center(
                  child: Text(
                      textAlign: TextAlign.center,
                      errorMessage,
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.w500,
                        color: Theme.of(context).errorColor,
                      )),
                ),
              ),
            if (isSubmit && !isError)
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Text(
                    textAlign: TextAlign.center,
                    'you will receve if that adress maches your mail',
                    style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.w500,
                      color: Colors.green,
                    )),
              ),
            Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.red,
                      onSurface: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: isFinished ? submitForgorUserName : null,
                    child: Text('Continue'),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
