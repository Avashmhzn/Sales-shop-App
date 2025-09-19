import 'package:flutter/material.dart';
import 'package:saleup_app/screen/supplier/model/supplier_model.dart'; // Import the shared Supplier class

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  _AddSupplierScreenState createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _typeController.text.isNotEmpty) {
      final newSupplier = Supplier(
        name: _nameController.text,
        location: _locationController.text,
        type: _typeController.text,
      );
      Navigator.pop(context, newSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Supplier Name'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Supplier'),
            ),
          ],
        ),
      ),
    );
  }
}