import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/ui/auth/login_screen.dart';
import 'package:Chef/ui/firestore/firestore_list_screen.dart';

class SplashServices{

  void isLogin(BuildContext context){
    FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;
    if(user!=null){
      Timer(const Duration(seconds:3), () { 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ListScreen()));
    });
    }else{
      Timer(const Duration(seconds: 3), () { 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
    });
    }
  }

}