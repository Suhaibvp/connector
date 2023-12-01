import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class WhatsAppPage extends StatefulWidget {
  final String email;
  final String selectedUser;

  WhatsAppPage({required this.email, required this.selectedUser});

  @override
  _WhatsAppPageState createState() => _WhatsAppPageState();
}

class _WhatsAppPageState extends State<WhatsAppPage> {
  final TextEditingController _mobileNumberController = TextEditingController();

  void _handleAddButtonPress() async {
    String mobileNumber = _mobileNumberController.text;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('whatsapp');
    QuerySnapshot snapshot = await usersCollection
        .where('senter', isEqualTo: widget.email)
        .where('receiver', isEqualTo: widget.selectedUser)
        .get();
    if (snapshot.docs.isNotEmpty) {
      // String mobileNumber = snapshot.docs.first.get('number');
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.update({'number': mobileNumber});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatFormPage(
            selectedUser: widget.selectedUser,
          ),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('whatsapp').add({
        'senter': widget.email,
        'receiver': widget.selectedUser,
        'number': mobileNumber // Replace with your input text
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
        title: Text('WhatsApp Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
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
