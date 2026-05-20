import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() =>
      _AddPropertyScreenState();
}

class _AddPropertyScreenState
    extends State<AddPropertyScreen> {

  final title = TextEditingController();
  final address = TextEditingController();
  final description = TextEditingController();
  final reserve = TextEditingController();

  final bedrooms = TextEditingController(text: "3");
  final bathrooms = TextEditingController(text: "2");
  final sqft = TextEditingController(text: "1800");

  bool loading = false;

  int selectedDuration = 7;

  Future<void> addProperty() async {

    try {

      setState(() => loading = true);

      double reservePrice =
          double.tryParse(reserve.text) ?? 0;

      await FirebaseFirestore.instance
          .collection('auctions')
          .add({

        'title': title.text.trim(),
        'address': address.text.trim(),
        'description': description.text.trim(),

        'reserve': reservePrice,
        'price': reservePrice,
        'highestBid': 0,
        'bidCount': 0,

        'beds':
            int.tryParse(bedrooms.text) ?? 0,

        'baths':
            int.tryParse(bathrooms.text) ?? 0,

        'sqft':
            int.tryParse(sqft.text) ?? 0,

        'duration': selectedDuration,

        'status': 'live',

        'sellerId':
            FirebaseAuth.instance.currentUser?.uid,

        'createdAt': Timestamp.now(),

        'image':
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
      });

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height:
          MediaQuery.of(context).size.height * 0.90,

      decoration: const BoxDecoration(
        color: Color(0xFF020617),

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),

      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// HANDLE
              Center(
                child: Container(
                  width: 42,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.white24,

                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),

                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),

                  const Text(
                    "List Property",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 24),
                ],
              ),

              const SizedBox(height: 20),

              /// IMAGE BOX
              Container(
                width: double.infinity,
                height: 150,

                decoration: BoxDecoration(
                  color: const Color(0xFF121A3A),

                  borderRadius:
                      BorderRadius.circular(24),
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Container(
                      width: 54,
                      height: 54,

                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.12),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF6C97FF),
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Add property photo",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Tap to upload from your library",

                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _label("Property Title"),

              const SizedBox(height: 8),

              _field(
                controller: title,
                hint:
                    "e.g. Modern Home in Green Valley",
              ),

              const SizedBox(height: 16),

              _label("Address"),

              const SizedBox(height: 8),

              _field(
                controller: address,
                hint: "123 Main St, City, State",
              ),

              const SizedBox(height: 16),

              _label("Description"),

              const SizedBox(height: 8),

              _field(
                controller: description,
                hint: "Describe the property...",
                maxLines: 3,
              ),

              const SizedBox(height: 18),

              Row(
                children: [

                  Expanded(
                    child: _miniField(
                      "Bedrooms",
                      bedrooms,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _miniField(
                      "Bathrooms",
                      bathrooms,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _miniField(
                      "Sqft",
                      sqft,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _label("Reserve Price (\$)"),

              const SizedBox(height: 8),

              _field(
                controller: reserve,
                hint: "e.g. 500000",
                keyboard:
                    TextInputType.number,
              ),

              const SizedBox(height: 18),

              _label("Auction Duration"),

              const SizedBox(height: 10),

              Row(
                children: [

                  _durationButton(3),

                  const SizedBox(width: 8),

                  _durationButton(7),

                  const SizedBox(width: 8),

                  _durationButton(14),

                  const SizedBox(width: 8),

                  _durationButton(30),
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed:
                      loading ? null : addProperty,

                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,

                    backgroundColor:
                        const Color(0xFF6C97FF),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),

                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "List Property",

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {

    return Text(
      text,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboard =
        TextInputType.text,
  }) {

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 13,
        ),

        filled: true,

        fillColor: const Color(0xFF121A3A),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _miniField(
    String label,
    TextEditingController controller,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,

          keyboardType:
              TextInputType.number,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),

          decoration: InputDecoration(
            filled: true,

            fillColor:
                const Color(0xFF121A3A),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _durationButton(int days) {

    bool selected =
        selectedDuration == days;

    return Expanded(
      child: GestureDetector(
        onTap: () {

          setState(() {
            selectedDuration = days;
          });
        },

        child: Container(
          height: 42,

          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6C97FF)
                : const Color(0xFF121A3A),

            borderRadius:
                BorderRadius.circular(16),
          ),

          child: Center(
            child: Text(
              "${days}d",

              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}