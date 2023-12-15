import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Signup extends StatefulWidget {
  final void Function()? onPressed;
  const Signup({super.key, required this.onPressed});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  bool isloading = false;
  XFile? _pickedImage;

  createUserWithEmailAndPassword() async {
    if (await doesUsernameExist(_userName.text)) {
      setState(() {
        isloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Username already exists. Please choose a different one."),
        ),
      );
      return;
    }
    try {
      setState(() {
        isloading = true;
      });

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'full_name': _fullName.text,
        'username': _userName.text,
        'email': _email.text,
      });
      await uploadProfileImage(_userName.text);
      setState(() {
        isloading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });
      if (e.code == 'weak-password') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The password provided is too weak."),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The account already exists for that email."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });

      print(e);
    }
  }

  Future<bool> doesUsernameExist(String username) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> uploadProfileImage(String username) async {
    if (_pickedImage == null) {
      // No image selected, handle this case if needed
      return;
    }

    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$username.jpg');

      final UploadTask uploadTask = storageRef.putFile(
        File(_pickedImage!.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask.whenComplete(() async {
        final downloadUrl = await storageRef.getDownloadURL();
        print('File uploaded. Download URL: $downloadUrl');
      });
    } catch (e) {
      // Handle any errors that occur during the upload
      print('Error uploading file: $e');
    }
  }

  Future<String?> getProfileImageUrl(String username) async {
    CollectionReference profileImagesCollection =
        FirebaseFirestore.instance.collection('profile_images');

    DocumentSnapshot snapshot =
        await profileImagesCollection.doc(username).get();

    if (snapshot.exists) {
      return snapshot.get('image_url');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Signup"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: OverflowBar(
                  overflowSpacing: 20,
                  children: [
                    TextFormField(
                      controller: _email,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Email is empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextFormField(
                      controller: _password,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Email is empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                    TextFormField(
                      controller: _fullName,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Full Name is empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    TextFormField(
                      controller: _userName,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Username is empty';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage, // Call the image picker
                      child: const Text('Pick Profile Picture'),
                    ),
                    if (_pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            100), // Make it fully circular
                        child: Image.file(
                          File(_pickedImage!.path),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createUserWithEmailAndPassword();
                          }
                        },
                        child: isloading
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                            : const Text("Signup"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: widget.onPressed,
                        child: const Text("login"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
