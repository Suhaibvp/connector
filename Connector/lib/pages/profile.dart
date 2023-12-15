import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<String?> getProfileImageUrl(String username) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('profile_images/$username.jpg');
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: getUserDataFromEmail(widget.userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text('Error fetching user data'),
          );
        } else {
          String? username = snapshot.data!['username'];
          String? fullName = snapshot.data!['full_name'];
          return FutureBuilder<String?>(
            future: getProfileImageUrl(username!),
            builder: (context, profileSnapshot) {
              String profileImageUrl = profileSnapshot.data ??
                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'; // Replace with default image URL

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        fullName ?? 'Full Name not available',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        username ?? 'Username not available',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userEmail,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const Spacer(), // Add space to push content to the top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Implement your edit profile logic here
                            },
                            child: const Text('Edit Profile'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Implement your logout logic here
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

Future<Map<String, String>?> getUserDataFromEmail(String email) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  QuerySnapshot snapshot =
      await usersCollection.where('email', isEqualTo: email).get();

  if (snapshot.docs.isNotEmpty) {
    var userData = snapshot.docs.first.data() as Map<String, dynamic>;
    return {
      'username': userData['username'],
      'full_name': userData['full_name'],
    };
  } else {
    return null;
  }
}
