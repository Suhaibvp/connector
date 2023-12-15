import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class TelegramPage extends StatefulWidget {
  final String email;
  final String selectedUser;

  TelegramPage({required this.email, required this.selectedUser});

  @override
  _TelegramPageState createState() => _TelegramPageState();
}

class _TelegramPageState extends State<TelegramPage> {
  final TextEditingController _LinkController = TextEditingController();

  void _handleAddButtonPress() async {
    String Link = _LinkController.text;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('telegram');
    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: widget.email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();
    if (snapshot.docs.isNotEmpty) {
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.update({'link': Link});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatFormPage(
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('telegram').add({
        'senter': widget.email,
        'receiver': widget.selectedUser,
        'link': Link
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatFormPage(
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('telegram Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _LinkController,
              decoration: InputDecoration(
                labelText: 'Profilelink',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleAddButtonPress,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
