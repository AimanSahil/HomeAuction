import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),

            child: Column(
              children: [

                const SizedBox(height: 20),

                /// LOGO SECTION
                Center(
                  child: Container(
                    height: 210,
                    width: 210,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(55),

                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B295A),
                          Color(0xFF101936),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.18),
                          blurRadius: 35,
                          spreadRadius: 6,
                        ),
                      ],
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(55),

                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Lottie.asset(
                          'assets/animations/Bidding icon.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                /// TITLE
                const Text(
                  "HomeAuction",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 10),

                /// SUBTITLE
                RichText(
                  textAlign: TextAlign.center,

                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                    ),

                    children: [

                      TextSpan(
                        text: "Bid smart. ",
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),

                      TextSpan(
                        text: "Win big.",
                        style: TextStyle(
                          color: Color(0xFFFFC857),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 42),

                /// FEATURES
                featureCard(
                  Icons.bolt,
                  "Live Auctions",
                  "Bid in real-time on exclusive properties",
                ),

                const SizedBox(height: 18),

                featureCard(
                  Icons.shield_outlined,
                  "Secure Bidding",
                  "Every bid is verified and protected",
                ),

                const SizedBox(height: 18),

                featureCard(
                  Icons.trending_up,
                  "Win Smart",
                  "Track the market and outbid the competition",
                ),

                const SizedBox(height: 42),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 66,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C97FF),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),

                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/auth',
                      );
                    },

                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(width: 10),

                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget featureCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF121A3A),

        borderRadius: BorderRadius.circular(26),

        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: const Color(0xFF1A234A),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF6C97FF),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,

                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.4,
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