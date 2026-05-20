import 'package:flutter/material.dart';

import 'seller_dashboard.dart';
import 'profile_screen.dart';
import 'auction_list.dart';

class HomeScreen extends StatefulWidget {

  final bool isSeller;

  const HomeScreen({
    super.key,
    required this.isSeller,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int index = 0;

  @override
  Widget build(BuildContext context) {

    /// SELLER PAGES
    final sellerPages = [

      const AuctionList(),

      const SellerDashboard(),

      ProfileScreen(
        isSeller: true,
      ),
    ];

    /// NORMAL USER PAGES
    final userPages = [

      const AuctionList(),

      ProfileScreen(
        isSeller: false,
      ),
    ];

    return Scaffold(

      backgroundColor:
          const Color(0xFF020617),

      body: widget.isSeller
          ? sellerPages[index]
          : userPages[index],

      /// PREMIUM NAVBAR
      bottomNavigationBar: Container(

        margin: const EdgeInsets.all(12),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: const Color(0xFF0F172A),

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black.withOpacity(0.3),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: widget.isSeller

              ? [

                  navItem(
                    Icons.home_outlined,
                    "Auctions",
                    0,
                  ),

                  navItem(
                    Icons.bar_chart,
                    "Dashboard",
                    1,
                  ),

                  navItem(
                    Icons.person_outline,
                    "Profile",
                    2,
                  ),
                ]

              : [

                  navItem(
                    Icons.home_outlined,
                    "Auctions",
                    0,
                  ),

                  navItem(
                    Icons.person_outline,
                    "Profile",
                    1,
                  ),
                ],
        ),
      ),
    );
  }

  /// NAV ITEM
  Widget navItem(
    IconData icon,
    String label,
    int i,
  ) {

    bool active = index == i;

    return GestureDetector(

      onTap: () {

        setState(() {

          index = i;
        });
      },

      child: AnimatedContainer(

        duration:
            const Duration(milliseconds: 250),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: active
              ? const Color(0xFF3B82F6)
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Row(

          children: [

            Icon(

              icon,

              size: 22,

              color: active
                  ? Colors.white
                  : Colors.white54,
            ),

            if (active) ...[

              const SizedBox(width: 8),

              Text(

                label,

                style: const TextStyle(

                  color: Colors.white,

                  fontWeight:
                      FontWeight.w600,

                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}