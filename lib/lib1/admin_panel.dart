import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkingapp/lib1/panel_menu.dart';
import 'package:parkingapp/lib1/review_page.dart';

import 'all_book.dart';

class AdminSetting extends StatefulWidget {
  const AdminSetting({Key key}) : super(key: key);

  @override
  State<AdminSetting> createState() => _AdminSettingState();
}

class _AdminSettingState extends State<AdminSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          "Admin Panel",
          style: GoogleFonts.roboto(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
      body: ListView(
        children: [
          ProfileMenu(
              text: "Booking Details",
              icon: Icons.online_prediction_rounded,
              press: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllBookDetails()));
              }),
          ProfileMenu(
              text: "Reviews",
              icon: Icons.message,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewDetails(),
                  ),
                );
              })
        ],
      ),
    );
  }
}
