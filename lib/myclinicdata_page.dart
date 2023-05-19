import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'add_user_page.dart';
import 'add_appointment_page.dart';
import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:flutter/cupertino.dart';

Future<List<dynamic>> showPatientAppointments(String userID, String clinicID,
    StreamController patientAppointmentStreamController) async {
  Map<String, dynamic> parsedData;
  late List<dynamic> patientAppointments;
  try {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getPatientAppointments');

    final result = await callable(
        <String, dynamic>{'userid': userID, 'clinicid': clinicID});
    //print(result.data);

    parsedData = jsonDecode(result.data);
    patientAppointments = parsedData["patientAppointments"];

    //print(parsedData["patientAppointments"]);
    patientAppointmentStreamController.sink.add(patientAppointments);
  } catch (e) {
    print(e);
  }
  return patientAppointments;
}

Future<List<dynamic>> showPatientPrescriptions(
    String userID, String clinicID) async {
  List<dynamic> myList = [];
  //print(userID + " " + clinicID);
  /*HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getMyClinicData');
  final result = await callable();
  Map<String, dynamic> resultJson = jsonDecode(result.data);
  List<dynamic> myClinic = resultJson["clinicAssociatedPatients"];
  myClinic.forEach((element) {
    //print(element["name"]);
    myList.add(ClinicData.fromJson(element["name"], element["docID"]));
  });*/
  return myList;
}

Future<List<dynamic>> showPatientInvoicePaymentHistory(
    String userID, String clinicID) async {
  List<dynamic> myList = [];
  //print(userID + " " + clinicID);
  /*HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getMyClinicData');
  final result = await callable();
  Map<String, dynamic> resultJson = jsonDecode(result.data);
  List<dynamic> myClinic = resultJson["clinicAssociatedPatients"];
  myClinic.forEach((element) {
    //print(element["name"]);
    myList.add(ClinicData.fromJson(element["name"], element["docID"]));
  });  */
  return myList;
}

Future<List<dynamic>> showPatientRecordHistory(
    String userID, String clinicID) async {
  List<dynamic> myList = [];
  //print(userID + " " + clinicID);
  /*HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getMyClinicData');
  final result = await callable();
  Map<String, dynamic> resultJson = jsonDecode(result.data);
  List<dynamic> myClinic = resultJson["clinicAssociatedPatients"];
  myClinic.forEach((element) {
    //print(element["name"]);
    myList.add(ClinicData.fromJson(element["name"], element["docID"]));
  });  */
  return myList;
}

Future<List<ClinicData>> getData() async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('getMyClinicData');
  final result = await callable();
  Map<String, dynamic> resultJson = jsonDecode(result.data);
  List<dynamic> myClinic = resultJson["clinicAssociatedPatients"];
  List<ClinicData> myList = [];
  myClinic.forEach((element) {
    //print(element["name"]);
    myList.add(ClinicData.fromJson(element["name"], element["docID"]));
  });
  return myList;
}

Future<List<Patient>> searchPatients(String searchQueryValue) async {
  var result;
  List<Patient> myList = [];
  if (searchQueryValue.length >= 3) {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('searchPatients');
      result = await callable(searchQueryValue);
      //print(result.data);
      Map<String, dynamic> resultJson = jsonDecode(result.data);
      if (resultJson.isNotEmpty) {
        List<dynamic> patientList = resultJson["patientList"];
        patientList.forEach((element) {
          //print(element["name"]);
          myList.add(Patient.fromJson(
            element["name"],
            element["email"],
            element["phone"],
            element["age"],
            element["gender"],
            element["reverseLookup"],
          ));
        });
      }
    } catch (e) {
      log("searchPatients exception ");
      log(e.toString());
    }
  }
  //print(myList);
  return myList;
}

@immutable
class Patient {
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String patientAge;
  final String patientGender;
  final String patientReverseLookup;

  Patient({
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.patientAge,
    required this.patientGender,
    required this.patientReverseLookup,
  });

  factory Patient.fromJson(String name, String email, String phone, String age,
      String gender, String reverseLookup) {
    return Patient(
      patientName: name,
      patientEmail: email,
      patientPhone: phone,
      patientAge: age,
      patientGender: gender,
      patientReverseLookup: reverseLookup,
    );
  }
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Patient &&
        other.patientName == patientName &&
        other.patientEmail == patientEmail &&
        other.patientPhone == patientPhone &&
        other.patientReverseLookup == patientReverseLookup;
  }

  @override
  int get hashCode => Object.hash(
      patientName, patientEmail, patientPhone, patientReverseLookup);
}

class ClinicData {
  final String clinicName;
  final String clinicReverseLookup;

  const ClinicData({
    required this.clinicName,
    required this.clinicReverseLookup,
  });

  factory ClinicData.fromJson(String name, String docID) {
    return ClinicData(
      clinicName: name,
      clinicReverseLookup: docID,
    );
  }
}

class MyClinicDataPage extends StatefulWidget {
  const MyClinicDataPage({super.key});
  @override
  State<MyClinicDataPage> createState() => MyClinicDataPageState();
}

class MyClinicDataPageState extends State<MyClinicDataPage> {
  final appCheck = FirebaseAppCheck.instance;
  TextEditingController textController = TextEditingController();
  late TextEditingController autocompleteTextEditingController;
  final patientStreamController = StreamController<Patient>();
  final patientAppointmentStreamController = StreamController<List<dynamic>>();
  final patientPrescriptionStreamController = StreamController<List<dynamic>>();
  final patientInvoicePaymentsStreamController =
      StreamController<List<dynamic>>();
  final patientRecordStreamController = StreamController<List<dynamic>>();
  @override
  void initState() {
    super.initState();
  }

  void setEventToken(String? token) {}

  @override
  Widget build(BuildContext context) {
    List<String?> clinicNameTitle =
        ModalRoute.of(context)!.settings.arguments as List<String?>;
    List<dynamic> temp = [];
    String selectedPatientReverseLookup = "";
    //patientAppointmentStreamController.sink.add("");
    // print(clinicNameTitle[1]);
    return Scaffold(
      appBar: AppBar(
        title: Text(clinicNameTitle[0] as String),
      ),
      body: SingleChildScrollView(child:Column(children: <Widget>[
          Row(
            children: [
             
                  IconButton(
                      icon: const Icon(
                        Icons.home,
                        size: 40,
                      ),
                      onPressed: () {
                        patientStreamController.sink.add(Patient(
                            patientName: "",
                            patientEmail: "",
                            patientPhone: "",
                            patientAge: "",
                            patientGender: "",
                            patientReverseLookup: ""));

                        patientAppointmentStreamController.sink.add(temp);
                        autocompleteTextEditingController.text = "";
                      }),
               
              
                IconButton(
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddUserPage(),
                          settings: RouteSettings(
                            arguments: [clinicNameTitle[0], clinicNameTitle[1]],
                          ),
                        ));
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 200,
                  
                  child: Autocomplete(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return searchPatients(textEditingValue.text);
                      },
                      onSelected: (Patient selection) {
                        patientStreamController.sink.add(selection);
                        patientAppointmentStreamController.sink.add(temp);
                      },
                      displayStringForOption: (Patient option) =>
                          option.patientName,
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        autocompleteTextEditingController =
                            textEditingController;
                        return TextFormField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText:
                                'Enter 3 letters to start searching customer',
                          ),
                          focusNode: focusNode,
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                          validator: (String? value) {
                            return null;
                          },
                        );
                      }),
                ),
                //Icon(Icons.person_search_rounded),
              //]),
            ],
          ),
          Column(children: [
                StreamBuilder<Patient>(
                  stream: patientStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      selectedPatientReverseLookup =
                          snapshot.data?.patientReverseLookup as String;

                      if (snapshot.data?.patientName == "") {
                        log("Empty name");
                        return const SizedBox(height:300);
                      }
                      return SizedBox(
                        height: 300,
                        child:Column(children: [Expanded(
                          child: ListView(children: [
                            ListTile(
                              title: Text (snapshot.data?.patientName as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                                leading: const Icon(Icons.person_outlined, size: 30),
                            ),
                            ListTile(
                              title: Text (snapshot.data?.patientEmail as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                                leading: const Icon(Icons.email_outlined, size: 30),
                            ),
                            ListTile(
                              title: Text (snapshot.data?.patientPhone as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                                leading: const Icon(Icons.smartphone_outlined, size: 30),
                            ),
                            ListTile(
                              title: Text (snapshot.data?.patientAge as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                                leading: const Icon(Icons.update_outlined, size: 30),
                            ),
                            ListTile(
                              title: Text (snapshot.data?.patientGender as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                                leading: Icon(CupertinoIcons.sparkles, size: 30),
                            )
                          ],)),
                          Row(
                        children: [
                          IconButton(
                              icon: const Icon(
                                Icons.calendar_month,
                                size: 40,
                              ),
                              onPressed: () {
                                showPatientAppointments(
                                  selectedPatientReverseLookup,
                                  clinicNameTitle[1] as String,
                                  patientAppointmentStreamController,
                                );
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.medication_liquid_outlined,
                                size: 40,
                              ),
                              onPressed: () {
                                showPatientPrescriptions(
                                  selectedPatientReverseLookup,
                                  clinicNameTitle[1] as String,
                                );
                                //patientAppointmentStreamController.sink.add("Prescription");
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.currency_rupee_outlined,
                                size: 40,
                              ),
                              onPressed: () {
                                showPatientInvoicePaymentHistory(
                                  selectedPatientReverseLookup,
                                  clinicNameTitle[1] as String,
                                );
                                //patientAppointmentStreamController.sink.add("InvoicePayment");
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.file_present,
                                size: 40,
                              ),
                              onPressed: () {
                                showPatientRecordHistory(
                                  selectedPatientReverseLookup,
                                  clinicNameTitle[1] as String,
                                );
                                //patientAppointmentStreamController.sink.add("Records");
                              }),
                          IconButton(
                              icon: const Icon(
                                CupertinoIcons.bag_badge_plus,
                                size: 40,
                              ),
                              onPressed: () {
                                showPatientRecordHistory(
                                  selectedPatientReverseLookup,
                                  clinicNameTitle[1] as String,
                                );
                                //patientAppointmentStreamController.sink.add("Records");
                              }),
                        ],
                      ),
                          ]));
                        
                    } else if (snapshot.hasError) {
                      return SizedBox(height: 300,child:Text('Failed to load data'));
                    }
                    else{
                      return const SizedBox(height:300);
                    }
                  },
                ),
                
                      
                      StreamBuilder<List<dynamic>>(
                          stream: patientAppointmentStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var listLength = snapshot.data?.length;
                              //log("List length $listLength");
                              return SizedBox(
                        height: 300,
                        child:Column(children: [Expanded(
                          child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: (snapshot.data?.length)! + 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      //log("Index $index");
                                      if (listLength! >= 1) {
                                        if (index == 0) {
                                          return Text("Upcoming Appointments",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge);
                                        }
                                        var appointment =
                                            snapshot.data?[index - 1];
                                        //print(appointment);
                                        var seconds = appointment["when"];
                                        //print(seconds["_seconds"]);
                                        DateTime appointmentDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                seconds["_seconds"] * 1000);
                                        String fomrattedDate =
                                            DateFormat('dd-MMM-yy hh:mm a')
                                                .format(appointmentDate);
                                        return GestureDetector(
                                            onTap: () => {},
                                            child: Card(
                                                child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Stack(children: <Widget>[
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 40,
                                                        ),
                                                        Text(fomrattedDate,
                                                            //"trying to get time",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on_outlined,
                                                          size: 40,
                                                        ),
                                                        Text(
                                                            appointment[
                                                                "where"],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle_outline,
                                                          size: 40,
                                                        ),
                                                        Text(
                                                            appointment[
                                                                "status"],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 10,
                                                  child: FloatingActionButton(
                                                    child: const Icon(
                                                      Icons.edit_calendar,
                                                      size: 30,
                                                    ),
                                                    onPressed: () =>
                                                        log('Button pressed!'),
                                                  ),
                                                ),
                                              ]),
                                            )));
                                      } else {
                                        return Text("No Upcoming appoitnments",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge);
                                      }
                                    },
                              ))]));
                            } else {
                              return Container();
                            }
                          }),
                          IconButton(
                              icon: const Icon(
                                CupertinoIcons.calendar_badge_plus,
                                size: 40,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddAppointmentPage(),
                                      settings: RouteSettings(
                                        arguments: [clinicNameTitle[0], clinicNameTitle[1], selectedPatientReverseLookup],
                                      ),
                                    ));
                              
                                //patientAppointmentStreamController.sink.add("Records");
                              }),
              ],  
          ),
        ])),
      
    );
  }
}
