import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/Provider/providerScenes.dart';
import 'package:Chef/ui/auth/verify_code.dart';
import 'package:Chef/ui/widgets/round_button.dart';
import 'package:Chef/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginWithPhoneNumber extends StatefulWidget {
  const LoginWithPhoneNumber({super.key});

  @override
  State<LoginWithPhoneNumber> createState() => _LoginWithPhoneNumberState();
}

class _LoginWithPhoneNumberState extends State<LoginWithPhoneNumber> {
  final phoneTextController = TextEditingController();
  bool loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  void phoneLogin(BuildContext context) {
    final loadingProvier = Provider.of<ProviderScene>(context, listen: false);
    loadingProvier.startLoading();
    const int timeoutInSeconds = 60;
    _auth.verifyPhoneNumber(
        phoneNumber: phoneTextController.text,
        timeout: const Duration(seconds: timeoutInSeconds),
        verificationCompleted: (_) {
          loadingProvier.stopLoading();
        },
        verificationFailed: (e) {
          loadingProvier.stopLoading();
          Utils().toastMessage(e.message.toString(), Colors.red);
        },
        codeSent: (String verificationId, int? token) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyCodeScreen(
                        verificationId: verificationId,
                      )));
          loadingProvier.stopLoading();
        },
        codeAutoRetrievalTimeout: (e) {
          loadingProvier.stopLoading();
          Utils().toastMessage(e.toString(), Colors.red);
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneTextController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10,top: 30),
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.arrow_back, color: Colors.white,)
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 180,
                ),
                const Padding(
                  padding:  EdgeInsets.only(bottom: 3),
                  child: Text("Phone Number with country Code", style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: phoneTextController,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ), 
                      hintText: "Add phone Number",
                      prefixIcon: Icon(Icons.phone,color: Colors.black)
                      ),
                      
                ),
                const SizedBox(
                  height: 60,
                ),
                RoundButton(title: "Login", ontapMethod: () => phoneLogin(context))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
