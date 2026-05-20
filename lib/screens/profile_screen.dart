import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {

  final bool isSeller;

  final VoidCallback? onOpenDashboard;

  const ProfileScreen({
    super.key,
    required this.isSeller,
    this.onOpenDashboard,
  });

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {

      return const Scaffold(

        body: Center(
          child: Text("Not logged in"),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(0xFF020617),

      body: SafeArea(

        child: FutureBuilder<DocumentSnapshot>(

          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),

          builder: (context, snapshot) {

            if (!snapshot.hasData) {

              return const Center(

                child:
                    CircularProgressIndicator(),
              );
            }

            final data =
                snapshot.data!.data()
                    as Map<String, dynamic>?;

            String name =
                data?['name'] ?? "User";

            String email =
                data?['email'] ??
                    user.email ??
                    "";

            return SingleChildScrollView(

              padding:
                  const EdgeInsets.all(18),

              child: Column(

                children: [

                  /// PROFILE CARD
                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(24),

                    decoration: BoxDecoration(

                      color:
                          const Color(0xFF0F172A),

                      borderRadius:
                          BorderRadius.circular(28),
                    ),

                    child: Column(

                      children: [

                        CircleAvatar(

                          radius: 52,

                          backgroundColor:
                              const Color(
                                  0xFF5B8DEF),

                          child: Text(

                            name.isNotEmpty
                                ? name[0]
                                    .toUpperCase()
                                : "U",

                            style:
                                const TextStyle(

                              fontSize: 42,

                              fontWeight:
                                  FontWeight.bold,

                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(

                          name,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(

                            color: Colors.white,

                            fontSize: 26,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(

                          email,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(

                            color: Colors.grey,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(

                            color:
                                const Color(
                                    0xFF172554),

                            borderRadius:
                                BorderRadius.circular(
                                    30),
                          ),

                          child: Row(

                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              Icon(

                                isSeller
                                    ? Icons.home
                                    : Icons.trending_up,

                                color:
                                    const Color(
                                        0xFF6C97FF),

                                size: 18,
                              ),

                              const SizedBox(width: 8),

                              Text(

                                isSeller
                                    ? "Seller"
                                    : "Bidder",

                                style:
                                    const TextStyle(

                                  color: Colors.white,

                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// STATS
                  if (!isSeller) ...[
                  Row(

                    children: [

                      _statBox(
                        "0",
                        "Active",
                        Icons.home,
                        Colors.blue,
                      ),

                      const SizedBox(width: 10),

                      _statBox(
                        "0",
                        "Leading",
                        Icons.trending_up,
                        Colors.green,
                      ),

                      const SizedBox(width: 10),

                      _statBox(
                        "0",
                        "Outbid",
                        Icons.close,
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  ],
                  if (!isSeller) ...[
                  /// EMPTY BIDS CARD
                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(24),

                    decoration: BoxDecoration(

                      color:
                          const Color(0xFF0F172A),

                      borderRadius:
                          BorderRadius.circular(24),
                    ),

                    child: Column(

                      children: [

                        const Icon(

                          Icons.gavel,

                          size: 48,

                          color: Colors.grey,
                        ),

                        const SizedBox(height: 16),

                        const Text(

                          "No active bids yet",

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 20,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(

                          "Browse auctions and start bidding",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(

                          width: double.infinity,

                          child: ElevatedButton(

                            onPressed: () {

                              Navigator.pop(
                                  context);
                            },

                            child: const Text(
                                "Browse Auctions"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                 ],
                  /// SELLER DASHBOARD BUTTON
                  if (isSeller)

                    Container(

                      decoration: BoxDecoration(

                        color:
                            const Color(0xFF0F172A),

                        borderRadius:
                            BorderRadius.circular(22),
                      ),

                      child: ListTile(

                        leading: Container(

                          padding:
                              const EdgeInsets.all(12),

                          decoration: BoxDecoration(

                            color:
                                const Color(
                                    0xFF172554),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(

                            Icons.dashboard,

                            color:
                                Color(0xFF6C97FF),
                          ),
                        ),

                        title: const Text(

                          "Open Seller Dashboard",

                          style: TextStyle(

                            color: Colors.white,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: const Text(

                          "View listings, bids, and stats",

                          style:
                              TextStyle(color: Colors.grey),
                        ),

                        trailing: const Icon(

                          Icons.arrow_forward_ios,

                          color: Colors.grey,

                          size: 18,
                        ),

                        onTap: () {

                          if (onOpenDashboard !=
                              null) {

                            onOpenDashboard!();
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 26),

                  /// SIGN OUT BUTTON
                  SizedBox(

                    width: double.infinity,

                    child: OutlinedButton.icon(

                      style:
                          OutlinedButton.styleFrom(

                        side: const BorderSide(
                          color: Colors.red,
                        ),

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                      ),

                      onPressed: () async {

                        await FirebaseAuth.instance
                            .signOut();

                        Navigator.pushAndRemoveUntil(

                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const AuthScreen(),
                          ),

                          (route) => false,
                        );
                      },

                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),

                      label: const Text(

                        "Sign Out",

                        style: TextStyle(

                          color: Colors.red,

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statBox(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),

        decoration: BoxDecoration(

          color: const Color(0xFF0F172A),

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Column(

          children: [

            Icon(
              icon,
              color: color,
              size: 24,
            ),

            const SizedBox(height: 10),

            Text(

              value,

              style: TextStyle(

                color: color,

                fontSize: 26,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(

              label,

              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 