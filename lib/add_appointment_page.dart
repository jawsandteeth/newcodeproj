import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';
import 'dart:developer';
final resourcesController = TextEditingController();
final requiredUsersController = TextEditingController();


DateTime appointmentTime = DateTime.now();

Future<void> addAppointment(List<String?> clinicDetails) async {
  try {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createAppointment');
    final result = await callable({
      "user": clinicDetails[2],
      "clinic": clinicDetails[1],
      "when": appointmentTime.toString(),
    }).then((result)=>{
      log("appointment created"),
    });
  } catch (e) {
    log("addAppointment exception" + e.toString());
  }
  return;
}

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});
  @override
  State<AddAppointmentPage> createState() => AddAppointmentPageState();
}

class AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    resourcesController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    List<String?> appointmentDetails =
        ModalRoute.of(context)!.settings.arguments as List<String?>;
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    log(appointmentDetails.toString());
    if(appointmentDetails[2] == "")
    {
      Navigator.pop(context);
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Enter Appointment details'),
        ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DateTimeFormField(
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black45),
                        errorStyle: TextStyle(color: Colors.redAccent),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Select Date and Time',
                      ),
                      mode: DateTimeFieldPickerMode.dateAndTime,
                      autovalidateMode: AutovalidateMode.always,
                      /*validator: (e) => (e?.day ?? 0) == 1
                          ? 'Please not the first day'
                          : null,*/
                      onDateSelected: (DateTime value) {
                        log(value.toString());
                        appointmentTime = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: requiredUsersController,
                      validator: (value) {
                        
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Required Users',
                        enabled: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: resourcesController,
                      validator: (value) {
                        
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Required Resources',
                        enabled: true,
                      ),
                    ),
                  ),
                  
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addAppointment(appointmentDetails);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  
                ]))));
  }
}
