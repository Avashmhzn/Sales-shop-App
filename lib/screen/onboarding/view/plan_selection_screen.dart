import 'package:flutter/material.dart';
import 'package:saleup_app/screen/dashboard/view/dashboard_screen.dart';
import 'package:saleup_app/screen/onboarding/view/advanced_price.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  PlanSelectionScreenState createState() => PlanSelectionScreenState();
}

class PlanSelectionScreenState extends State<PlanSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 7),
                        margin: const EdgeInsets.only(
                            bottom: 35, left: 19, right: 19),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              child: const Text(
                                "Choose Your Plan",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 359,
                              child: Text(
                                "Start with the basics, and explore advanced features whenever you're ready!",
                                style: TextStyle(
                                  color: Color(0xFF767272),
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Plan card
                      const PlanCard(
                        title: "Startup Plan- Free",
                        price: "Rs 0",
                        features: [
                          {"title": "Inventory Tracking", "enabled": true},
                          {"title": "Assets Management", "enabled": true},
                          {"title": "Creditor Management", "enabled": true},
                          {
                            "title": "Detailed Sales and Purchase Report",
                            "enabled": false
                          },
                          {"title": "Priority Support", "enabled": false},
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Buttons
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardScreen(),
                                    ),
                                  );
                                }, //payment
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFED864B),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChoosePlanAdvance(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFED864B), width: 1),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16), // Adjusted height
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Explore Advance Feature",
                                  style: TextStyle(
                                    color: Color(0xFFED864B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
}

// Plan Card Widget
class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<Map<String, dynamic>> features;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE3E3E3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF2EEF8), // Light background to enhance elevation
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.15), // Darker shadow for stronger elevation
            blurRadius: 25, // Increased blur for depth effect
            spreadRadius: 5, // Slightly larger spread
            offset: const Offset(0, 8), // Stronger elevation effect
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan title and price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            margin: const EdgeInsets.only(bottom: 24, left: 49, right: 49),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF292929),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF292929),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "/per month",
                        style: TextStyle(
                          color: Color(0xFF909090),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Features list
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: features
                  .map((feature) =>
                      _buildFeatureRow(feature["title"], feature["enabled"]))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      margin: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.orange : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color:
                  isActive ? const Color(0xFF191919) : const Color(0xFF787474),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
