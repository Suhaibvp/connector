import 'package:flutter/material.dart';

import 'add.dart';
import 'home_page.dart';
import 'postpage.dart';
import 'reels.dart';
import 'search.dart';

class profilereels extends StatefulWidget {
  const profilereels({super.key});

  @override
  State<profilereels> createState() => _profilereelsState();
}

class _profilereelsState extends State<profilereels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
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
              // Height of the bottom bar
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(10) // Border radius for top corners
                    ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomBarButton(Icons.home, () {
                    // Add your navigation logic for the search icon
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
                            const SearchScreen(),
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
                    // Add your navigation logic for the search icon
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            addreels(),
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
                  _buildBottomBarButton(Icons.video_library, () {
                    // Add your navigation logic for the search icon
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            reels(),
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
                  _buildBottomBarButton(Icons.person, () {
                    // Add your navigation logic for the search icon
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => SearchScreen()));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
