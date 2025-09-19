import 'package:flutter/material.dart';
import 'package:saleup_app/screen/notification/view/notification_screen.dart';
import 'package:saleup_app/screen/supplier/model/supplier_model.dart';
import 'package:saleup_app/theme/custom_app_bar.dart';
import 'package:saleup_app/utility/bottomnav.dart';

class SupplierViewScreen extends StatefulWidget {
  final Supplier supplier;
  final Function(Supplier)? onEdit; // Callback for editing the supplier
  final Function()? onDelete; // Callback for deleting the supplier

  const SupplierViewScreen({
    super.key,
    required this.supplier,
    this.onEdit,
    this.onDelete,
  });

  @override
  _SupplierViewScreenState createState() => _SupplierViewScreenState();
}

class _SupplierViewScreenState extends State<SupplierViewScreen> {
  int _selectedIndex = 2; // Default to Purchase tab (as per your app structure)
  final bool _isBottomNavVisible = true;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _notificationCount = 3; // Matches the 3 notifications in the image

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Matches the design
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onMenuPressed: () {
                Navigator.pop(context);
              },
              notificationCount: _notificationCount,
              onNotificationTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );

                if (result != null && result is int) {
                  setState(() {
                    _notificationCount = result;
                  });
                }
              },
            ),
            const Divider(thickness: 1, height: 1, color: Colors.grey),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Matches the overall screen padding in the image
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Vertically center the icon and text
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 20, // Matches the design
                            ),
                            SizedBox(width: 4), // Matches the design
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height:
                              16), // Matches the spacing below the "Back" button
                      // Supplier details in a card
                      Container(
                        padding: const EdgeInsets.all(12), // Matches the design
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                                'Supplier Name', widget.supplier.name),
                            _buildDetailRow(
                                'Contact Number', '+977-9812121212'),
                            _buildDetailRow(
                                'Address', widget.supplier.location),
                            _buildDetailRow('Email', 'abc@gmail.com'),
                            _buildDetailRow(
                                'Company Name', 'BloomTech Suppliers'),
                            _buildDetailRow(
                                'Company Address', widget.supplier.location),
                            _buildDetailRow(
                                'Company Contact', '+977-9812121212'),
                            _buildDetailRow(
                                'Supplier Relationship', widget.supplier.type),
                            _buildDetailRow('Expiry Date', '2024/10/23'),
                            const SizedBox(height: 12), // Matches the design
                            // Action buttons inside the card
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildActionButton(
                                  'Edit',
                                  Icons.edit,
                                  const Color(0xFF8E44AD), // Purple color
                                  () {
                                    if (widget.onEdit != null) {
                                      final updatedSupplier = Supplier(
                                        name:
                                            "${widget.supplier.name} (Updated)",
                                        location: widget.supplier.location,
                                        type: widget.supplier.type,
                                      );
                                      widget.onEdit!(updatedSupplier);
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                                const SizedBox(width: 16), // Matches the design
                                _buildActionButton(
                                  'Delete',
                                  Icons.delete,
                                  const Color(0xFFE74C3C), // Red color
                                  () {
                                    if (widget.onDelete != null) {
                                      widget.onDelete!();
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isBottomNavVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: BottomNav(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
