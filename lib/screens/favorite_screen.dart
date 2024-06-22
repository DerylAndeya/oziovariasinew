import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favorite posts'));
          }

          List<Widget> favoriteWidgets = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: data['imageUrl'].isNotEmpty
                  ? Image.network(data['imageUrl'])
                  : null,
              title: Text(data['username']),
              subtitle: Text(data['text']),
            );
          }).toList();

          return ListView(
            children: favoriteWidgets,
          );
        },
      ),
    );
  }
}
