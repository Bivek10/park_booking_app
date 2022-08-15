import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './DetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Tower> towers = new List();
  int totalSize;
  int numberOfTowers;

  Future<void> getData() async {
    await FirebaseFirestore.instance
        .collection("towersInfo")
        .doc("mainInfo")
        .get()
        .then((value) {
      print("value is ${value.id}");
      if (value != null) {
        totalSize = value.data()['occupancy'];
        numberOfTowers = value.data()['numberOfTowers'];
      }
    });

    FirebaseFirestore.instance
        .collection("towersInfo")
        .doc("towers")
        .snapshots()
        .listen((value) {
      print("tower info $value");
      towers.clear();
      print("number of tower is $numberOfTowers");
      for (int i = 1; i <= numberOfTowers; i++) {
        int occupied = value.data()['tower' + i.toString()]['occupied'];
        int availableSlots =
            value.data()['tower' + i.toString()]['availableSlots'];
        setState(() {
          towers.add(new Tower(i, availableSlots, occupied));
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: towers.length > 0
          ? OrientationBuilder(
              builder: (context, orientation) => GridView.builder(
                itemCount: towers.length,
                itemBuilder: (itemBuilder, index) => towers.length <= 0
                    ? CircularProgressIndicator()
                    : GridItem(towers[index]),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        orientation == Orientation.portrait ? 2 : 3),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.orange),
                backgroundColor: Colors.blue,
              ),
            ),
    );
  }
}

class Tower {
  int towerID;
  int availableSlots;
  int occupied;
  Tower(this.towerID, this.availableSlots, this.occupied);
}

class GridItem extends StatefulWidget {
  final Tower tower;

  GridItem(this.tower);

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  void handleGridItemClick(BuildContext context) async {
    String location = widget.tower.towerID.toString();
    print(location + " Clicked ");
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User user = await firebaseAuth.currentUser;
    if (user != null) {
      print("user authenticated");
      _pushPage(context, DetailsScreen(location));
    } else {
      print("user is not authorised");
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please sign up/ sign in",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _pushPage(BuildContext context, Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          handleGridItemClick(context);
        },
        child: Container(
          decoration: BoxDecoration(
              color: Color(0xffcdf909),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.tower.towerID.toString(),
                style: TextStyle(fontSize: 50, color: Colors.black),
              ),
              Text("Available: " + widget.tower.availableSlots.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text("Occupied: " + widget.tower.occupied.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
