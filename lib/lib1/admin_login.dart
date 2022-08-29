import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'admin_panel.dart';
import 'circularprogess.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success;
  String _successText;
  bool _failure;
  String _failureText;
  String _userEmail;
  final key = GlobalKey<ScaffoldState>();

  bool isRequest = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
        title: Text(
          "Admin Access",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      body: ListView(
        key: key,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 20, right: 20),
            child: Material(
              elevation: 2,
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.account_circle,
                      size: 150,
                      color: Color.fromARGB(255, 220, 219, 219),
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                              // ignore: missing_return
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                              },
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              // ignore: missing_return
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                if (value.length < 6) {
                                  return 'Please enter atleast 6 characters long password';
                                }
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 15),
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      this.isRequest = true;
                                    });

                                    FirebaseFirestore.instance
                                        .collection("admin")
                                        .where('email',
                                            isEqualTo: _emailController.text)
                                        .where('password',
                                            isEqualTo: _passwordController.text)
                                        .get()
                                        .then((checkSnapshot) {
                                      // print(checkSnapshot.docs.length);
                                      if (checkSnapshot.size > 0) {
                                        setState(() {
                                          this.isRequest = false;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                AdminSetting()),
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          this.isRequest = false;
                                        });

                                        Fluttertoast.showToast(
                                            msg: "user not found!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        //add the document
                                      }
                                    });
                                  }
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.grey.shade100,
                                  elevation: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Color.fromRGBO(37, 52, 112, 0.8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0,
                                          left: 25,
                                          right: 25,
                                          bottom: 12),
                                      child: this.isRequest
                                          ? CircularProgress()
                                          : Text(
                                              'Login',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                _success == null
                                    ? ''
                                    : _successText == null
                                        ? ""
                                        : _successText,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                _failure == null
                                    ? ''
                                    : _failureText == null
                                        ? ""
                                        : _failureText,
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
