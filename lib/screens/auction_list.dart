import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'property_detail.dart';

class AuctionList extends StatefulWidget {
  const AuctionList({super.key});

  @override
  State<AuctionList> createState() => AuctionListState();
}
class AuctionListState extends State<AuctionList> {
  String selectedTab = "All";

  @override
void initState() {
  super.initState();
}
  /// PRICE FORMAT
  String formatPrice(dynamic price) {
    double p = 0;

    if (price is int) {
      p = price.toDouble();
    } else if (price is double) {
      p = price;
    } else {
      p = double.tryParse(price.toString()) ?? 0;
    }

    if (p >= 1000000) {
      return "${(p / 1000000).toStringAsFixed(2)}M";
    }

    if (p >= 1000) {
      return "${(p / 1000).toStringAsFixed(1)}K";
    }

    return p.toStringAsFixed(0);
  }

  /// TIMER
  String getRemainingTime(dynamic endTime) {
    if (endTime == null) return "Ended";

    int end;

    if (endTime is Timestamp) {
      end = endTime.millisecondsSinceEpoch;
    } else if (endTime is int) {
      end = endTime;
    } else {
      return "Ended";
    }

    final diff =
        end - DateTime.now().millisecondsSinceEpoch;

    if (diff <= 0) {
      return "Ended";
    }

    final h = diff ~/ (1000 * 60 * 60);

    final m =
        (diff ~/ (1000 * 60)) % 60;

    final s =
        (diff ~/ 1000) % 60;

    return
        "${h.toString().padLeft(2, '0')}:"
        "${m.toString().padLeft(2, '0')}:"
        "${s.toString().padLeft(2, '0')}";
  }

  /// BADGE
  Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  /// FILTER BUTTON
  Widget filterButton(
      String text,
      IconData icon,
      ) {

    bool active = selectedTab == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
        });
      },

      child: Container(
        margin:
            const EdgeInsets.only(right: 10),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: active
              ? Colors.blue
              : const Color(0xFF1E293B),

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              size: 15,
              color: active
                  ? Colors.white
                  : Colors.grey,
            ),

            const SizedBox(width: 5),

            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color: active
                    ? Colors.white
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xFF020617),

      child: SafeArea(

          child: Column(

            children: [

              /// HEADER
              Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: const [

                    CircleAvatar(
                      backgroundColor:
                          Color(0xFF1E293B),

                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                  const Text(
                      "Auctions",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 40),
                  ],
                ),
              ),

              /// FILTERS
              SizedBox(
                height: 70,

                child: ListView(
                  scrollDirection:
                      Axis.horizontal,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  children: [

                    filterButton(
                      "All",
                      Icons.grid_view,
                    ),

                    filterButton(
                      "Live",
                      Icons.wifi,
                    ),

                    filterButton(
                      "Upcoming",
                      Icons.access_time,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// AUCTION LIST
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection('auctions')
                    .orderBy(
                      'endTime',
                      descending: true,
                    )
                    .snapshots(),

                builder:
                    (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  final docs =
                      snapshot.data!.docs;

                  if (docs.isEmpty) {

                    return const Center(
                      child: Text(
                        "No auctions found",

                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
  return ListView.builder(
    padding: const EdgeInsets.only(
      left: 16,
      right: 16,
      top: 10,
      bottom: 120,
    ),
    itemCount: docs.length,
    itemBuilder: (context, i) {

                        final doc = docs[i];

                        final d =
                            doc.data()
                                as Map<String,
                                    dynamic>;

                        final remaining =
                            getRemainingTime(
                                d['endTime']);

                        final isEnded =
                            remaining ==
                                "Ended";

                        String status =
                            isEnded
                                ? "ended"
                                : (d['status'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();

                        /// FILTER
                        if (selectedTab ==
                                "Live" &&
                            status != "live") {
                          return const SizedBox();
                        }

                        if (selectedTab ==
                                "Upcoming" &&
                            status !=
                                "upcoming") {
                          return const SizedBox();
                        }

                        final users =
                            (d['users'] is List)
                                ? (d['users']
                                        as List)
                                    .take(3)
                                    .toList()
                                : [];

                        final price =
                            (d['highestBid'] ??
                                    d['price']) ??
                                0;

                        return GestureDetector(

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    PropertyDetail(
                                  data: d,
                                  docId: doc.id,
                                ),
                              ),
                            );
                          },

                          child: Container(

                            margin: const EdgeInsets.only(
                               bottom: 20,
                        ),

                            decoration: BoxDecoration(
                              color:
                                  const Color(
                                      0xFF0F172A),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                /// IMAGE
                                Stack(
                                  children: [

                                    ClipRRect(

                                      borderRadius:
                                          const BorderRadius
                                              .vertical(
                                        top: Radius
                                            .circular(
                                                20),
                                      ),

                                      child:
                                          Image.network(

                                        d['image'] ??
                                            "",

                                        height: 145,

                                        width:
                                            double
                                                .infinity,

                                        fit: BoxFit
                                            .cover,
                                        filterQuality: FilterQuality.low,
                                        loadingBuilder:
                                            (
                                          context,
                                          child,
                                          progress,
                                        ) {

                                          if (progress ==
                                              null) {
                                            return child;
                                          }

                                          return Container(
                                            height:
                                                160,

                                            color:
                                                const Color(
                                                    0xFF0F172A),

                                            child:
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },

                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {

                                          return Container(
                                            height:
                                                160,

                                            color:
                                                const Color(
                                                    0xFF0F172A),

                                            child:
                                                const Center(
                                              child:
                                                  Icon(
                                                Icons
                                                    .image_not_supported,
                                                color: Colors
                                                    .white54,
                                                size:
                                                    40,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    /// TIMER
                                    Positioned(
                                      top: 10,
                                      left: 10,

                                      child:
                                          Container(

                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              10,
                                          vertical:
                                              6,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .black
                                              .withOpacity(
                                                  0.6),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      20),
                                        ),

                                        child: Row(

                                          children: [

                                            const Icon(
                                              Icons
                                                  .access_time,

                                              size:
                                                  14,

                                              color:
                                                  Colors.white,
                                            ),

                                            const SizedBox(
                                                width:
                                                    5),

                                            Text(
                                              remaining,

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    /// BADGES
                                    if (status ==
                                        "live")
                                      Positioned(
                                        top: 10,
                                        right: 10,

                                        child: badge(
                                          "LIVE",
                                          Colors.green,
                                        ),
                                      ),

                                    if (status ==
                                        "ended")
                                      Positioned(
                                        top: 10,
                                        right: 10,

                                        child: badge(
                                          "ENDED",
                                          Colors.red,
                                        ),
                                      ),
                                  ],
                                ),

                                /// INFO
                                Padding(

                                  padding:
                                      const EdgeInsets
                                          .all(12),

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      SizedBox(

                                        width:
                                            MediaQuery.of(
                                                        context)
                                                    .size
                                                    .width *
                                                0.65,

                                        child: Text(

                                          d['title'] ??
                                              '',

                                          maxLines:
                                              2,

                                          overflow:
                                              TextOverflow
                                                  .ellipsis,

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,

                                            fontSize:
                                                15,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              6),

                                      Text(

                                        d['address'] ??
                                            '',

                                        maxLines:
                                            1,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,

                                          fontSize:
                                              13,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              10),

                                      Wrap(

                                        alignment:
                                            WrapAlignment
                                                .spaceBetween,

                                        crossAxisAlignment:
                                            WrapCrossAlignment
                                                .center,

                                        spacing:
                                            10,

                                        runSpacing:
                                            8,

                                        children: [

                                          /// USERS
                                          Row(

                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,

                                            children:
                                                users
                                                    .take(
                                                        3)
                                                    .map<
                                                            Widget>(
                                                        (u) {

                                              return Container(

                                                margin:
                                                    const EdgeInsets
                                                        .only(
                                                  right:
                                                      6,
                                                ),

                                                width:
                                                    26,

                                                height:
                                                    26,

                                                decoration:
                                                    const BoxDecoration(
                                                  color:
                                                      Colors.blueGrey,

                                                  shape:
                                                      BoxShape.circle,
                                                ),

                                                child:
                                                    Center(

                                                  child:
                                                      Text(

                                                    u.toString(),

                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.white,
                                                      fontSize:
                                                          10,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                          /// PRICE
                                          Text(

                                            "\$${formatPrice(price)}",

                                            maxLines:
                                                1,

                                            overflow:
                                                TextOverflow
                                                    .ellipsis,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.amber,

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize:
                                                  16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
          ),
        ),
      );
    }
  }