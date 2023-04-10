import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/ui/auth/login_screen.dart';
import 'package:Chef/ui/firestore/firestore_add_data.dart';
import 'package:Chef/ui/firestore/saved_posts.dart';
import 'package:Chef/ui/firestore/widgets2.dart';
import '../../utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  late String errorMessage;

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    final firestoreSnapshot = FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('postCollections')
        .snapshots();
    // final forUpdateData = FirebaseFirestore.instance.collection('user').doc(userId).collection('postCollections');
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text("Profile Page"),
        actions: [
          PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
             PopupMenuItem<String>(
              value: 'save',
              child: Row(
                children: const [
                  Icon(Icons.save),
                  Text('Saved Posts')
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'LogOut',
              child: Row(
                children: const [
                  Icon(Icons.logout_outlined),
                  Text('LogOut')
                ],
              ),
            ),
          ],
          onSelected: (String value) async {
            if (value == 'save') {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const SavedPostsScreen()));
            }
            if(value=='LogOut'){
              try {
                  await _auth.signOut().then((value) {
                    Utils().toastMessage(
                        "Successfully Loging Out", Colors.grey[400]!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  });
                } on FirebaseAuthException catch (error, stackTrace) {
                  errorMessage = error.message!;
                  Utils().toastMessage(errorMessage, Colors.grey[400]!);
                }
            }
          },
          child: InkWell(
            child: Container(
              width: 50,
              height: 50,
              child: const Icon(Icons.menu),
            ),
          ),
        )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: firestoreSnapshot,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final posts = snapshot.data!.docs;
                  return GridView.builder(
                    itemCount: posts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 210),
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            // Do something when a post is tapped
                          },
                          child: RecipeContainer(
                              recipename: posts[index]['recipeName'],
                              cookingtime: posts[index]['cookingTime'],
                              createdby: posts[index]['createdBy'],
                              totalingredients: posts[index]['totalIngredients'],
                              imageUrl: posts[index]['image'],
                              ontap: 'update',
                              id: posts[index]['id'],
                              )
                          
                          );
                    },
                  );
                  
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => 
                  const AddFireStoreDataScreen()
                  // AddData()
                  ));
        },
        child: const Icon(
          Icons.post_add,
          color: Colors.white,
        ),
      ),
    );
  }
}
