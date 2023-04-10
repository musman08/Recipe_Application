import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Chef/Provider/providerScenes.dart';
import 'package:Chef/ui/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    // apiKey: "AIzaSyDStD1x-cE3vI0aBD_PDSJgMQcH_bFwkNo",
    // projectId: "foodapp-ab2e9",
    // messagingSenderId: "73292080923",
    // appId: "1:73292080923:web:57d8d50cb62b63c1e8d5be",
    // databaseURL: "https://foodapp-ab2e9-default-rtdb.firebaseio.com",
    //   )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
      create: (_)=> ProviderScene(),
    ),
    ChangeNotifierProvider(create: (_) => ProviderImage() )
      ],
      child: MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const SplashScreen(),
    ),
      );
    

    
  }
}
