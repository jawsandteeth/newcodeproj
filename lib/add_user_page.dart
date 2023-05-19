import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';


final nameController = TextEditingController();
final phoneNumberController = TextEditingController();
final emailController = TextEditingController();
final ageController = TextEditingController();
enum Gender { male, female, others}

Gender gender =Gender.male;

Future<void> addPatientData(List<String?> clinicDetails) async{
  try{
    
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addPatientsUser');
    final result = await callable(
      {
        "name": nameController.text,
        "phoneNumber": phoneNumberController.text,
        "email": emailController.text,
        "age": ageController.text,
        "gender":gender.toString().split('.')[1],
        "associatedClinic":clinicDetails[1],
      }
    );
  }
  catch (e){
    print(e);
  }
  return;
}
class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});
  @override
  State<AddUserPage> createState() => AddUserPageState();
}
 
class AddUserPageState extends State<AddUserPage> {  
    final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    nameController.text="";
    phoneNumberController.text="";
    emailController.text="";
    ageController.text="";
    gender = Gender.male;
  }
 
  @override
  Widget build(BuildContext context) {
    List<String?> clinicNameTitle = ModalRoute.of(context)!.settings.arguments as List<String?>;
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    return Scaffold(
      appBar: AppBar(
       title: const Text('Enter customer details'),
      ),
      body:Form(key: _formKey,
        child:Padding(padding: EdgeInsets.all(15), 
      child: Column( 
        children: <Widget>[  
                
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextFormField(  
                    controller: nameController,
                    validator: (value) {
                      //print ("inside validation");
                      if (value == null || value.isEmpty || value.length < 3) {
                        return 'Please enter atleast 3 letters';
                      }
                      else if (value[0] == ' ') {
                        return 'Plese remove white space at the begining';
                      }
                      return null ;
                    },
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      hintText: 'Enter Full name',  
                      enabled:true,
                    ),  
                  ),  
                ),  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if(!EmailValidator.validate(value as String)) {
                        return 'Please enter a valid Email ID';
                      }
                    },
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      hintText: 'Email',  
                      enabled:true,
                    ),  
                  ),  
                ),  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextFormField(  
                    controller: phoneNumberController,
                    validator: (value) {
                      var ret;
                      if (value == null || value.isEmpty || value.length < 10 || value.length > 10) {
                        return 'Please enter 10 digit phone number';
                      }
                      else {
                        ret = int.tryParse(value);
                        if (ret == null){
                          return 'Enter only numbers';
                        }
                        if(ret <= 999999999) {
                          return 'Please enter 10 digit phone number';
                        }
                      }
                      return null ;
                    },
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      hintText: 'Phone Number',  
                      enabled:true,
                    ),  
                  ),  
                ), 
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextFormField(  
                    controller: ageController,
                    validator: (value) {
                      var ret;
                      if (value == null || value.isEmpty || value.length > 3) {
                        return 'Please enter age';
                      }
                      else {
                        ret = int.tryParse(value);
                        if (ret == null){
                          return 'Enter only numbers';
                        }
                        if(ret > 200 || ret < 0) {
                          return 'Please enter age';
                        }
                      }
                      return null ;
                    },
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      hintText: 'Age as on ' + DateFormat.yMMMd(tag).format(DateTime.now()),  
                      enabled:true,
                    ),  
                  ),  
                ),  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Male'),
                        leading: Radio(
                          value: Gender.male,
                          groupValue: gender,
                          onChanged: (value){setState(() {
                            gender=value as Gender;
                          });},
                        )
                      ),
                      ListTile(
                        title: const Text('Female'),
                        leading: Radio(
                          value: Gender.female,
                          groupValue: gender,
                          onChanged: (value){setState(() {
                            gender = value as Gender;
                          });},
                        )
                      ),
                      ListTile(
                        title: const Text('Others'),
                        leading: Radio(
                          value: Gender.others,
                          groupValue: gender,
                          onChanged: (value){setState(() {
                            gender=value as Gender;
                          });},
                        )
                      )
                    ]
                  )
                ), 
                ElevatedButton(  
                  child: Text('Save'),  
                  onPressed: (){if (_formKey.currentState!.validate()) 
                  {
                    addPatientData(clinicNameTitle);
                    Navigator.pop(context);
                  }},
                ),
                //Padding(  
                  //padding: EdgeInsets.all(15),  
                  //child: 
                    //DatePickerDialog(initialDate: DateTime.now(),
                      //firstDate: DateTime(1900, 1, 1),
                      //lastDate: DateTime.now(),)
                //),  
        ]
      )
      ))

    );
  }
}