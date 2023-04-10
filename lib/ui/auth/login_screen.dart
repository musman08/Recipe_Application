import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:Chef/ui/auth/login_phone.dart';
import 'package:Chef/ui/auth/signup_screen.dart';
import 'package:Chef/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../Provider/providerScenes.dart';
import '../firestore/firestore_list_screen.dart';
import '../widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String errorMessage;
  bool loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void login(BuildContext context) async {
    final loadingProvider = Provider.of<ProviderScene>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      loadingProvider.startLoading();
      try {
        await _auth
            .signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        )
            .then((value) {
          Utils().toastMessage(value.user!.email.toString(), Colors.grey[600]!);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ListScreen()),
            (Route<dynamic> route) => false,
          );
          loadingProvider.stopLoading();
        });
      } on FirebaseAuthException catch (error, stackTrace) {
        errorMessage = error.message!;
        Utils().toastMessage(errorMessage, Colors.grey[600]!);
        loadingProvider.stopLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await Future.delayed(const Duration(milliseconds: 500));
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Login"),
        //   centerTitle: true,
        //   automaticallyImplyLeading: false,
        // ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("Login Screen"),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        // color: Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Food Recipes",style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                          Text("Find Best Recipes Here!",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          
                        ],
                      ),),
                      const SizedBox(height: 20,),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
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
                            hintText: "Email",
                            // fillColor: Colors.amber,
                            prefixIcon: Icon(Icons.email, color: Colors.black)),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email";
                          } else if (!EmailValidator.validate(value)) {
                            return 'Enter a valid email';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
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
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.black,)),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  )),

              const SizedBox(
                height: 50,
              ),
              RoundButton(
                title: "Login",
                ontapMethod: () => login(context),
              ),

              const SizedBox(
                height: 30,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                      child: const Text("Sign Up"))
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginWithPhoneNumber()));
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: Colors.black)
                      ),
                  child: const Center(child: Text("Using Phone Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
