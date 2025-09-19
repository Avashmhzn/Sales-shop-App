import 'package:flutter/material.dart';

// Assuming these are the imports from your project
import 'package:saleup_app/screen/notification/view/notification_screen.dart';
import 'package:saleup_app/screen/supplier/model/supplier_model.dart';
import 'package:saleup_app/theme/custom_app_bar.dart';
import 'package:saleup_app/utility/bottomnav.dart';


// Edit Supplier Screen
class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;
  final Function(Supplier) onEdit;

  const EditSupplierScreen({
    super.key,
    required this.supplier,
    required this.onEdit,
  });

  @override
  _EditSupplierScreenState createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _productQuantityController;
  late TextEditingController _productRateController;
  late TextEditingController _companyNameController;
  late TextEditingController _productName1Controller;
  late TextEditingController _companyAddressController;
  late TextEditingController _companyContactController;
  late TextEditingController _productName2Controller;
  late TextEditingController _supplierRelationController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;
  late TextEditingController _expiryDateController;

  int _selectedIndex = 2; // Default to Purchase tab (as per the image)
  final bool _isBottomNavVisible = true;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // Initialize controllers with existing supplier data
    _nameController = TextEditingController(text: widget.supplier.name);
    _contactNumberController =
        TextEditingController(text: widget.supplier.contactNumber);
    _emailController = TextEditingController(text: widget.supplier.email);
    _productQuantityController =
        TextEditingController(text: widget.supplier.productQuantity);
    _productRateController =
        TextEditingController(text: widget.supplier.productRate);
    _companyNameController =
        TextEditingController(text: widget.supplier.companyName);
    _productName1Controller =
        TextEditingController(text: widget.supplier.productName1);
    _companyAddressController =
        TextEditingController(text: widget.supplier.companyAddress);
    _companyContactController =
        TextEditingController(text: widget.supplier.companyContact);
    _productName2Controller =
        TextEditingController(text: widget.supplier.productName2);
    _supplierRelationController =
        TextEditingController(text: widget.supplier.supplierRelation);
    _locationController = TextEditingController(text: widget.supplier.location);
    _typeController = TextEditingController(text: widget.supplier.type);
    _expiryDateController =
        TextEditingController(text: widget.supplier.expiryDate);
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _nameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _productQuantityController.dispose();
    _productRateController.dispose();
    _companyNameController.dispose();
    _productName1Controller.dispose();
    _companyAddressController.dispose();
    _companyContactController.dispose();
    _productName2Controller.dispose();
    _supplierRelationController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _expiryDateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _submit() {
    // Create an updated supplier object with the edited values
    final updatedSupplier = Supplier(
      name: _nameController.text,
      contactNumber: _contactNumberController.text,
      email: _emailController.text,
      productQuantity: _productQuantityController.text,
      productRate: _productRateController.text,
      companyName: _companyNameController.text,
      productName1: _productName1Controller.text,
      companyAddress: _companyAddressController.text,
      companyContact: _companyContactController.text,
      productName2: _productName2Controller.text,
      supplierRelation: _supplierRelationController.text,
      location: _locationController.text,
      type: _typeController.text,
      expiryDate: _expiryDateController.text,
    );

    // Call the onEdit callback to update the supplier in the parent screen
    widget.onEdit(updatedSupplier);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.black54, size: 20),
                SizedBox(width: 8),
                Text(
                  'Supplier',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabeledTextField('Enter Name', _nameController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Contact Number', _contactNumberController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Email', _emailController),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Enter product quantity', _productQuantityController),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Enter Product Rate', _productRateController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Company Name', _companyNameController),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Enter product name', _productName1Controller),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Company Address', _companyAddressController),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Company Contact', _companyContactController),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Enter product name', _productName2Controller),
            const SizedBox(height: 16),
            _buildLabeledTextField(
                'Supplier Relation', _supplierRelationController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Location', _locationController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Type', _typeController),
            const SizedBox(height: 16),
            _buildLabeledTextField('Expiry Date', _expiryDateController),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[500],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isBottomNavVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: BottomNav(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
