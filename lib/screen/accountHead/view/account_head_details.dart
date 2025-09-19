// import 'package:dio/dio.dart' as dio;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/account_head_details_response.dart';
// import 'package:saleup_app/services/auth_service.dart';

// class AccountHeadDetails extends StatefulWidget {
//   final int accountHeadId;

//   const AccountHeadDetails({super.key, required this.accountHeadId});

//   @override
//   State<AccountHeadDetails> createState() => _AccountHeadDetailsState();
// }

// class _AccountHeadDetailsState extends State<AccountHeadDetails> {
//   bool isLoading = true;
//   AccountHeadDetailData? accountHeadDetails;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchAccountHeadDetails();
//   }

//   Future<void> fetchAccountHeadDetails() async {
//     setState(() => isLoading = true);
//     try {
//       final token = await AuthService().getAccessToken();
//       if (token == null) {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'No access token available';
//         });
//         return;
//       }

//       final response = await DioClient().dio.get(
//             '/account-heads/get_account_head/?account_head_id=${widget.accountHeadId}',
//             options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
//           );

//       if (response.statusCode == 200 && response.data['success'] == true) {
//         final accountHeadResponse =
//             AccountHeadDetailsResponse.fromJson(response.data);
//         setState(() {
//           accountHeadDetails = accountHeadResponse.data;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Failed to load details: ${response.data['message']}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = e is dio.DioError
//             ? 'Network error: ${e.message}'
//             : 'Unexpected error';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Text(errorMessage!,
//                       style: const TextStyle(color: Colors.red)))
//               : accountHeadDetails == null
//                   ? const Center(child: Text('No details available'))
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(accountHeadDetails!.name,
//                             style: const TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         _buildDetailRow(
//                             'Parent', accountHeadDetails!.parent ?? 'N/A'),
//                         _buildDetailRow('Main Group',
//                             accountHeadDetails!.mainGroup ?? 'N/A'),
//                         _buildDetailRow(
//                             'Dr/Cr', accountHeadDetails!.drCr ?? 'N/A'),
//                         _buildDetailRow('Account Type',
//                             accountHeadDetails!.accountType ?? 'N/A'),
//                         _buildDetailRow(
//                             'Opening Balance',
//                             accountHeadDetails!.openingBalance?.toString() ??
//                                 'N/A'),
//                         _buildDetailRow('Description',
//                             accountHeadDetails!.description ?? 'N/A'),
//                         _buildDetailRow(
//                             'Status',
//                             accountHeadDetails!.status == true
//                                 ? 'Active'
//                                 : 'Inactive'),
//                         _buildDetailRow(
//                           'Created On',
//                           accountHeadDetails!.createdOn != null
//                               ? DateFormat("MMMM dd, yyyy hh:mm a").format(
//                                   DateTime.parse(
//                                       accountHeadDetails!.createdOn!))
//                               : 'N/A',
//                         ),
//                         _buildDetailRow(
//                           'Updated On',
//                           accountHeadDetails!.updatedOn != null
//                               ? DateFormat("MMMM dd, yyyy hh:mm a").format(
//                                   DateTime.parse(
//                                       accountHeadDetails!.updatedOn!))
//                               : 'N/A',
//                         ),
//                       ],
//                     ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 120,
//               child: Text('$label:',
//                   style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700]))),
//           Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_details_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_details_event.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_details_state.dart';

class AccountHeadDetails extends StatelessWidget {
  final int accountHeadId;

  const AccountHeadDetails({super.key, required this.accountHeadId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountHeadDetailsBloc()..add(FetchAccountHeadDetails(accountHeadId)),
      child: BlocBuilder<AccountHeadDetailsBloc, AccountHeadDetailsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : state.accountHeadDetails == null
                        ? const Center(child: Text('No details available'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.accountHeadDetails!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow('Parent',
                                  state.accountHeadDetails!.parent ?? 'N/A'),
                              _buildDetailRow('Main Group',
                                  state.accountHeadDetails!.mainGroup ?? 'N/A'),
                              _buildDetailRow('Dr/Cr',
                                  state.accountHeadDetails!.drCr ?? 'N/A'),
                              _buildDetailRow(
                                  'Account Type',
                                  state.accountHeadDetails!.accountType ??
                                      'N/A'),
                              _buildDetailRow(
                                  'Opening Balance',
                                  state.accountHeadDetails!.openingBalance
                                          ?.toString() ??
                                      'N/A'),
                              _buildDetailRow(
                                  'Description',
                                  state.accountHeadDetails!.description ??
                                      'N/A'),
                              _buildDetailRow(
                                  'Status',
                                  state.accountHeadDetails!.status == true
                                      ? 'Active'
                                      : 'Inactive'),
                              _buildDetailRow(
                                'Created On',
                                state.accountHeadDetails!.createdOn != null
                                    ? DateFormat("MMMM dd, yyyy hh:mm a")
                                        .format(DateTime.parse(state
                                            .accountHeadDetails!.createdOn!))
                                    : 'N/A',
                              ),
                              _buildDetailRow(
                                'Updated On',
                                state.accountHeadDetails!.updatedOn != null
                                    ? DateFormat("MMMM dd, yyyy hh:mm a")
                                        .format(DateTime.parse(state
                                            .accountHeadDetails!.updatedOn!))
                                    : 'N/A',
                              ),
                            ],
                          ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
