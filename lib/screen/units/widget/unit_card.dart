// File: lib/screen/units/widget/unit_card.dart
import 'package:flutter/material.dart';
import 'package:saleup_app/model/unit_response.dart';

class UnitCard extends StatelessWidget {
  final UnitData unit;
  final double screenWidth;
  final double screenHeight;

  const UnitCard({
    super.key,
    required this.unit,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenHeight * 0.1,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              content: SizedBox(
                width: screenWidth * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unit: ${unit.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('ID: ${unit.id}'),
                    Text('Description: ${unit.description ?? 'N/A'}'),
                  ],
                ),
              ),
              actions: const [],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      unit.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'ID: ${unit.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.end,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                unit.description ?? 'N/A',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
