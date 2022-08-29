import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key key,
    this.text,
    this.icon,
    this.press,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.black,
          padding: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color(0xFFF5F6F9),
        ),
        onPressed: () {
          press();
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: Color.fromRGBO(37, 52, 112, 0.8),
              size: 22,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(text),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
