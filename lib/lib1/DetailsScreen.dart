import 'package:crypt/crypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsScreen extends StatefulWidget {
  final String location;
  DetailsScreen(this.location);
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class ParkingSlot {
  int location;
  bool isOccupied;
  bool isverify;
  bool isSelected;
  ParkingSlot(this.location, this.isOccupied, this.isverify, this.isSelected);
}

int totalSize;
int numberOfTowers;
int numberOfParkingSlotsInEachTower;

class _DetailsScreenState extends State<DetailsScreen> {
  List<ParkingSlot> parkingSlots = new List();
  List<ParkingSlot> bookedSlots = new List();
  List<ParkingSlot> pendingSlots = new List();
  bool isLoaded = false;
  Future<void> getData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = await auth.currentUser;
    await FirebaseFirestore.instance
        .collection("towersInfo")
        .doc("mainInfo")
        .get()
        .then((value) {
      totalSize = value['occupancy'];
      numberOfTowers = value['numberOfTowers'];
      numberOfParkingSlotsInEachTower = value['numberOfParkingSlots'];
    });

    FirebaseFirestore.instance
        .collection("towersInfo")
        .doc("tower" + widget.location)
        .snapshots()
        .listen((value) {
      setState(() {
        parkingSlots.clear();
        bookedSlots.clear();
        pendingSlots.clear();
      });
      bool isOccupied;
      bool isVerify;
      //print("tower" + widget.location);
      for (int i = 1; i <= numberOfParkingSlotsInEachTower; i++) {
        isOccupied = value.data()['parkingSlot$i']['isOccupied'];
        isVerify = value.data()["parkingSlot$i"]["isVarify"];
        //print("is occupied $isOccupied");
        if (isOccupied && isVerify != null && isVerify) {
          String userIDBookedByTheUser;
          userIDBookedByTheUser = value.data()['parkingSlot$i']['ownerID'];
          if (userIDBookedByTheUser == user.uid) {
            setState(() {
              bookedSlots.add(new ParkingSlot(i, isOccupied, isVerify, false));
            });
          } else {
            setState(() {
              parkingSlots.add(new ParkingSlot(i, isOccupied, isVerify, false));
            });
          }
        } else if (isVerify != null) {
          if (!isVerify && isOccupied) {
            String userIDBookedByTheUser;
            userIDBookedByTheUser = value.data()['parkingSlot$i']['ownerID'];
            if (userIDBookedByTheUser == user.uid) {
              setState(() {
                pendingSlots
                    .add(new ParkingSlot(i, isOccupied, isVerify, false));
              });
            }
          }
        } else {
          setState(() {
            parkingSlots.add(new ParkingSlot(i, isOccupied, isVerify, false));
          });
        }
      }
      setState(() {
        isLoaded = !isLoaded;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    ////print("location ${widget.location}");
    getData();
  }

  TextEditingController _passwordController =
      new TextEditingController(text: "");

  Future<void> bookParkingSlots() async {
    //print(availableLocationsSelected);
    if (availableLocationsSelected.length > 0) {
      _showDialog(true);
    } else {
      //print("Select Atleast One");
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(
          "Please Select Atleast One",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _showDialog(bool isBooked) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
        context: key.currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Enter your account password:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            content: Container(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
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
                ),
                SizedBox(height: 30),
                RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      String encryptedPassword;
                      FirebaseAuth auth = FirebaseAuth.instance;
                      User user = await auth.currentUser;
                      await FirebaseFirestore.instance
                          .collection("parkingSlotsPassword")
                          .doc(user.uid)
                          .get()
                          .then((value) {
                        encryptedPassword = value.data()['password'];
                      });
                      var pass = Crypt(encryptedPassword);

                      if (pass.match(_passwordController.text + "@1234!")) {
                        //print("PAssword Matched");
                        if (isBooked) {
                          book();
                        } else {
                          unbook();
                        }
                        Navigator.of(key.currentContext).pop();
                      } else {
                        Scaffold.of(key.currentContext).showSnackBar(SnackBar(
                          content: Text(
                            "Incorrect Password",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          backgroundColor: Colors.green,
                        ));
                      }
                    }
                  },
                  child: Text(isBooked ? "Book" : "UnBook"),
                )
              ],
            )),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.all(20),
          );
        });
  }

  Future<void> unbookParkingSlots() async {
    //print(bookedLocationsSelected);
    if (bookedLocationsSelected.length > 0) {
      _showDialog(false);
    } else {
      //print("Select Atleast One");
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(
          "Please Select Atleast One",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ));
    }
  }

  void unbook() async {
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
      content: Text(
        "Please wait we are unbooking...",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.green,
      duration: Duration(minutes: 5),
    ));
    int occupancy;
    int availableSlots;
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("towersInfo").doc("mainInfo").get().then((onValue) {
      occupancy = onValue.data()['occupancy'];
      availableSlots = onValue.data()['availableSlots'];
    });
    await db.collection("towersInfo").doc("mainInfo").update({
      'occupancy': occupancy - bookedLocationsSelected.length,
      'availableSlots': availableSlots + bookedLocationsSelected.length
    });

    for (int i = 1; i <= bookedLocationsSelected.length; i++) {
      await db.collection("towersInfo").doc('tower${widget.location}').update({
        'parkingSlot${bookedLocationsSelected.toList()[i - 1]}': {
          'isOccupied': false,
        }
      });
    }
    int availableParkingSlots;
    int occupiedParkingSlots;
    await db.collection("towersInfo").doc("towers").get().then((value) {
      availableParkingSlots =
          value.data()['tower${widget.location}']['availableSlots'];
      occupiedParkingSlots =
          value.data()['tower${widget.location}']['occupied'];
    });
    await db.collection("towersInfo").doc("towers").update({
      'tower${widget.location}': {
        'availableSlots':
            availableParkingSlots + bookedLocationsSelected.length,
        'occupied': occupiedParkingSlots - bookedLocationsSelected.length,
      }
    });
    //print("Data Updated Successfuly");
    Scaffold.of(key.currentContext).removeCurrentSnackBar();
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
      content: Text(
        "UnBooked  Successfully",
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
    bookedLocationsSelected.clear();
  }

  void book() async {
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
      content: Text(
        "Please wait we are booking...",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.green,
      duration: Duration(minutes: 5),
    ));
    int occupancy;
    int availableSlots;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    User user = (await auth.currentUser);
    //print("user id is ${user.uid}");
    await db.collection("towersInfo").doc("mainInfo").get().then((onValue) {
      occupancy = onValue.data()['occupancy'];
      availableSlots = onValue.data()['availableSlots'];
    });
    await db.collection("towersInfo").doc("mainInfo").update({
      'occupancy': occupancy + availableLocationsSelected.length,
      'availableSlots': availableSlots - availableLocationsSelected.length,
    });

    for (int i = 1; i <= availableLocationsSelected.length; i++) {
      await db.collection("towersInfo").doc('tower${widget.location}').update({
        'parkingSlot${availableLocationsSelected.toList()[i - 1]}': {
          'isOccupied': true,
          'ownerID': user.uid,
          'occupiedTimeStamp': DateTime.now().millisecondsSinceEpoch,
          'isVarify': false,
        }
      });
    }
    int availableParkingSlots;
    int occupiedParkingSlots;
    await db.collection("towersInfo").doc("towers").get().then((value) {
      availableParkingSlots =
          value.data()['tower${widget.location}']['availableSlots'];
      occupiedParkingSlots =
          value.data()['tower${widget.location}']['occupied'];
    });
    await db.collection("towersInfo").doc("towers").update({
      'tower${widget.location}': {
        'availableSlots':
            availableParkingSlots - availableLocationsSelected.length,
        'occupied': occupiedParkingSlots + availableLocationsSelected.length,
      }
    });
    //print("Data Updated Successfuly");
    //Scaffold.of(key.currentContext).removeCurrentSnackBar();
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
      content: Text(
        "Booked Request  Sent",
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
    availableLocationsSelected.clear();
  }

  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Tower " + widget.location.toString()),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
      ),
      body:
          ListView(key: key, scrollDirection: Axis.vertical, children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(18.0),
            child: parkingSlots.length > 0
                ? OrientationBuilder(
                    builder: (context, orientation) => GridView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: parkingSlots.length,
                      itemBuilder: (itemBuilder, index) =>
                          parkingSlots.length <= 0
                              ? CircularProgressIndicator()
                              : GridItemForAvaialbleSlots(parkingSlots[index]),
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  orientation == Orientation.portrait ? 3 : 5,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20),
                    ),
                  )
                : bookedSlots.length > 0
                    ? null
                    : Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ))),
        Container(
          child: parkingSlots.length > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "Occupied  ",
                          style: TextStyle(fontSize: 14),
                        ),
                        Container(
                          width: 15,
                          height: 15,
                          color: Colors.red,
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Pending  ",
                          style: TextStyle(fontSize: 14),
                        ),
                        Container(
                          width: 15,
                          height: 15,
                          color: Colors.blue,
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Available  ",
                          style: TextStyle(fontSize: 14),
                        ),
                        Container(
                            width: 15, height: 15, color: Colors.orangeAccent)
                      ],
                    ),
                  ],
                )
              : null,
        ),
        Container(
          child: parkingSlots.length > 0
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: RaisedButton(
                    onPressed: () {
                      bookParkingSlots();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: Text(
                        "Book Selected Parking Slots",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: pendingSlots.length > 0
              ? Container(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Your Requested Parking Slots",
                          style: TextStyle(
                            color: Color.fromRGBO(37, 52, 112, 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      OrientationBuilder(
                        builder: (context, orientation) {
                          return GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: pendingSlots.length,
                            itemBuilder: (context, index) {
                              return GridItemForBookedSlots(
                                  bookedSlot: pendingSlots[index]);
                            },
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        orientation == Orientation.portrait
                                            ? 3
                                            : 5,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: RaisedButton(
                          onPressed: () {
                            unbookParkingSlots();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10),
                            child: Text(
                              "Cancle Parking",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  ),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: bookedSlots.length > 0
              ? Container(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Your Booked Parking Slots",
                          style: TextStyle(
                            color: Color.fromRGBO(37, 52, 112, 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      OrientationBuilder(
                        builder: (context, orientation) {
                          return GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: bookedSlots.length,
                            itemBuilder: (context, index) {
                              return GridItemForBookedSlots(
                                  bookedSlot: bookedSlots[index]);
                            },
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        orientation == Orientation.portrait
                                            ? 3
                                            : 5,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: RaisedButton(
                          onPressed: () {
                            unbookParkingSlots();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10),
                            child: Text(
                              "Cancle Parking",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  ),
                )
              : null,
        ),
      ]),
    );
  }
}

class GridItemForAvaialbleSlots extends StatefulWidget {
  final ParkingSlot parkingSlot;
  GridItemForAvaialbleSlots(this.parkingSlot);
  @override
  _GridItemForAvaialbleSlotsState createState() =>
      _GridItemForAvaialbleSlotsState();
}

Set<int> availableLocationsSelected = new Set();
Set<int> bookedLocationsSelected = new Set();

class _GridItemForAvaialbleSlotsState extends State<GridItemForAvaialbleSlots> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!widget.parkingSlot.isOccupied) {
            widget.parkingSlot.isSelected = !widget.parkingSlot.isSelected;
            if (widget.parkingSlot.isSelected) {
              availableLocationsSelected.add(widget.parkingSlot.location);
            } else {
              availableLocationsSelected.remove(widget.parkingSlot.location);
            }
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                "Already Occupied",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ));
          }
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: widget.parkingSlot.isOccupied
                ? Colors.red
                : Colors.orangeAccent,
            borderRadius: BorderRadius.circular(20),
            border: widget.parkingSlot.isSelected
                ? BorderDirectional(
                    start: BorderSide(color: Colors.green, width: 5),
                    top: BorderSide(color: Colors.green, width: 5),
                    bottom: BorderSide(color: Colors.green, width: 5),
                    end: BorderSide(color: Colors.green, width: 5))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                widget.parkingSlot.location.toString(),
                style: TextStyle(fontSize: 25),
              )),
            ],
          )),
    );
  }
}

class GridItemForBookedSlots extends StatefulWidget {
  final ParkingSlot bookedSlot;
  GridItemForBookedSlots({this.bookedSlot});
  @override
  _GridItemForBookedSlotsState createState() => _GridItemForBookedSlotsState();
}

class _GridItemForBookedSlotsState extends State<GridItemForBookedSlots> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //print(widget.bookedSlot.location);
        setState(() {
          widget.bookedSlot.isSelected = !widget.bookedSlot.isSelected;
          if (widget.bookedSlot.isSelected) {
            bookedLocationsSelected.add(widget.bookedSlot.location);
          } else {
            bookedLocationsSelected.remove(widget.bookedSlot.location);
          }
        });
        //print(bookedLocationsSelected);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.bookedSlot.isverify ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(20),
          border: widget.bookedSlot.isSelected
              ? BorderDirectional(
                  start: BorderSide(color: Colors.green, width: 5),
                  top: BorderSide(color: Colors.green, width: 5),
                  bottom: BorderSide(color: Colors.green, width: 5),
                  end: BorderSide(color: Colors.green, width: 5))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                widget.bookedSlot.location.toString(),
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
