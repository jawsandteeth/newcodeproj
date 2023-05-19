import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';

final resourcesController = TextEditingController();
final requiredUsersController = TextEditingController();


enum Gender { male, female, others }

Gender gender = Gender.male;

Future<void> addAppointment(List<String?> clinicDetails) async {
  try {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('addPatientsUser');
    final result = await callable({
      "phoneNumber": resourcesController.text,
      "gender": gender.toString().split('.')[1],
      "associatedClinic": clinicDetails[1],
    });
  } catch (e) {
    print(e);
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
    gender = Gender.male;
  }

  @override
  Widget build(BuildContext context) {
    List<String?> clinicNameTitle =
        ModalRoute.of(context)!.settings.arguments as List<String?>;
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
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
                      validator: (e) => (e?.day ?? 0) == 1
                          ? 'Please not the first day'
                          : null,
                      onDateSelected: (DateTime value) {
                        print(value);
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
                        addAppointment(clinicNameTitle);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  
                ]))));
  }
}
