import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_property_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      body: SafeArea(
        child: Stack(
          children: [

            /// MAIN CONTENT
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('auctions')
                  .where(
                    'sellerId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                int active = docs.length;
                int totalBids = 0;
                int reserveMet = 0;
                double totalValue = 0;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  totalBids += (data['bidCount'] ?? 0) as int;

                  double highest =
                      (data['highestBid'] ?? 0).toDouble();

                  double reserve =
                      (data['reserve'] ??
                              data['reserved'] ??
                              0)
                          .toDouble();

                  if (highest >= reserve && reserve > 0) {
                    reserveMet++;
                  }

                  totalValue += highest;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    42,
                    22,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      /// HEADER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text(
                                "Seller Dashboard",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: const [

                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 10,
                                  ),

                                  SizedBox(width: 8),

                                  Text(
                                    "Updates every 5s",
                                    style: TextStyle(
                                      color:
                                          Colors.green,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// FLOATING ADD BUTTON
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: FloatingActionButton(
                              elevation: 0,
                              backgroundColor:
                                  const Color(
                                      0xFF6C97FF),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(24),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {

                                /// OPEN AS MODAL
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled:
                                      true,
                                  backgroundColor:
                                      Colors
                                          .transparent,
                                  builder: (_) =>
                                      const AddPropertyScreen(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// GRID
                      GridView.count(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.08,
                        children: [

                          _card(
                            Icons.home_outlined,
                            "$active",
                            "Active",
                            Colors.blueAccent,
                          ),

                          _card(
                            Icons.show_chart,
                            "$totalBids",
                            "Total Bids",
                            Colors.orangeAccent,
                          ),

                          _card(
                            Icons.check_circle_outline,
                            "$reserveMet",
                            "Reserve Met",
                            Colors.greenAccent,
                          ),

                          _card(
                            Icons.attach_money,
                            "\$${totalValue.toStringAsFixed(0)}",
                            "Bid Value",
                            Colors.amber,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        "Your Listings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// EMPTY
                      if (docs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF121A3A),
                            borderRadius:
                                BorderRadius.circular(
                                    32),
                          ),
                          child: Column(
                            children: [

                              const Icon(
                                Icons.home_outlined,
                                size: 72,
                                color: Colors.white30,
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                "No listings yet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "List your first property to start receiving bids",
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        const Color(
                                            0xFF6C97FF),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  30),
                                    ),
                                  ),
                                  onPressed: () {

                                    /// MODAL
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled:
                                          true,
                                      backgroundColor:
                                          Colors
                                              .transparent,
                                      builder: (_) =>
                                          const AddPropertyScreen(),
                                    );
                                  },
                                  child: const Text(
                                    "+ List a Property",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// LISTINGS
                      if (docs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder:
                              (context, index) {

                            final data =
                                docs[index].data()
                                    as Map<String,
                                        dynamic>;

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 18),
                              decoration: BoxDecoration(
                                color:
                                    const Color(
                                        0xFF121A3A),
                                borderRadius:
                                    BorderRadius
                                        .circular(26),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  /// IMAGE
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius
                                            .vertical(
                                      top: Radius
                                          .circular(26),
                                    ),
                                    child: Image.network(
                                      data['image'] ??
                                          "",
                                      height: 170,
                                      width:
                                          double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [

                                        Text(
                                          data['title'] ??
                                              "",
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        Text(
                                          data['address'] ??
                                              "",
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white54,
                                            fontSize: 14,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 18),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [

                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                horizontal:
                                                    14,
                                                vertical: 6,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .green
                                                    .withOpacity(
                                                        0.15),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30),
                                              ),
                                              child:
                                                  const Text(
                                                "LIVE",
                                                style:
                                                    TextStyle(
                                                  color: Colors
                                                      .green,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            Text(
                                              "\$${(data['highestBid'] ?? data['price'] ?? 0)}",
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .amber,
                                                fontSize:
                                                    24,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
                
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF141B34),
        selectedItemColor: const Color(0xFF6C97FF),
        unselectedItemColor: Colors.white54,
        currentIndex: 1,

        onTap: (index) {

          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          }

          if (index == 1) {
            Navigator.pushNamed(context, '/dashboard');
          }

          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Auctions',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  Widget _card(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121A3A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}