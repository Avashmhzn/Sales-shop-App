// lib/auth/view/createCompany/widget/domain_field.dart
import 'package:flutter/material.dart';

class DomainField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DomainField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Domain:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // http:// prefix
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: const Text(
                  'http://',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
              Container(width: 1, color: const Color(0xFFD1D5DB)),
              // Editable subdomain
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'yourstore',
                    hintStyle:
                        TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                    isDense: true,
                    errorStyle: TextStyle(height: 0), // hide inline error
                  ),
                ),
              ),
              Container(width: 1, color: const Color(0xFFD1D5DB)),
              // .salesshopnepal.com suffix
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: const Text(
                  'salesshopnepal.com',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
        // Live full-domain preview
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Full domain: ${value.text}.salesshopnepal.com',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            );
          },
        ),
      ],
    );
  }
}
