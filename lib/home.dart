
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'profile_page.dart';
import 'myclinicdata_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

Future<List<Album>> getData() async{
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getMyClinics');
  final result = await callable();
  Map<String, dynamic> resultJson = jsonDecode(result.data);
  List<dynamic> myClinic = resultJson["myAssociatedClinics"];
  List<Album> myList = [];
  myClinic.forEach((element) {
    //print(element["name"]);
    myList.add(Album.fromJson(element["name"], element["docID"]));
  });  
  return myList;
}

class Album {
  final String clinicName;
  final String reverseLookup;
  
  const Album({
    required this.clinicName,
    required this.reverseLookup,
  });

  factory Album.fromJson(String name, String docID)  {
    return Album(
      clinicName: name,
      reverseLookup: docID,
    );
  }
}
class HomeScreenState extends State<HomeScreen> {  
late Future<List<Album>> futureAlbum;
  @override
  void initState(){
    super.initState();
    futureAlbum = getData();
  }
 @override
 Widget build(BuildContext context) {
  int selectedClinicIndex = -1;

   return Scaffold(
     appBar: AppBar(
       title: const Text('Jaws and Teeth Dental Clinic'),
       actions: [
         IconButton(
           icon: const Icon(Icons.person),
           onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
           },
         )
       ],
       automaticallyImplyLeading: false,
     ),
     body: Center(
       child: Column(
         children: [
           Flexible(child:Text(
             'Welcome!',
             style: Theme.of(context).textTheme.displaySmall,
           ),),
           FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(child:ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                    onTap: () =>{
                      // print("click ${snapshot.data?[index].reverseLookup}"),
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyClinicDataPage(),
                        settings: RouteSettings(
                          arguments: [snapshot.data?[index].clinicName, snapshot.data?[index].reverseLookup,],
                        ),
                        ),
                      )},
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('${snapshot.data?[index].clinicName}')
                      ),
                    )
                    );
                  },
                ));
              } else if (snapshot.hasError) {
                return Text('Failed to load data');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
           const SignOutButton(),
         ],
       ),
     ),
   );
 }
}