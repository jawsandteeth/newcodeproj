import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _ProfilePageState extends State<ProfilePage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final accountNumberController = TextEditingController();
  final IFSCCodeController = TextEditingController();
  final DCIRegIDController = TextEditingController();
  final currentLoggedinUser = FirebaseAuth.instance.currentUser;
  final CollectionReference  users = FirebaseFirestore.instance.collection('users');
  //Object obj = currentLoggedinUser.uid as Object;
  //String uid = "$currentLoggedinUser?.uid";
  final Stream<QuerySnapshot> userSnapshot = FirebaseFirestore.instance.collection('users').snapshots();
  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
       
  @override
  Widget build(BuildContext context) {
    String? email;
    if (currentLoggedinUser != null) {
      email = currentLoggedinUser?.email;
    }
   
    Future<void> updateUser() {
      // Call the user's CollectionReference to add a new user
      return users
          .doc(currentLoggedinUser?.uid).set({
            'email': email, // John Doe
            'name': nameController.text, // Stokes and Sons
            'phone': phoneNumberController.text,
            'accountNumber': accountNumberController.text,
            'IFSCCode': IFSCCodeController.text,
            'DCIRegID': DCIRegIDController.text,
          })
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }
    String? _directoryPath;
    List<PlatformFile>? _paths;
    FileType _pickingType = FileType.custom;
    bool _multiPick = false;
    String? _extension;
    bool _lockParentWindow = false;
    bool _isLoading = false;
    String? _fileName;
    Uint8List fileBytes = new Uint8List(1);
    String? fileName = null;
    String? fileExtension = null;
    void _pickFiles(String uploadType) async {
    
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
        allowMultiple: _multiPick,
        onFileLoading: (FilePickerStatus status) => print(status),
        
        //dialogTitle: _dialogTitleController.text,
        //initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation s' + e.toString());
    } catch (e) {
      print('log here'+e.toString());
    }
    
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      print(_fileName);
      PlatformFile result ;

      
      _paths?.forEach((element) { 
        print(element.name);
        fileBytes = element.bytes as Uint8List;
        fileName = element.name;
        fileExtension = element.name.split('.').last;
        });

    
      _paths == null;
    });
    try {
        String? currentUserUID = currentLoggedinUser?.uid.toString();
        await FirebaseStorage.instance.ref('users/$currentUserUID/$uploadType.$fileExtension').putData(fileBytes);
      } catch (e) {
        // ...
        print(e);
      };
  }
    return StreamBuilder<QuerySnapshot>(
      stream: userSnapshot,
      builder: ( context, snapshot) {
        List products = new List.empty();
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        //Map<String, dynamic> data = snapshot.data! as Map<String, dynamic>;
        
        if(snapshot.hasData){
          
          final snapshotData = snapshot.data;
          if(snapshotData !=null)
          {  
            products = snapshotData.docs;
          }
        }
        //snapshot.requireData.docs.forEach((element) {print(element["name"]);});
        snapshot.requireData.docs.forEach((element) {
          //name =name + element["name"];
          //phoneNumber =phoneNumber + element["phone"];
          try{nameController.text = element["name"];}catch(e){}
          try{phoneNumberController.text = element["phone"];}catch(e){}
          try{accountNumberController.text = element["accountNumber"];}catch(e){}
          try{IFSCCodeController.text = element["IFSCCode"];}catch(e){}
          try{DCIRegIDController.text = element["DCIRegID"];}catch(e){}
        });
        
        
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('User Profile'),
          ),
          body: Padding(  
            padding: EdgeInsets.all(15),  
            child: Column(  
              children: <Widget>[  
                
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      labelText: email,  
                      hintText: 'Email',  
                      enabled:false,
                    ),  
                  ),  
                ),  
                ElevatedButton(  
                  child: Text('upload Profle Photo'),  
                  onPressed: ()=>_pickFiles('photo'),  
                ),
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: nameController,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      //labelText: name,  
                      helperText:  'Enter Full Name',
                    ),  
                  ),  
                ),  
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: phoneNumberController,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      //labelText: phoneNumber,  
                      helperText: 'Enter Phone Number with country code',
                    ),  
                  ),  
                ),
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: accountNumberController,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      //labelText: phoneNumber,  
                      helperText: 'Enter Bank Account Number',
                    ),  
                  ),  
                ),
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: IFSCCodeController,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      //labelText: phoneNumber,  
                      helperText: 'Enter Bank IFSC Code',
                    ),  
                  ),  
                ),
                Padding(  
                  padding: EdgeInsets.all(15),  
                  child: TextField(  
                    controller: DCIRegIDController,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      //labelText: phoneNumber,  
                      helperText: 'Enter DCI Registration Code',
                    ),  
                  ),  
                ),
                ElevatedButton(  
                  child: Text('upload PAN'),  
                  onPressed: ()=>_pickFiles('pan'),  
                ),
                ElevatedButton(  
                  child: Text('upload Aadhaar'),  
                  onPressed: ()=>_pickFiles('aadhaar'),  
                ),
                ElevatedButton(  
                  child: Text('upload DCI Regn'),  
                  onPressed: ()=>_pickFiles('dci'),  
                ),
                ElevatedButton(  
                  child: Text('Save'),  
                  onPressed: updateUser,  
                ),
                
                
              ],
            ),
          ),
        );
      }
    );
  }
}
