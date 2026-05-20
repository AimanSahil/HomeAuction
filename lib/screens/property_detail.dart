import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyDetail extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const PropertyDetail({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<PropertyDetail> createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {
  int tabIndex = 0;

  Timer? timer;
  String remainingTime = "";
  bool isEnded = false;

  String formatPrice(dynamic price) {
    double p = (price is num)
        ? price.toDouble()
        : double.tryParse(price.toString()) ?? 0;

    if (p >= 1000000) return "\$${(p / 1000000).toStringAsFixed(2)}M";
    if (p >= 1000) return "\$${(p / 1000).toStringAsFixed(0)}K";
    return "\$${p.toStringAsFixed(0)}";
  }

  double toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final snap = await FirebaseFirestore.instance
          .collection('auctions')
          .doc(widget.docId)
          .get();

      final data = snap.data();
      if (data == null) return;

      int endTime = 0;


      if (data['endTime'] != null) {
  if (data['endTime'] is Timestamp) {
    endTime = data['endTime'].millisecondsSinceEpoch;
  } else {
    endTime = int.tryParse(data['endTime'].toString()) ?? 0;
  }
}

      int now = DateTime.now().millisecondsSinceEpoch;

if (endTime <= now) {
  setState(() {
    remainingTime = "Waiting for first bid";
  });
  return;
}

int diff = endTime - now;

      if (diff <= 0 && endTime != 0) {
  await endAuction();

  timer?.cancel();

  setState(() {
    remainingTime = "Auction Ended";
    isEnded = true;
  });
}
       else {
        Duration d = Duration(milliseconds: diff);
        setState(() {
          remainingTime =
              "${d.inHours.toString().padLeft(2, '0')}:"
              "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
              "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
        });
      }
    });
  }

  Future<void> endAuction() async {
    final ref = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.docId);

    final bids = await ref
        .collection('bids')
        .orderBy('amount', descending: true)
        .limit(1)
        .get();

    String winner = "No bids";

    if (bids.docs.isNotEmpty) {
  final topBid =
      bids.docs.first.data();

  winner = topBid['name'] ?? "Anonymous";
}

    await ref.update({
      'status': 'ended',
      'winner': winner,
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF020617),

    body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('auctions')
          .doc(widget.docId)
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        isEnded = data['status'] == 'ended';

        double highestBid =
            toDouble(data['highestBid'] ?? data['price'] ?? 0);

        return SafeArea(
          child: Stack(
            children: [

              /// MAIN CONTENT
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
               padding: const EdgeInsets.fromLTRB(0, 0, 0, 260),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// IMAGE
                    Stack(
                      children: [

                        Image.network(
                          data['image'] ?? '',
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              height: 280,
                              color: Colors.black12,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),

                        /// BACK BUTTON
                        Positioned(
                          top: 20,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),

                        /// STATUS
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: _statusTag(data),
                        ),

                        /// TIMER
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _timerTag(),
                        ),
                      ],
                    ),

                    /// CONTENT
                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          /// TITLE
                          Text(
  data['title'] ?? 'Property',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  ),
),

                          const SizedBox(height: 8),

                          /// ADDRESS
                         Text(
  data['address'] ?? '',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    color: Colors.white54,
  ),
),

                          const SizedBox(height: 20),

                          /// AVATAR + PRICE
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              Row(
                                children: [
                                  _avatar("S"),
                                  _avatar("M"),
                                ],
                              ),

                              Text(
                                formatPrice(highestBid),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// TABS
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B253B),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),

                            child: Row(
                              children: [
                                _tab("Auction details", 0),
                                _tab("Bidding details", 1),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TAB CONTENT
                          tabIndex == 0
                              ? auctionDetails(
                                  highestBid,
                                  data,
                                )
                              : biddingDetails(),
                              const SizedBox(height: 30),

                            _bottomBar(highestBid),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// FIXED BOTTOM BAR
              /// FIXED BOTTOM BAR
            ],
          ),
        );
      },
    ),
  );
}
  /// MODAL (FIXED EXACT)
  void openBidModal(double highest) {
    TextEditingController controller =
        TextEditingController(text: (highest + 1000).toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0B1220),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Place Your Bid",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 15),

              Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [
    _quickBtn(highest + 1000, controller),
    _quickBtn(highest + 6000, controller),
    _quickBtn(highest + 11000, controller),
    _quickBtn(highest + 26000, controller),
  ],
),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B253B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixText: "\$ ",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                 onPressed: () async {
  print("BUTTON CLICKED");

  double amount = double.tryParse(
    controller.text.replaceAll(RegExp(r'[^0-9]'), '')
  ) ?? 0;

  print("User entered: $amount");

  await placeBid(amount);

  Navigator.pop(context);
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Confirm Bid"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickBtn(double v, TextEditingController c) {
    return GestureDetector(
      onTap: () => c.text = v.toInt().toString(),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B253B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(formatPrice(v),
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> placeBid(double amount) async {
  final ref =
      FirebaseFirestore.instance.collection('auctions').doc(widget.docId);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);

    final data = snap.data();

double current =
    toDouble(data?['highestBid'] ?? data?['price'] ?? 0);
double basePrice =
    toDouble(data?['price'] ?? 0);

if (current == 0) {
  current = basePrice - 1000;
}

// 🔥 SHOW ERROR IF TOO LOW
if (amount <= current) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bid must be higher than current bid"),
      ),
    );
  }
  return;
}

    int now = DateTime.now().millisecondsSinceEpoch;
    int endTime = 0;

if (snap.data()!.containsKey('endTime')) {
  if (snap['endTime'] is Timestamp) {
  endTime = snap['endTime'].millisecondsSinceEpoch;
} else {
  endTime =
      int.tryParse(snap['endTime'].toString()) ?? 0;
}
}

    /// ✅ START TIMER ON FIRST BID
    if (endTime == 0) {
      endTime = now + (120 * 60 * 60 * 1000);
    }

    tx.update(ref, {
      'highestBid': amount,
      'endTime': endTime,
      'status': 'live',
    });
   setState(() {
  remainingTime = "Loading...";
});
    tx.set(ref.collection('bids').doc(), {
  'amount': amount,
  'name': "Sarah_K",
  'time': FieldValue.serverTimestamp(),
});
  });
}

  Widget _bottomBar(double highest) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Next Bid",
                      style: TextStyle(color: Colors.white54)),
                  Text(formatPrice(highest + 1000),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(
  width: 140,
  height: 50,
  child: ElevatedButton(
    onPressed: isEnded ? null : () => openBidModal(highest),
    child: const Text("Place Bid"),
  ),
)
          ],
        ),
      );

 Widget _statusTag(Map<String, dynamic> data) => Container(
  padding: const EdgeInsets.all(6),
  decoration: BoxDecoration(
    color: Colors.black54,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    isEnded
        ? "ENDED"
        : (data['status'] == "upcoming"
            ? "UPCOMING"
            : "LIVE"),
    style: TextStyle(
      color: isEnded ? Colors.red : Colors.green,
    ),
  ),
);

  Widget _timerTag() => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
       child: Text(
  isEnded
      ? "Auction Ended"
      : remainingTime.isEmpty
          ? "Loading..."
          : "Ends in $remainingTime",
  style: const TextStyle(color: Colors.white),
),
      );

  Widget _tab(String text, int i) {
    bool active = tabIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = i),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                active ? const Color(0xFF5B8DEF) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    color:
                        active ? Colors.white : Colors.white54)),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String t) => Container(
        margin: const EdgeInsets.only(right: 5),
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B8DEF), Color(0xFF7F53AC)],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
            child:
                Text(t, style: const TextStyle(color: Colors.white))),
      );

 Widget auctionDetails(double highest, Map data) {
  double highestBid =
    toDouble(data['highestBid'] ?? data['price'] ?? 0);

double lowestBid =
    toDouble(
      data['lowestBid'] ??
      data['price'] ??
      (highestBid - 25000),
    );

  return Column(
    children: [

     /// 🔴🟢 BID CARDS
Row(
  children: [

    Expanded(
      child: _bidCard(
        "Lowest bid",
        formatPrice(lowestBid),
        Colors.red,
        Icons.trending_down,
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: _bidCard(
        "Highest bid",
        formatPrice(highestBid),
        Colors.green,
        Icons.trending_up,
      ),
    ),
  ],
),
      const SizedBox(height: 20),
     /// FEATURES
Row(
  children: [

    Expanded(
      child: _featureCard(
        Icons.bed,
        "${data['beds'] ?? '--'}",
        "Beds",
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: _featureCard(
        Icons.bathtub,
        "${data['baths'] ?? '--'}",
        "Baths",
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: _featureCard(
        Icons.square_foot,
        "${data['sqft'] ?? '--'}",
        "Sqft",
      ),
    ),
  ],
),
      const SizedBox(height: 20),

      /// ABOUT
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "About this property",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 8),

      Text(
        data['description'] ?? "No description available",
        style: const TextStyle(color: Colors.white54),
      ),

      const SizedBox(height: 20),

      /// RESERVE
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Reserve",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 10),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B253B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reserve price",
                style: TextStyle(color: Colors.white54)),

            Text(
              formatPrice(toDouble(data['reserve'] ?? 0)),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              highestBid >= toDouble(data['reserve'])
                  ? "Reserve met"
                  : "Reserve not met",
              style: TextStyle(
                color: highestBid >= toDouble(data['reserve'])
                    ? Colors.green
                    : Colors.red,
              ),
            )
          ],
        ),
      ),
    ],
  );
}

  Widget biddingDetails() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.docId)
        .collection('bids')
        .orderBy('time', descending: true)
        .snapshots(),

    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return Container();
      }

      final bids = snapshot.data!.docs;

      return Column(
        children: bids.map((e) {

          final d = e.data() as Map<String, dynamic>;

          if (!d.containsKey('amount')) {
            return const SizedBox();
          }

          return ListTile(
            title: Text(
              d.containsKey('name')
                  ? d['name'].toString()
                  : "Anonymous",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            trailing: Text(
              formatPrice(d['amount'] ?? 0),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          );

        }).toList(),
      );
    },
  );
}

  Widget _infoCard(String t, String v, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B253B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(t, style: const TextStyle(color: Colors.white54)),
              Text(v, style: TextStyle(color: c)),
            ],
          ),
        ),
      );

       Widget _featureCard(IconData icon, String value, String label) =>
    Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B253B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF5B8DEF)),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
      Widget _bidCard(
  String title,
  String value,
  Color color,
  IconData icon,
) {
 return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B253B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 