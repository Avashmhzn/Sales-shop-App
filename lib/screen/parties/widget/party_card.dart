import 'package:flutter/material.dart';
import 'package:saleup_app/model/party_response.dart';

class PartyCard extends StatelessWidget {
  final PartyData party;
  final double screenWidth;
  final double screenHeight;

  const PartyCard({
    super.key,
    required this.party,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Parties Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    Text('Party: ${party.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('ID: ${party.id}'),
                    Text('Type: ${party.type ?? 'N/A'}'),
                    Text('Account Type: ${party.accType ?? 'N/A'}'),
                    Text('PAN: ${party.panNumber ?? 'N/A'}'),
                    Text('Phone: ${party.phone ?? 'N/A'}'),
                    Text('Address: ${party.address ?? 'N/A'}'),
                    Text(
                        'Opening Balance: ${party.openingBalance != null ? 'Rs ${party.openingBalance!.toStringAsFixed(2)}' : 'Rs 0.00'}'),
                    Text(
                        'Status: ${party.status != null ? (party.status! ? 'Active' : 'Inactive') : 'N/A'}'),
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
                      party.name,
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
                      'ID: ${party.id}',
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
                      party.type ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      party.accType ?? 'N/A',
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      party.openingBalance != null
                          ? 'Rs ${party.openingBalance!.toStringAsFixed(2)}'
                          : 'Rs 0.00',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      party.phone ?? 'N/A',
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
