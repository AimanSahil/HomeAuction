import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auction_list.dart';
import 'profile_screen.dart';
import 'seller_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 0;

  bool isSeller = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {

      setState(() {

        isSeller = doc['role'] == 'seller';
        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /// SELLER SCREENS
    final sellerScreens = [

      const AuctionList(),

      const SellerDashboard(),

      ProfileScreen(
        isSeller: true,
        onOpenDashboard: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),
    ];

    /// NORMAL USER SCREENS
    final userScreens = [

      const AuctionList(),

      ProfileScreen(
        isSeller: false,
      ),
    ];

    final screens =
        isSeller ? sellerScreens : userScreens;

    return Scaffold(

      backgroundColor: const Color(0xFF020617),

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: Container(

        height: 82,

        decoration: const BoxDecoration(

          color: Color(0xFF121A3A),

          border: Border(
            top: BorderSide(
              color: Colors.white10,
            ),
          ),
        ),

        child: BottomNavigationBar(

          currentIndex: currentIndex,

          onTap: (index) {

            setState(() {
              currentIndex = index;
            });
          },

          backgroundColor:
              const Color(0xFF121A3A),

          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor:
              const Color(0xFF6C97FF),

          unselectedItemColor:
              Colors.white54,

          selectedLabelStyle:
              const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontSize: 12,
          ),

          items: isSeller
              ? const [

                  /// AUCTIONS
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Auctions",
                  ),

                  /// DASHBOARD
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: "Dashboard",
                  ),

                  /// PROFILE
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ]
              : const [

                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Auctions",
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
        ),
      ),
    );
  }
}