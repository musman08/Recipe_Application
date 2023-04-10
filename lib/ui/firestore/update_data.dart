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

class UpdateFireStoreDataScreen extends StatefulWidget {
  const UpdateFireStoreDataScreen({super.key, required this.fRecipeName, required this.fTotalIngredients, required this.fCookingTime, required this.fCreatedBy, required this.fID, required this.fImageUrl});
  final String fRecipeName;
  final String fTotalIngredients;
  final String fCookingTime;
  final String fCreatedBy;
  final String fID;
  final String fImageUrl;
  @override
  State<UpdateFireStoreDataScreen> createState() => _UpdateFireStoreDataScreenState();
}

class _UpdateFireStoreDataScreenState extends State<UpdateFireStoreDataScreen> {
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
        String id = widget.fID;
        // DateTime.now().microsecondsSinceEpoch.toString();
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref('/foodRecipes/' + id);
        firebase_storage.UploadTask uploadTask =
            ref.putFile(provider.imageFile!.absolute);

        Future.value(uploadTask).then((value) async {
          var newimageUrl = await ref.getDownloadURL();

          try {
            firestore.doc(userId).collection('postCollections').doc(id).set({
              'id': id,
              'recipeName': recipeName.text.trim(),
              'totalIngredients': totalIngredients.text.trim(),
              'cookingTime': cookingTime.text.trim(),
              'createdBy': createdBy.text.trim(),
              'image': newimageUrl.toString(),
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
      if (_formKey.currentState!.validate()) {
        final loadingProvider =
            Provider.of<ProviderScene>(context, listen: false);
        loadingProvider.startLoading();
        String userId = auth.currentUser!.uid;
        String id = widget.fID;

          try {
            firestore.doc(userId).collection('postCollections').doc(id).set({
              'id': id,
              'recipeName': recipeName.text.trim(),
              'totalIngredients': totalIngredients.text.trim(),
              'cookingTime': cookingTime.text.trim(),
              'createdBy': createdBy.text.trim(),
              'image': widget.fImageUrl,
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

        //----------------- TRY and Catch Method--------------------------------
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    recipeName.text = widget.fRecipeName;
    totalIngredients.text = widget.fTotalIngredients;
    cookingTime.text = widget.fCookingTime;
    createdBy.text = widget.fCreatedBy;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Recipe"),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 15),
                      child: Text(
                        "Update Your post here",
                        style: TextStyle(fontSize: 18,),
                      )),
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
                                offset: Offset(0,
                                    3), // offset, i.e where the shadow will be placed
                              ),
                            ],
                          ),
                          child: Consumer<ProviderImage>(
                              builder: (context, value, child) {
                            if (value.imageFile != null) {
                              return ClipRRect(borderRadius: BorderRadius.circular(20),
                              child: Image.file(value.imageFile!.absolute,
                                  fit: BoxFit.cover,
                                  ),
                              );
                            } else {
                              return Container(
                                height: 150,
                                width: 150,
                                child: ClipRRect(borderRadius: BorderRadius.circular(16),
                                child: Image.network(widget.fImageUrl, fit: BoxFit.cover,),),
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
                            prefixIcon: Icon(Icons.fastfood, color: Colors.black,),
                            hintText: "Recipe Name",
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
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        controller: createdBy,
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
                              return 'Only 1-60 minutes';
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
                            return "Its Mandatory";
                          }
                          else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            RoundButton(
                title: "Update",
                // loading: loading,
                ontapMethod: () => addPost(context))
          ],
        ),
      ),
    );
  }
}
