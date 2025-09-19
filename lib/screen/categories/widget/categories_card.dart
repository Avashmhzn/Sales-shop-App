import 'package:flutter/material.dart';
import 'package:saleup_app/model/category_response.dart';

// New CategoryCard widget
class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final double screenWidth;
  final double screenHeight;

  const CategoryCard({
    super.key,
    required this.category,
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
            onTap: () {}, // Absorb taps
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
                    Text('Name: ${category.name ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('Short Code: ${category.shortCode ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('Status: ${category.status ? 'Active' : 'Inactive'}'),
                    Text(
                        'Description: ${(category.description ?? '').trim().isEmpty ? 'N/A' : category.description}'),
                    const SizedBox(height: 8),
                    Text('Created On: ${category.createdOn.toIso8601String()}'),
                    const SizedBox(height: 8),
                    Text('Updated On: ${category.updatedOn.toIso8601String()}'),
                    if (category.subcategories.isNotEmpty)
                      Text('Subcategories: ${category.subcategories.length}'),
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
                color: Colors.black.withOpacity(0.1),
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
                      category.name ?? 'Unnamed Category',
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
                      'Code: ${category.shortCode ?? 'N/A'}',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Status: ${category.status ? 'Active' : 'Inactive'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      category.subcategories.isNotEmpty
                          ? 'Subcats: ${category.subcategories.length}'
                          : 'No Subcats',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.end,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
