import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/Provider/providerScenes.dart';
import 'package:Chef/ui/widgets/round_button.dart';
import 'package:Chef/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddFireStoreDataScreen extends StatefulWidget {
  const AddFireStoreDataScreen({super.key});

  @override
  State<AddFireStoreDataScreen> createState() => _AddFireStoreDataScreenState();
}

class _AddFireStoreDataScreenState extends State<AddFireStoreDataScreen> {
  final recipeName = TextEditingController();
  final createdBy = TextEditingController();
  final cookingTime = TextEditingController();
  final totalIngredients = TextEditingController();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance.collection('user');
  // final postCollection = FirebaseFirestore.instance.collection('postCollection');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  File? choosedImage;
  final picker = ImagePicker();

  Future addImages(BuildContext context) async {
    final provider = Provider.of<ProviderImage>(context, listen: false);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      choosedImage = File(pickedFile.path);
      provider.ChangeImage(choosedImage!);
    } else {
      Utils().toastMessage("Image is not selected", Colors.red);
    }
  }

  void addPost(BuildContext context) async {
    final provider = Provider.of<ProviderImage>(context, listen: false);
    if (provider.imageFile != null) {
      if (_formKey.currentState!.validate()) {
        final loadingProvider =
            Provider.of<ProviderScene>(context, listen: false);
        loadingProvider.startLoading();
        String userId = auth.currentUser!.uid;
        String id = DateTime.now().microsecondsSinceEpoch.toString();
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref('/foodRecipes/' + id);
        firebase_storage.UploadTask uploadTask =
            ref.putFile(provider.imageFile!.absolute);

        Future.value(uploadTask).then((value) async {
          var imageUrl = await ref.getDownloadURL();

          try {
            firestore.doc(userId).collection('postCollections').doc(id).set({
              'id': id,
              'recipeName': recipeName.text.trim(),
              'totalIngredients': totalIngredients.text.trim(),
              'cookingTime': cookingTime.text.trim(),
              'createdBy': createdBy.text.trim(),
              'image': imageUrl.toString(),
            }).then((value) {
              Utils().toastMessage("Post Uploaded", Colors.grey);
              loadingProvider.stopLoading();
              provider.removeImage();
              recipeName.text = '';
              totalIngredients.text = '';
              cookingTime.text = '';
              createdBy.text = '';
              Navigator.pop(context);
            });
          } catch (e) {
            Utils().toastMessage(e.toString(), Colors.red);
            loadingProvider.stopLoading();
          }
        }).onError((error, stackTrace) {
          Utils().toastMessage(error.toString(), Colors.red);
        });

        //----------------- TRY and Catch Method--------------------------------
      }
    } else {
      Utils().toastMessage("Select the Image", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Your Post"),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(padding: EdgeInsets.only(top: 30, left: 10),
          // child: InkWell(
          //   onTap: (){
          //     Navigator.pop(context);
          //   },
          //   child: Container(
          //     height: 30,
          //     width: 30,
          //     decoration: const BoxDecoration(
          //       color: Colors.black,
          //       shape: BoxShape.circle
          //     ),
          //     child: const Icon(Icons.arrow_back, color: Colors.white,),
          //   ),
          // ),),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40,),
                  Center(
                    child: InkWell(
                      onTap: () {
                        addImages(context);
                      },
                      child: Container(
                          height: 150,
                          width: 180,
                          // width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // shadow color
                                spreadRadius: 5, // how much spread you want
                                blurRadius: 7, // blur radius
                                offset: const Offset(0,3), // offset, i.e where the shadow will be placed
                              ),
                            ],
                          ),
                          child: Consumer<ProviderImage>(
                              builder: (context, value, child) {
                            if (value.imageFile != null) {
                              return ClipRRect(borderRadius: BorderRadius.circular(16),
                              child: Image.file(value.imageFile!.absolute,
                                  fit: BoxFit.cover,
                                  ),
                              );
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  Text("Choose Image"),
                                  Icon(
                                Icons.image,
                                size: 90,
                                color: Colors.black,
                              )
                                ],
                              );
                            }
                          })),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      TextFormField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        controller: recipeName,
                        decoration: const InputDecoration(
                            hintText: "Recipe Name",
                            prefixIcon: Icon(Icons.fastfood, color: Colors.black,),
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                            ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Give it a name please";
                          } else if (value.length < 5) {
                            return "Atleast 5 characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: createdBy,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.black,),
                            hintText: "Created By",
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                            ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Created by";
                          } else if (value.length < 4 && value.length > 20) {
                            return "4-20 characters range ";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        controller: cookingTime,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.timer, color: Colors.black,),
                            hintText: "Cooking Time in minutes (1-60)",
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),

                            ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Put a time here";
                          } else if (int.tryParse(value) == null) {
                            if (int.parse(value) > 0 && int.parse(value) < 61) {
                              return 'In (1-60 digits) Mins.';
                            } else {
                              return '';
                            }
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        
                        keyboardType: TextInputType.number,
                        controller: totalIngredients,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.dining, color: Colors.black,),
                            hintText: "No. of Ingredients",
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                            ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "At Least 2 items";
                          }
                          else if (int.tryParse(value) == null) {
                            if (int.parse(value) > 1 && int.parse(value) < 21) {
                              return 'Only 2-20 in digits';
                            } else {
                              return '';
                            }
                          }
                          else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20,),
                      RoundButton(
                title: "Add",
                // loading: loading,
                ontapMethod: () => addPost(context)),
                    ],
                    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
