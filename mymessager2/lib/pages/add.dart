import 'dart:io';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'VideoPlayerWidget.dart';
import 'home_page.dart';
import 'postpage.dart';
import 'postprofile.dart';
import 'reels.dart';
import 'search.dart';

class addreels extends StatefulWidget {
  @override
  _addreelsState createState() => _addreelsState();
}

class _addreelsState extends State<addreels> {
  bool isIconClicked = true;
  String? selectedImagePath;

  void _handleIconClick() {
    setState(() {
      isIconClicked = true;
    });
  }

  String uid = FirebaseAuth.instance.currentUser?.email ?? '';
  // Import video_player package

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print(file.path);
      setState(() {
        selectedImagePath = file.path;
      });
    } else {
      // User canceled the picker
    }
  }
  // final picker = ImagePicker();
  // final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  // if (pickedImage != null) {
  //   setState(() {
  //     selectedImagePath = pickedImage;
  //   });
  // }

  TextEditingController descriptionController = TextEditingController();

  Future<void> _submitPost(String description) async {
    if (selectedImagePath == null) {
      // Handle case where image is not selected
      return;
    }

    // Get the current user's UID

    // Generate a unique name for the file using a timestamp
    String fileName = '${DateTime.now().millisecondsSinceEpoch}';
    String storagePath;

    if (selectedImagePath!.endsWith('.mp4')) {
      // If it's a video, store it in the 'postvideos' folder
      storagePath = 'postvideos/$fileName.mp4';
    } else {
      // If it's an image, store it in the 'postimages' folder
      storagePath = 'postimages/$fileName.jpg';
    }

    // Reference to the Firebase Storage location
    Reference storageReference =
        FirebaseStorage.instance.ref().child(storagePath);

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(File(selectedImagePath!));
    TaskSnapshot storageSnapshot = await uploadTask;

    // Get the URL of the uploaded file
    String fileURL = await storageSnapshot.ref.getDownloadURL();

    // Save the input field content to Firestore in a 'description' collection
    await FirebaseFirestore.instance.collection('description').add({
      'fileURL': fileURL,
      'description': description, // Replace with your input text
    });

    // Save the file URL and other details to the 'posts' collection
    await FirebaseFirestore.instance.collection('posts').add({
      'email': uid,
      'fileURL': fileURL,
      'timestamp': FieldValue.serverTimestamp(),
      'type': selectedImagePath!.endsWith('.mp4') ? 'video' : 'image',
    });

    // Save the initial count to Firestore
    await FirebaseFirestore.instance.collection('counters').add({
      'count': 0,
      'fileURL': fileURL,
      'usersliked': '',
    });

    // Reset the state
    setState(() {
      selectedImagePath = null;
      // descriptionText = ''; // Clear the input text
      isIconClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to black
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check swipe direction
              if (details.velocity.pixelsPerSecond.dx > 0) {
                // Swiped right
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Homepage()));
              }
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                  bottom: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomBarButton(Icons.home, () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            posthome(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutQuart;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  }),
                  _buildBottomBarButton(Icons.search, () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SearchScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutQuart;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  }),
                  _buildBottomBarButton(Icons.add, () {
                    // Handle the icon click here
                    // _handleIconClick();
                  }),
                  _buildBottomBarButton(Icons.video_library, () {
                    // Add your navigation logic for the search icon
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            reels(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutQuart;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  }),
                  _buildBottomBarButton(Icons.person, () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            profilereels(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutQuart;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (isIconClicked)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2, // Adjust as needed
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    selectedImagePath != null
                        ? selectedImagePath!.endsWith('.mp4')
                            ? VideoPlayerWidget(
                                videoPath:
                                    selectedImagePath!) // Custom video player widget
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(selectedImagePath!),
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              )
                        : Container(
                            alignment: Alignment.center,
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 5,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _pickImage();
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent,
                                  elevation: 0,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Color.fromARGB(113, 0, 0, 0),
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    if (selectedImagePath != null)
                      Column(
                        children: [
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Description.',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                  maxLines: null,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _submitPost(descriptionController.text);
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      ),

                    // if (selectedImagePath != null)
                    //   ElevatedButton(
                    //     onPressed: () {},
                    //     child: Text('Submit'),
                    //   ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}
