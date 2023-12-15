import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:vibration/vibration.dart';
import 'chat.dart';
// import 'customization.dart';
// import 'myai.dart';
import 'postpage.dart';
import 'profile.dart';

final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late PageController _pageController; // Add this line
  int _currentPageIndex = 0; // Add this line
  void onProfileIconPressed() async {
    String currentUserEmail = await getCurrentUserEmail();
    // Implement your logic here when the profile icon is pressed
    // checkForNewNotifications(); // Call this function here
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userEmail: currentUserEmail),
      ),
    );
  }

  void myai() async {
    String currentUserEmail = await getCurrentUserEmail();
  }

  Future<String> getCurrentUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      return user.email!;
    }
    throw Exception("User is not authenticated");
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool hasNewNotifications = false;
  bool shouldShake = false;
  Set<String> usersWithNewNotifications = {};

  @override
  void initState() {
    super.initState();
    checkForNewNotifications();

    // Start the timer to control shaking
    Timer(const Duration(seconds: 1), () {
      setState(() {
        shouldShake = false;
      });
    });
    _pageController =
        PageController(initialPage: _currentPageIndex); // Add this line
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  Future<void> checkForNewNotifications() async {
    String currentUserEmail = _auth.currentUser!.email!;
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('notification');

    QuerySnapshot notificationSnapshot = await notifications
        .where('receiver', isEqualTo: currentUserEmail)
        .get();

    if (notificationSnapshot.docs.isNotEmpty) {
      setState(() {
        hasNewNotifications = true;
        shouldShake = true;

        // Store the usernames of users with new notifications
        usersWithNewNotifications = notificationSnapshot.docs
            .map((doc) => doc['senter'].toString())
            .toSet();
      });
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> deleteNotification(
      String currentUserEmail, String senderUsername) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('notification');

    QuerySnapshot notificationSnapshot = await notifications
        .where('receiver', isEqualTo: currentUserEmail)
        .where('senter', isEqualTo: senderUsername)
        .get();

    for (QueryDocumentSnapshot doc in notificationSnapshot.docs) {
      String notificationMessage = doc['message'];

      // Delete the notification document
      await doc.reference.delete();

      // Navigate to the chat page with the message
    }
  }

  Future<String?> getProfileImageUrl(String username) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('profile_images/$username.jpg');
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      // print('Error getting profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {},
          child: const Icon(Icons.settings), // Customization icon
        ),
        centerTitle: true,
        title: const Text(""),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: const Icon(Icons.logout), // Sign out icon
          ),
          GestureDetector(
            onTap: onProfileIconPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding
              child: Icon(Icons.person), // Profile icon
            ),
          ),
          GestureDetector(
            onTap: myai,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding
              child: Icon(Icons.work), // Profile icon
            ),
          ),
        ],
      ),
      floatingActionButton: ShakeWidget(
        duration: const Duration(milliseconds: 500),
        shakeConstant: ShakeHardConstant1(),
        autoPlay: shouldShake,
        enableWebMouseHover: true,
        child: FloatingActionButton(
          onPressed: () {
            Vibration.vibrate(duration: 500);
            // Handle the bell icon click here
            if (hasNewNotifications) {
              // Perform action related to notifications
            }
          },
          backgroundColor: hasNewNotifications
              ? const Color.fromARGB(255, 54, 152, 244)
              : null,
          child: const Icon(Icons.notifications),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Check swipe direction
          if (details.velocity.pixelsPerSecond.dx < 0) {
            // Swiped right
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => posthome()));
          }
        },
        child: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data != null) {
              final user = snapshot.data!;
              String currentUserEmail = user.email ?? '';

              return FutureBuilder<String?>(
                future: getUsernameFromEmail(currentUserEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String? currentUsername = snapshot.data;
                    return Column(
                      children: [
                        const Center(
                          child: Text(''),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isNotEqualTo: currentUserEmail)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              List<QueryDocumentSnapshot> users =
                                  snapshot.data!.docs.toList();

                              return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      3, //adjust this to adjust the number of persons in 1 line
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  String fullName =
                                      users[index].get('full_name') ?? '';
                                  String userName =
                                      users[index].get('username') ?? '';

                                  bool hasNew = usersWithNewNotifications
                                      .contains(userName);

                                  return Card(
                                    // Wrap the user's content in a Card
                                    elevation:
                                        4, // Add elevation to create the floating effect
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // Customize border radius as needed
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          usersWithNewNotifications
                                              .remove(userName);
                                        });
                                        deleteNotification(
                                            currentUserEmail, userName);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatFormPage(
                                              selectedUser: userName,
                                              currentUsername: currentUsername,
                                              currentUserEmail:
                                                  currentUserEmail,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FutureBuilder<String?>(
                                            future: getProfileImageUrl(
                                                userName), // Fetch only when username is available
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError ||
                                                  snapshot.data == null) {
                                                return const CircleAvatar(
                                                  radius: 35,
                                                  backgroundImage: AssetImage(
                                                      'images/dp/user.png'),
                                                );
                                              } else {
                                                String imageUrl =
                                                    snapshot.data!;
                                                return CircleAvatar(
                                                  radius: 35,
                                                  backgroundImage:
                                                      NetworkImage(imageUrl),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            fullName,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          if (hasNew)
                                            const Icon(
                                              Icons.circle,
                                              color: Color.fromARGB(
                                                  255, 17, 17, 17),
                                              size: 10,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            } else {
              return const Center(child: Text('Not signed in'));
            }
          },
        ),
      ),
    );
  }
}

Future<String?> getUsernameFromEmail(String email) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  QuerySnapshot snapshot =
      await usersCollection.where('email', isEqualTo: email).get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.get('username');
  } else {
    return null;
  }
}
