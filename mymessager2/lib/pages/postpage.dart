import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mymessager2/pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'add.dart';
import 'postprofile.dart';
import 'reels.dart';
import 'search.dart';

class posthome extends StatefulWidget {
  @override
  State<posthome> createState() => _posthomeState();
}

class _posthomeState extends State<posthome> {
  List<String> imageUrls = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchImages();
    print(imageUrls); // Fetch images when the page loads
  }

  ScrollController _scrollController = ScrollController();
  Future<void> fetchImages() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('posts').get();
      for (var doc in snapshot.docs) {
        String imageUrl = doc['imageURL']; // Access the 'imageURL' field
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      print('Error fetching images: $e');
    }

    setState(() {
      isLoading = false;
    });
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<String> getDescriptionForImage(String imageUrl) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('description');
    QuerySnapshot snapshot =
        await usersCollection.where('imageURL', isEqualTo: imageUrl).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.get('description');
    } else {
      return '.....';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // GestureDetector for Swiping Gesture
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: 0, // Adjust the position as needed
              child: Container(
                height: 80, // Height of the top bar
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(0, 255, 255, 255),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                      bottom:
                          Radius.circular(20) // Border radius for top corners
                      ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of rounded images
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      width: 70, // Width of each rounded image
                      height: 70, // Height of each rounded image
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: AssetImage(
                              'images/dp/user.png'), // Replace with your image
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // ... Top bar content ...

// Inside your build method
            if (!isLoading)
              Positioned(
                top: 80,
                bottom: 70, // Adjust the position as needed
                child: Container(
                  height: MediaQuery.of(context).size.height - 80,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: imageUrls.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      final reversedIndex = imageUrls.length - 1 - index;
                      final imageUrl = imageUrls[reversedIndex];

                      return FutureBuilder(
                        future: getDescriptionForImage(imageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox.shrink();
                          }

                          final description = snapshot.data as String?;

                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                width: double.infinity,
                                height: 500,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: Text(
                                      description ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      10), // Add a space between image and icons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Handle like button press
                                    },
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Handle comment button press
                                    },
                                    icon: Icon(
                                      Icons.comment,
                                      color: const Color.fromARGB(
                                          255, 250, 249, 249),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Handle share button press
                                    },
                                    icon: Icon(
                                      Icons.share,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

// After fetching imageUrls and isLoading is set to false, scroll to the maximum extent

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
                      // Add your navigation logic for the search icon
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => posthome()));
                    }),
                    _buildBottomBarButton(Icons.search, () {
                      // Add your navigation logic for the search icon
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SearchScreen(),
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
                    _buildBottomBarButton(Icons.add, () {
                      // Add your navigation logic for the search icon
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  addreels(),
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
                    _buildBottomBarButton(Icons.video_library, () {
                      // Add your navigation logic for the search icon
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
                      // Add your navigation logic for the search icon
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Add the onTap callback for navigation
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
