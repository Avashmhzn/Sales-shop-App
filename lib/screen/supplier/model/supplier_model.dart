// models/supplier.dart
class Supplier {
  final String name;
  final String location;
  final String type;
  final String contactNumber;
  final String email;
  final String companyName;
  final String companyContact;
  final String expiryDate;
  final String productQuantity;
  final String productRate;
  final String productName1;
  final String productName2;
  final String companyAddress;
  final String supplierRelation;

  Supplier({
    required this.name,
    required this.location,
    required this.type,
    this.contactNumber = '977-9812121212',
    this.email = 'abc@gmail.com',
    this.companyName = 'BloomTech Suppliers',
    this.companyContact = '977-9812121212',
    this.expiryDate = '20/10/23',
    this.productQuantity = '100',
    this.productRate = '50',
    this.productName1 = 'Product A',
    this.productName2 = 'Product B',
    this.companyAddress = '123 Main St',
    this.supplierRelation = 'Primary',
  });
}