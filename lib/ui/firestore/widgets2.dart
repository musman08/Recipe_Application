import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/ui/firestore/update_data.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../utils/utils.dart';

class RecipeContainer extends StatelessWidget {
  RecipeContainer(
      {Key? key,
      required this.recipename,
      required this.cookingtime,
      required this.createdby,
      required this.totalingredients,
      required this.ontap,
      required this.imageUrl,
      required this.id})
      : super(key: key);

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance.collection('user');
  final String recipename;
  final String cookingtime;
  final String createdby;
  final String totalingredients;
  final String ontap;
  final String imageUrl;
  final String id;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    height: 145,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text("Failed to load!", style: TextStyle(color: Colors.redAccent),));
                    },
                  ),
                ),
                Positioned(
                    bottom: 8,
                    left: 5,
                    child: Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.star_half,
                            size: 15,
                            color: Colors.white,
                          ),
                          Text("4.5", style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    )),
                Positioned(
                    top: 5,
                    right: 5,
                    child: 
                    InkWell(
                      onTap: () {
                        if (ontap == 'Bookmark') {
                          showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(0, 0, 50, 0),
                          items: <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'save',
                              child: Text("Save")
                            ),
                            
                          ],
                          
                        ).then((value) {
                          if(value == 'save'){
                            save();
                          }
                        });
                        }
                        else if (ontap == 'update'){
                          showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(0, 0, 50, 0),
                          items: <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'update',
                              child: Text("Update")
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text("Delete")
                            ),
                            
                          ],
                          
                        ).then((value) {
                          if(value == 'update'){
                            Navigator.push(context, MaterialPageRoute(
                            builder: (context)=> UpdateFireStoreDataScreen(
                              fRecipeName: recipename, 
                              fTotalIngredients: totalingredients, 
                              fCookingTime: cookingtime, 
                              fCreatedBy: createdby, 
                              fID: id, 
                              fImageUrl: imageUrl) ));
                          }
                          if(value == 'delete'){
                            // Utils().toastMessage("Delete will be implement soon", Colors.red);
                            delete();
                          }
                        });
                          
                          // Utils().toastMessage("updated", Colors.red);
                          
                        } else {
                          Utils().toastMessage("message", Colors.red);
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        width: 30,
                        height: 30,
                        child: const Icon(Icons.menu_rounded, color: Colors.black,),
                      ),
                    ))
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
                left: 5,
              ),
              child: Text(
                recipename,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    createdby,
                    // style: TextStyle(color: Colors.amberAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Text(
                          '$cookingtime min',
                          style: const TextStyle(color: Colors.amber),
                          overflow: TextOverflow.ellipsis,
                        )))),

                // Icon(Icons.info_outline_rounded, size: 20,)
              ],
            ),
          )
        ],
      ),
    );
  }

  void save() async {
    try {
      String userId = auth.currentUser!.uid;
      // String id = DateTime.now().microsecondsSinceEpoch.toString();
      firestore.doc(userId).collection('Bookmarks').doc(id).set({
        'id': id,
      }).then((value) {
        Utils().toastMessage("Post Saved", Colors.grey);
      });
    } catch (error) {
      Utils().toastMessage(error.toString(), Colors.red);
    }
  }
  void delete() async{
    try {
      String userId = auth.currentUser!.uid;
      firestore.doc(userId).collection('postCollections').doc(id).delete().then((value) async{
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/foodRecipes/' + id);
        await ref.delete();
        Utils().toastMessage("Post Deleted", Colors.grey);
      });
    } catch (error) {
      Utils().toastMessage(error.toString(), Colors.red);
    }
  }
}
