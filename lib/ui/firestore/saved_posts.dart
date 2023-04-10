import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Chef/ui/firestore/widgets2.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final _auth = FirebaseAuth.instance;
  late String errorMessage;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;
    final bookmarkCollection = FirebaseFirestore.instance.collection('user').doc(userId).collection('Bookmarks');
    final postCollection = FirebaseFirestore.instance.collectionGroup('postCollections');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
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
                stream: bookmarkCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final bookmarks = snapshot.data!.docs;
                  return StreamBuilder<QuerySnapshot>(
                    stream: postCollection.snapshots(),
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
                      final bookmarkIds = bookmarks.map((doc) => doc.id).toList();
                      final filteredPosts = posts.where((doc) => bookmarkIds.contains(doc.id)).toList();
                      return GridView.builder(
                        itemCount: filteredPosts.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 210,
                        ),
                        itemBuilder: (context, index) {
                          return RecipeContainer(
                              recipename: filteredPosts[index]['recipeName'],
                              cookingtime: filteredPosts[index]['cookingTime'],
                              createdby: filteredPosts[index]['createdBy'],
                              totalingredients: filteredPosts[index]['totalIngredients'],
                              imageUrl: filteredPosts[index]['image'],
                              ontap: '',
                              id: filteredPosts[index]['id'],
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
