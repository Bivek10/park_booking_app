import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkingapp/lib1/circularprogess.dart';

import 'costume_text.dart';

class ReviewForm extends StatefulWidget {
  final String userid;

  final String parkname;

  const ReviewForm({Key key, @required this.userid, @required this.parkname})
      : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    usernamectrl.dispose();
    feedBack.dispose();
  }

  TextEditingController usernamectrl = TextEditingController();
  TextEditingController feedBack = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isRequest = false;

  @override
  Widget build(BuildContext context) {
    //print(widget.userid.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          "Feedback Form",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          child: Form(
            key: formKey,
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: usernamectrl,
                      cursorColor: Color.fromRGBO(37, 52, 112, 0.8),
                      style: CostumTextBorder.textfieldstyle,
                      decoration: CostumTextBorder.textfieldDecoration(
                        context: context,
                        hintText: "Username",
                        lableText: "Username",
                        iconData: Icons.person,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Username is required.";
                        }
                        // final RegExp emailExp = RegExp(
                        //     r'^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                        // if (!emailExp.hasMatch(value.trim())) {
                        //   return "Invalid E-mail address";
                        // }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: feedBack,
                      cursorColor: Color.fromRGBO(37, 52, 112, 0.8),
                      style: CostumTextBorder.textfieldstyle,
                      maxLines: 2,
                      decoration: CostumTextBorder.textfieldDecoration(
                          context: context,
                          hintText: "FeedBack",
                          lableText: "FeedBack",
                          iconData: Icons.email),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Feedback is required";
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (formKey.currentState.validate()) {
          try {
            setState(() {
              this.isRequest = true;
            });
            var response =
                FirebaseFirestore.instance.collection('parkreview').add(
              {
                "username": usernamectrl.text,
                'useremail': widget.userid,
                "parkname": widget.parkname,
                'message': feedBack.text,
              },
            );

            response.then((value) {
              if (value.id.isNotEmpty) {
                //sessionManager.setUserID(value.id.toString());
                setState(() {
                  this.isRequest = false;
                });
                Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomePage(),
                //   ),
                //   (route) => false,
                // );
                Fluttertoast.showToast(
                  msg: "Thank You! For your feedback.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                setState(() {
                  this.isRequest = false;
                });
                Fluttertoast.showToast(
                    msg: "Sorry! review failed",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            });
          } catch (e, s) {
            setState(() {
              this.isRequest = false;
            });
            //print(e);
            //print(s);
          }
        }
        //start registration;
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(37, 52, 112, 0.8),
              Color.fromRGBO(37, 52, 112, 0.8),
            ],
          ),
        ),
        child: this.isRequest
            ? CircularProgress()
            : Text(
                'Send review',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
      ),
    );
  }
}
