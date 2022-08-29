import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkingapp/lib1/SigninPage.dart';
import 'package:parkingapp/lib1/parking_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        setState(() {
          user = firebaseUser;
        });
      } else {
        setState(() {
          user = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 14),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: InkWell(
              onTap: () {
                if (user == null)
                  _pushPage(context, SigninPage());
                else
                  _signOut();
              },
              child: Center(
                  child: Text(
                user == null ? "Sign in" : "Sign out",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )),
            ),
          )
        ],
      ),
      //body: ParkInMap(),
      body: HomeScreen(),
    );
  }

  void _pushPage(BuildContext context, Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }
}
