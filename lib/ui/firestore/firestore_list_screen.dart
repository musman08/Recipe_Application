import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Chef/ui/firestore/firestore_profile.dart';
import 'package:Chef/ui/firestore/widgets2.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String errorMessage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   title: const Text("Home Page"),
        //   // actions: [
        //   //   IconButton(onPressed: () {

        //   //   },
        //   //   icon: const Icon(Icons.person))
        //   // ],
        // ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
              // color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Home Page", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()));
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle
                            ),
                          child: const Icon(Icons.person, color: Colors.white,)
                                        ),
                      )
                  ],
                ),
              ),),
              SizedBox(height: 20,),
              SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Find Best Recipes',
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                      suffixIcon: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black,))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: Text(
                        "All Recipes", style: TextStyle(color: Colors.black),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                          // color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber)),
                      child: const Center(
                          child: Text(
                        "Italian",
                      )),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('postCollections')
                    .snapshots(),
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
                  return Expanded(
                    child: GridView.builder(
                      itemCount: posts.length,
                      // physics: const NeverScrollableScrollPhysics(),
                      // shrinkWrap: true,
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
                              ontap: 'Bookmark',
                              imageUrl: posts[index]['image'],
                              id: posts[index]['id'],
                            )
                            );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => const ProfileScreen()));
        //   },
        //   child: Icon(Icons.person),
        // ),
      ),
    );
  }
}
