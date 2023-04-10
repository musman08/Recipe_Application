import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:Chef/Provider/providerScenes.dart';
import 'package:Chef/ui/auth/login_screen.dart';
import 'package:Chef/utils/utils.dart';
import 'package:provider/provider.dart';
import '../widgets/round_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String errorMessage;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signUp(BuildContext context) async {
    final loadingProvider = Provider.of<ProviderScene>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      loadingProvider.startLoading();
      try {
        await _auth
            .createUserWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        )
            .then((value) {
          Utils().toastMessage("Resgistered Successfully", Colors.grey[600]!);
          loadingProvider.stopLoading();
        });
      } on FirebaseAuthException catch (error, stackTrace) {
        errorMessage = error.message!;
        Utils().toastMessage(errorMessage, Colors.grey[600]!);
        loadingProvider.startLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 35,),
          Padding(
            padding: const EdgeInsets.only(left: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text("Login Screen"),
                Container(
                        height: 120,
                        width: double.infinity,
                        // color: Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Food Recipes",style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                          Text("Welcome here! Best Food Recipes",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          
                        ],
                      ),),
                      const SizedBox(height: 30,),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
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
                          cursorColor: Colors.black,
                          controller: passwordController,
                          obscureText: true,
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
                              prefixIcon: Icon(Icons.lock,color: Colors.black)),
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
                  title: "Sign Up",
                  ontapMethod: () => signUp(context),
                ),
                const SizedBox(
                  height: 30,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text("Login"))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
