import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'home.dart';

class AuthGate extends StatelessWidget {
 const AuthGate({super.key});

 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
     stream: FirebaseAuth.instance.authStateChanges(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return SignInScreen(
           actions: [
            AuthStateChangeAction<SignedIn>((context, state) {
              if (!state.user!.emailVerified) {
                //Navigator.pushNamed(context, '/verify-email');
              } else {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            }),
          ],
         );
       }
       
       return const HomeScreen();
     },
   );
 }
}