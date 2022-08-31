import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkingapp/lib1/circularprogess.dart';
import 'package:parkingapp/lib1/parking_screen.dart';

class AllBookDetails extends StatefulWidget {
  const AllBookDetails({Key key}) : super(key: key);

  @override
  State<AllBookDetails> createState() => _AllBookDetailsState();
}

class _AllBookDetailsState extends State<AllBookDetails> {
  List allData = [];
  List pendingBooking = [];
  List confrimBooking = [];
  int totalSize;
  int numberOfTowers;
  List<Tower> towers = new List();

  // CollectionReference _collectionRef =
  //     FirebaseFirestore.instance.collection("towersInfo");

  Future<List> getData() async {
    allData.clear();
    pendingBooking.clear();
    confrimBooking.clear();
    await FirebaseFirestore.instance
        .collection("towersInfo")
        .doc("mainInfo")
        .get()
        .then((value) {
      if (value != null) {
        totalSize = value.data()['occupancy'];
        numberOfTowers = value.data()['numberOfTowers'];
      }
    });

    for (var i = 1; i <= numberOfTowers; i++) {
      var response = await FirebaseFirestore.instance
          .collection("towersInfo")
          .doc("tower$i")
          .get();

      List totalplote = [];
      response.data().forEach((key, value) {
        if (value["isVarify"] != null) {
          pendingBooking.add({
            "towerID": "tower$i",
            "plotID": key.toString(),
            "ownerId": value["ownerID"],
            "occupiedTime": value["occupiedTimeStamp"],
            "isVarify": value["isVarify"]
          });

          // if (value["isVarify"] == true) {
          //   confrimBooking.add({
          //     "towerID": "tower$i",
          //     "plotID": key.toString(),
          //     "ownerId": value["ownerID"],
          //     "occupiedTime": value["occupiedTimeStamp"],
          //     "isVarify": value["isVarify"]
          //   });
          // }
        }
      });
    }
    //  print(pendingBooking);
    return pendingBooking;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            //getData();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          "Booking Details",
          style: GoogleFonts.roboto(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Object>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return pendingBooking.isEmpty
                    ? Container(
                        child: Center(
                        child: CircularProgress(),
                      ))
                    : ListView.builder(
                        itemCount: pendingBooking.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            //child: Text(allData.toString()),
                            child: BookingCard(
                              details: pendingBooking[index],
                              isAdmin: true,
                            ),
                          );
                        }),
                      );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.hasError.toString(),
                  ),
                );
              }
              return Center(
                child: CircularProgress(),
              );
            }),
      ),
    );
  }

  Widget BookingCard({@required details, @required isAdmin}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.orangeAccent,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    "TowerID: ${details["towerID"]} ".toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    "Booked DateTime: ${details["occupiedTime"]}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    "Plot ID: ${details["plotID"]}".toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.roboto(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isAdmin
                    ? InkWell(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("towersInfo")
                              .doc(details["towerID"])
                              .update({
                            details["plotID"]: {"isOccupied": false}
                          });

                          setState(() {});
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Chip(
                            backgroundColor: Colors.white,
                            label: Text(
                              "Delete",
                              style: GoogleFonts.roboto(
                                textStyle:
                                    Theme.of(context).textTheme.headline4,
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            deleteIcon: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.pink,
                                child: Icon(
                                  Icons.delete,
                                  size: 15,
                                )),
                            onDeleted: () async {
                              await FirebaseFirestore.instance
                                  .collection("towersInfo")
                                  .doc(details["towerID"])
                                  .update({
                                details["plotID"]: {"isOccupied": false}
                              });

                              setState(() {});
                            },
                          ),
                        ),
                      )
                    : Container(),
                InkWell(
                  onTap: () async {
                    if (details["isVarify"] == false) {
                      await FirebaseFirestore.instance
                          .collection("towersInfo")
                          .doc(details["towerID"])
                          .update({
                        details["plotID"]: {
                          "isOccupied": true,
                          "isVarify": true,
                          "ownerID": details["ownerId"],
                          "occupiedTimeStamp": details["occupiedTime"],
                        }
                      });

                      setState(() {});
                    }
                  },
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Chip(
                        backgroundColor: Colors.white,
                        label: details["isVarify"] == true
                            ? Text(
                                "Accepted",
                                style: GoogleFonts.roboto(
                                  textStyle:
                                      Theme.of(context).textTheme.headline4,
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                ),
                              )
                            : Text(
                                "Accept Booking",
                                style: GoogleFonts.roboto(
                                  textStyle:
                                      Theme.of(context).textTheme.headline4,
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                        deleteIcon: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.pink,
                          child: details["isVarify"] == true
                              ? Icon(
                                  Icons.check,
                                  size: 15,
                                )
                              : Icon(
                                  Icons.remove,
                                  size: 15,
                                ),
                        ),
                        onDeleted: () async {
                          if (details["isVarify"] == false) {
                            await FirebaseFirestore.instance
                                .collection("towersInfo")
                                .doc(details["towerID"])
                                .update({
                              details["plotID"]: {
                                "isOccupied": true,
                                "isVarify": true,
                                "ownerID": details["ownerId"],
                                "occupiedTimeStamp": details["occupiedTime"],
                              }
                            });
                          }
                        }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
