// import 'package:flutter/material.dart';
// import 'package:saleup_app/model/account_heads_response.dart';
// import 'package:saleup_app/screen/accountHead/view/account_head_details.dart';

// class AccountHeadCard extends StatelessWidget {
//   final AccountHeadData head;
//   final double screenWidth;
//   final double screenHeight;
//   final Function(int) onDelete; // Callback for delete action

//   const AccountHeadCard({
//     super.key,
//     required this.head,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (context) => GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {}, // Absorb taps
//             child: AlertDialog(
//               insetPadding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.03,
//                 vertical: screenHeight * 0.1,
//               ),
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     color: Colors.grey[600],
//                   ),
//                 ],
//               ),
//               content: SizedBox(
//                 width: screenWidth * 0.9,
//                 child: AccountHeadDetails(accountHeadId: head.id),
//               ),
//               actions: const [], // No default close
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // Allow vertical alignment
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                       softWrap: true, // Ensure text wraps to multiple lines
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       'ID: ${head.id}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.end,
//                       softWrap: true, // Ensure text wraps to multiple lines
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // Allow vertical alignment
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.parent ?? 'N/A',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       softWrap: true, // Ensure text wraps to multiple lines
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       head.mainGroup ?? 'N/A',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       textAlign: TextAlign.end,
//                       softWrap: true, // Ensure text wraps to multiple lines
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // Allow vertical alignment
//                 children: [
//                   Expanded(
//                     child: Text(
//                       head.openingBalance != null
//                           ? 'Rs ${head.openingBalance!.toStringAsFixed(2)}'
//                           : 'Rs 0.00',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       softWrap: true, // Ensure text wraps to multiple lines
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'package:saleup_app/screen/accountHead/view/account_head_details.dart';

class AccountHeadCard extends StatelessWidget {
  final AccountHeadData head;
  final double screenWidth;
  final double screenHeight;

  const AccountHeadCard({
    super.key,
    required this.head,
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
                child: AccountHeadDetails(accountHeadId: head.id),
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
                      head.name,
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
                      'ID: ${head.id}',
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
                      head.parent ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      head.mainGroup ?? 'N/A',
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
                      head.openingBalance != null
                          ? 'Rs ${head.openingBalance!.toStringAsFixed(2)}'
                          : 'Rs 0.00',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
