
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'profile_page.dart';
import 'myclinicdata_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
import 'dart:developer';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

Future<List<MyClinic>> getMyClnics() async{
  List<MyClinic> myList = [];
  try{
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getMyClinics');
    final result = await callable();
    Map<String, dynamic> resultJson = jsonDecode(result.data);
    List<dynamic> myClinic = resultJson["myAssociatedClinics"];
    
    myClinic.forEach((element) {
      myList.add(MyClinic.fromJson(element["name"], element["docID"]));
    }); 
  }
  catch (e){
    log("Exception in getMyClnics " + e.toString());
  } 
  return myList;
}

class MyClinic {
  final String clinicName;
  final String reverseLookup;
  
  const MyClinic({
    required this.clinicName,
    required this.reverseLookup,
  });

  factory MyClinic.fromJson(String name, String docID)  {
    return MyClinic(
      clinicName: name,
      reverseLookup: docID,
    );
  }
}
class HomeScreenState extends State<HomeScreen> {  
late Future<List<MyClinic>> futureMyClinic;
  @override
  void initState(){
    super.initState();
    futureMyClinic = getMyClnics();
  }
 @override
 Widget build(BuildContext context) {
  int selectedClinicIndex = -1;

   return Scaffold(
     appBar: AppBar(
       title: const Text('Jaws and Teeth Dental Clinic'),
       /*actions: [
         IconButton(
           icon: const Icon(Icons.person),
           onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
           },
         )
       ],*/
     ),
     body: Center(
       child: Column(
         children: [
           Flexible(child:Text(
             'Welcome!',
             style: Theme.of(context).textTheme.displaySmall,
           ),),
           
           const SignOutButton(),
         ],
       ),
     ),
     drawer: Drawer(
      //shape:CircularNotchedRectangle(),
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  image: AssetImage("assets/jawsandteeth_128X128.png"),
                     fit: BoxFit.contain)
            ),
            child: Container(),
          ),
          Column(children:[
          const ListTile(
            title: Text('My Clinics'),
          ),
          Padding(
            padding:const EdgeInsets.all(1.0),
            child: FutureBuilder<List<MyClinic>>(
            future: futureMyClinic,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading:const Icon(Icons.location_on_outlined),
                      title: 
                        Text('${snapshot.data?[index].clinicName}'),
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyClinicDataPage(),
                          settings: RouteSettings(
                            arguments: [snapshot.data?[index].clinicName, snapshot.data?[index].reverseLookup,],
                          ),
                          ),
                        );
                      }
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return const Icon(Icons.error_outline, color: Colors.red,);
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            }
          )
            
          ),
          ]
          ),
        ],
      ),
    ),
   );
 }
}