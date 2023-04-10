import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/providerScenes.dart';
import '../../utils/utils.dart';
import '../firestore/firestore_list_screen.dart';
import '../widgets/round_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  const VerifyCodeScreen({super.key, required this.verificationId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final verifyCodeController = TextEditingController();
  bool loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;

  void verifyCode(BuildContext context) async {
    final loadingProvider = Provider.of<ProviderScene>(context, listen: false);
    loadingProvider.startLoading();

    final credentials = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: verifyCodeController.text);
    try {
      await _auth.signInWithCredential(credentials);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ListScreen()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message!;
      loadingProvider.stopLoading();
      Utils().toastMessage("errorMessage", Colors.red);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    verifyCodeController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 10),
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
                child: const Icon(Icons.arrow_back, color: Colors.white,)
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 130,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: verifyCodeController,
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
                      hintText: "6 Digits code",
                      ),
                ),
                const SizedBox(
                  height: 60,
                ),
                RoundButton(
                  title: "Verify",
                  // loading: loading,
                  ontapMethod: () => verifyCode(context),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
