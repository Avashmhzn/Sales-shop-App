import 'package:flutter/material.dart';

// Model class for purchase items
class PurchaseItem {
  String id;
  String name;
  String price;
  String quantity;
  String? paymentStatus;
  String category;
  String tax;
  String discount;
  String shippingCost;
  String subtotal;
  String totalPrice;

  PurchaseItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.paymentStatus,
    required this.category,
    required this.tax,
    required this.discount,
    required this.shippingCost,
    required this.subtotal,
    required this.totalPrice,
  });
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int _selectedIndex = 2;
  final bool _isBottomNavVisible = true;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Furniture',
    'Books',
    'Other',
  ];

  final List<String> _paymentStatuses = [
    'Paid',
    'Pending',
    'Failed',
  ];

  final List<PurchaseItem> expenses = [
    PurchaseItem(
      id: '1',
      name: 'iPhone Pro Max',
      price: '500',
      quantity: '12',
      paymentStatus: 'Paid',
      category: 'Electronics',
      tax: '500',
      discount: '15%',
      shippingCost: '100',
      subtotal: '₹ 500,000',
      totalPrice: '1,000,000',
    ),
    PurchaseItem(
      id: '2',
      name: 'iPhone Pro Max',
      price: '500',
      quantity: '12',
      paymentStatus: 'Paid',
      category: 'Electronics',
      tax: '500',
      discount: '15%',
      shippingCost: '100',
      subtotal: '₹ 500,000',
      totalPrice: '1,000,000',
    ),
  ];

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

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isDropdown = false,
    List<String>? dropdownItems,
    TextStyle? valueStyle,
    Function(String?)? onDropdownChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          if (isDropdown && dropdownItems != null && onDropdownChanged != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                value: value,
                items: dropdownItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: valueStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                    ),
                  );
                }).toList(),
                onChanged: onDropdownChanged,
                underline: const SizedBox(), // Remove default underline
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
                style: valueStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(4),
                isDense: true, // Reduce extra padding
              ),
            )
          else
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Roboto',
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
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.notifications_none),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 8,
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        label: 'Product Name:',
                        value: expense.name,
                      ),
                      _buildDetailRow(
                        label: 'Category:',
                        value: expense.category,
                        isDropdown: true,
                        dropdownItems: _categories,
                        onDropdownChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              expenses[index].category = newValue;
                            });
                          }
                        },
                      ),
                      _buildDetailRow(
                        label: 'Quantity:',
                        value: expense.quantity,
                      ),
                      _buildDetailRow(
                        label: 'Unit Price:',
                        value: 'Rs ${expense.price}',
                      ),
                      _buildDetailRow(
                        label: 'TAX:',
                        value: 'Rs ${expense.tax}',
                      ),
                      _buildDetailRow(
                        label: 'Discount:',
                        value: expense.discount,
                      ),
                      _buildDetailRow(
                        label: 'Price:',
                        value: expense.subtotal,
                      ),
                      _buildDetailRow(
                        label: 'Shipping Cost:',
                        value: 'Rs ${expense.shippingCost}',
                      ),
                      _buildDetailRow(
                        label: 'Total Price:',
                        value: 'Rs ${expense.totalPrice}',
                        valueStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      _buildDetailRow(
                        label: 'Payment Status:',
                        value: expense.paymentStatus ?? '',
                        isDropdown: true,
                        dropdownItems: _paymentStatuses,
                        valueStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: expense.paymentStatus == 'Paid'
                              ? Colors.green
                              : Colors.red,
                          fontFamily: 'Roboto',
                        ),
                        onDropdownChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              expenses[index].paymentStatus = newValue;
                            });
                          }
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
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isBottomNavVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
