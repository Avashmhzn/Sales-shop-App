import 'package:flutter/material.dart';
import 'package:saleup_app/screen/notification/view/notification_screen.dart';
import 'package:saleup_app/screen/supplier/model/supplier_model.dart';
import 'package:saleup_app/theme/custom_app_bar.dart';
import 'package:saleup_app/utility/bottomnav.dart';
import 'add_supplier_screen.dart';
import 'view_supplier_screen.dart';
import 'edit_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  _SuppliersScreenState createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<Supplier> suppliers = [
    Supplier(
      name: "Subash Suppliers",
      location: "Ratopul, Kathmandu",
      type: "Vendor",
      contactNumber: "977-9812121212",
      email: "subash@example.com",
      companyName: "BloomTech Suppliers",
      companyContact: "977-9812121212",
      expiryDate: "20/10/23",
      productQuantity: "100",
      productRate: "50",
      productName1: "Product A",
      productName2: "Product B",
      companyAddress: "Ratopul, Kathmandu",
      supplierRelation: "Primary",
    ),
    Supplier(
      name: "Jasmine Imports",
      location: "Los Angeles, California",
      type: "Vendor",
    ),
    Supplier(
      name: "Smith & Co.",
      location: "London, UK",
      type: "Vendor",
    ),
    Supplier(
      name: "Green Leaf Farms",
      location: "Sydney, Australia",
      type: "Vendor",
    ),
    Supplier(
      name: "Sunrise Supplies",
      location: "New York, USA",
      type: "Vendor",
    ),
    Supplier(
      name: "Golden Harvest Trading",
      location: "Toronto, Canada",
      type: "Vendor",
    ),
    Supplier(
      name: "Oceanic Foods",
      location: "Auckland, New Zealand",
      type: "Vendor",
    ),
  ];

  int _selectedIndex = 2; // Default to Purchase tab (as per your app structure)
  bool _isBottomNavVisible = true;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _notificationCount = 3;

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

  void _deleteSupplier(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to delete this supplier?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: The action cannot be undone once taken.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          suppliers.removeAt(index);
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Supplier deleted successfully!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        elevation: 0,
                        minimumSize: const Size(120, 36),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        minimumSize: const Size(120, 36),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBottomNavVisibilityChanged(bool isVisible) {
    setState(() {
      _isBottomNavVisible = isVisible;
    });
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

  void _addSupplier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
    );

    if (result != null && result is Supplier) {
      setState(() {
        suppliers.add(result);
      });
    }
  }

  Widget _buildSuppliersListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Expanded(
                child: Text(
                  'Suppliers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Here',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon:
                        Icon(Icons.filter_list, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: _addSupplier,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[500],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '+ Add Supplier',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          supplier.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          supplier.type,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildActionButton(
                            'View', Icons.visibility, const Color(0xFFF5A623),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupplierViewScreen(
                                supplier: supplier,
                                onEdit: (updatedSupplier) {
                                  setState(() {
                                    suppliers[index] = updatedSupplier;
                                  });
                                },
                                onDelete: () {
                                  _deleteSupplier(index);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        }, index),
                        const SizedBox(width: 16),
                        _buildActionButton('Edit', Icons.edit,
                            const Color(0xFF8E44AD), () {}, index),
                        const SizedBox(width: 16),
                        _buildActionButton(
                            'Delete', Icons.delete, const Color(0xFFE74C3C),
                            () {
                          _deleteSupplier(index);
                        }, index),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap, int index) {
    return GestureDetector(
      onTap: label == 'Edit'
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSupplierScreen(
                    supplier: suppliers[index],
                    onEdit: (Supplier updatedSupplier) {
                      setState(() {
                        suppliers[index] = updatedSupplier;
                      });
                    },
                  ),
                ),
              );
            }
          : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
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
                _scaffoldKey.currentState?.openDrawer();
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
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                physics: const ClampingScrollPhysics(),
                children: [
                  const Center(child: Text('Home Screen - Coming Soon')),
                  const Center(child: Text('Inventory Screen - Coming Soon')),
                  _buildSuppliersListContent(),
                  const Center(child: Text('Sales Screen - Coming Soon')),
                  const Center(child: Text('Settings Screen - Coming Soon')),
                ],
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
