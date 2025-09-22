
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LedgerReportScreen extends StatefulWidget {
//   const LedgerReportScreen({super.key});

//   @override
//   State<LedgerReportScreen> createState() => _LedgerReportScreenState();
// }

// class _LedgerReportScreenState extends State<LedgerReportScreen> {
//   DateTime? startDate;
//   DateTime? endDate;
//   LedgerAccount? selectedAccount;
//   List<LedgerAccount> accountList = [];
//   LedgerReport? ledgerReport;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAccounts();
//   }

//   Future<void> _fetchAccounts() async {
//     try {
//       final response = await DioClient().dio.get(
//         '/ledger/get_ledger_report/',
//         queryParameters: {'start_date': '2025-01-01', 'end_date': '2025-12-31'},
//       );
//       if (response.statusCode == 200) {
//         final data = response.data['data'] as List<dynamic>;
//         setState(() {
//           accountList = data.map((e) => LedgerAccount.fromJson(e)).toList();
//         });
//       }
//     } catch (e) {
//       print('Error fetching accounts: $e');
//     }
//   }

//   Future<void> _pickDate({required bool isStart}) async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (date != null) {
//       setState(() {
//         if (isStart) {
//           startDate = date;
//         } else {
//           endDate = date;
//         }
//       });
//     }
//   }

//   Future<void> _fetchLedger() async {
//     if (selectedAccount == null || startDate == null || endDate == null) return;

//     final response = await DioClient().dio.get(
//       '/ledger/get_ledger_report/',
//       queryParameters: {
//         'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
//         'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
//         'acc_head': selectedAccount!.accountId,
//       },
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         ledgerReport = LedgerReport.fromJson(response.data);
//       });
//     }
//   }

//   Future<void> _download(bool asPdf) async {
//     if (ledgerReport == null) return;

//     bool granted = await _requestPermission();
//     if (!granted) return;

//     if (asPdf) {
//       await DioClient().downloadAsPdf(
//         ledgerReport!,
//         DateFormat('yyyy-MM-dd').format(startDate!),
//         DateFormat('yyyy-MM-dd').format(endDate!),
//       );
//     } else {
//       await DioClient().downloadAsExcel(
//         ledgerReport!,
//         DateFormat('yyyy-MM-dd').format(startDate!),
//         DateFormat('yyyy-MM-dd').format(endDate!),
//       );
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(asPdf ? 'PDF downloaded' : 'Excel downloaded')),
//     );
//   }

//   Future<bool> _requestPermission() async {
//     if (Theme.of(context).platform == TargetPlatform.android) {
//       final status = await Permission.storage.request();
//       return status.isGranted;
//     } else if (Theme.of(context).platform == TargetPlatform.iOS) {
//       final status = await Permission.photosAddOnly.request();
//       return status.isGranted;
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ledger Report')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _pickDate(isStart: true),
//                     child: Text(startDate == null
//                         ? 'Select Start Date'
//                         : DateFormat('yyyy-MM-dd').format(startDate!)),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _pickDate(isStart: false),
//                     child: Text(endDate == null
//                         ? 'Select End Date'
//                         : DateFormat('yyyy-MM-dd').format(endDate!)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             DropdownButton<LedgerAccount>(
//               value: selectedAccount,
//               hint: const Text('Select Account'),
//               items: accountList
//                   .map((e) => DropdownMenuItem(
//                         value: e,
//                         child: Text(e.accountName ?? ''),
//                       ))
//                   .toList(),
//               onChanged: (val) => setState(() => selectedAccount = val),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _fetchLedger,
//               child: const Text('Fetch Ledger'),
//             ),
//             const SizedBox(height: 20),
//             if (ledgerReport != null)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => _download(true),
//                     child: const Text('Download PDF'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => _download(false),
//                     child: const Text('Download Excel'),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_bloc.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_event.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_state.dart';
// import 'package:saleup_app/model/ledger_report_response.dart';

// class LedgerReportScreen extends StatefulWidget {
//   const LedgerReportScreen({super.key});

//   @override
//   _LedgerReportScreenState createState() => _LedgerReportScreenState();
// }

// class _LedgerReportScreenState extends State<LedgerReportScreen> {
//   late final LedgerReportBloc _bloc;
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   String? _selectedAccHead;

//   @override
//   void initState() {
//     super.initState();
//     _bloc = LedgerReportBloc(dioClient: DioClient());
//     _bloc.add(FetchFilterOptions());
//   }

//   @override
//   void dispose() {
//     _bloc.close();
//     super.dispose();
//   }

//   Future<void> _pickDate({required bool isStart}) async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedStartDate ?? _selectedEndDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (date != null) {
//       setState(() {
//         if (isStart) {
//           _selectedStartDate = date;
//         } else {
//           _selectedEndDate = date;
//         }
//       });
//     }
//   }

//   void _clearFilter() {
//     setState(() {
//       _selectedStartDate = null;
//       _selectedEndDate = null;
//       _selectedAccHead = null;
//     });
//     _bloc.add(ClearFilterEvent()); // Use the new event
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _bloc,
//       child: Scaffold(
//         key: _bloc.navigatorKey,
//         appBar: AppBar(
//           title: const Text('Ledger Report'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 _bloc.add(FetchFilterOptions()); // Refresh account list
//               },
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Filter Section
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Filter Options',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text('Start Date'),
//                                 const SizedBox(height: 5),
//                                 ElevatedButton(
//                                   onPressed: () => _pickDate(isStart: true),
//                                   child: Text(_selectedStartDate == null
//                                       ? 'Select Start Date'
//                                       : DateFormat('yyyy-MM-dd').format(_selectedStartDate!)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text('End Date'),
//                                 const SizedBox(height: 5),
//                                 ElevatedButton(
//                                   onPressed: () => _pickDate(isStart: false),
//                                   child: Text(_selectedEndDate == null
//                                       ? 'Select End Date'
//                                       : DateFormat('yyyy-MM-dd').format(_selectedEndDate!)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Account'),
//                           const SizedBox(height: 5),
//                           BlocBuilder<LedgerReportBloc, LedgerReportState>(
//                             builder: (context, state) {
//                               List<String> accHeads = [];
//                               if (state is FilterOptionsLoaded) {
//                                 accHeads = state.accHeads;
//                                 _selectedAccHead ??= accHeads.isNotEmpty ? accHeads.first : null;
//                               }
//                               return DropdownButton<String>(
//                                 value: _selectedAccHead,
//                                 items: accHeads.map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Text(value),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     _selectedAccHead = newValue;
//                                   });
//                                 },
//                                 hint: const Text('Select Account'),
//                                 isExpanded: true,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Apply Filter and Clear Filter Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _selectedStartDate != null &&
//                             _selectedEndDate != null &&
//                             _selectedAccHead != null
//                         ? () async {
//                             final state = _bloc.state;
//                             if (state is FilterOptionsLoaded) {
//                               _bloc.add(FetchFilterOptions()); // Ensure fresh data
//                               final initialResponse = await _bloc.dioClient.dio.get(
//                                 '/ledger/get_ledger_report/',
//                                 queryParameters: {'start_date': '2025-01-01', 'end_date': '2025-12-31'},
//                               );
//                               if (initialResponse.statusCode == 200) {
//                                 final initialData = LedgerReport.fromJson(initialResponse.data);
//                                 final account = initialData.data?.firstWhere(
//                                   (acc) => acc.accountName == _selectedAccHead,
//                                   orElse: () => LedgerAccount(
//                                     accountId: 0,
//                                     accountName: '',
//                                     openingBalance: 0.0,
//                                     ledger: [],
//                                   ),
//                                 );
//                                 if (account?.accountId != null && account!.accountId != 0) {
//                                   _bloc.add(FetchAndDownloadLedgerReport(
//                                     startDate: DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
//                                     endDate: DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                                     accHead: account.accountId.toString(),
//                                   ));
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text('Invalid account selected')),
//                                   );
//                                 }
//                               }
//                             }
//                           }
//                         : null,
//                     child: const Text('Apply Filter'),
//                   ),
//                   ElevatedButton(
//                     onPressed: _clearFilter,
//                     child: const Text('Clear Filter'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               // No table display
//               if (false) // Placeholder to disable table
//                 Expanded(
//                   child: Container(),
//                 ),
//               // Download Buttons (conditional)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: BlocBuilder<LedgerReportBloc, LedgerReportState>(
//                   builder: (context, state) {
//                     if (state is LedgerReportSuccess &&
//                         state.ledgerReport.data != null &&
//                         state.ledgerReport.data!.isNotEmpty) {
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               if (state is LedgerReportSuccess) {
//                                 _bloc.dioClient.downloadAsPdf(
//                                   state.ledgerReport,
//                                   DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
//                                   DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                                 );
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('PDF downloaded successfully')),
//                                 );
//                               }
//                             },
//                             child: const Text('Download PDF'),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () {
//                               if (state is LedgerReportSuccess) {
//                                 _bloc.dioClient.downloadAsExcel(
//                                   state.ledgerReport,
//                                   DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
//                                   DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                                 );
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Excel downloaded successfully')),
//                                 );
//                               }
//                             },
//                             child: const Text('Download Excel'),
//                           ),
//                         ],
//                       );
//                     }
//                     return const SizedBox.shrink(); // Hide when no data
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_bloc.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_event.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_state.dart';
import 'package:saleup_app/model/ledger_report_response.dart';

class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({super.key});

  @override
  _LedgerReportScreenState createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends State<LedgerReportScreen> {
  late final LedgerReportBloc _bloc;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedAccHead;

  @override
  void initState() {
    super.initState();
    _bloc = LedgerReportBloc(dioClient: DioClient());
    _bloc.add(FetchFilterOptions());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _selectedStartDate = date;
        } else {
          _selectedEndDate = date;
        }
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedAccHead = null;
    });
    _bloc.add(ClearFilterEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        key: _bloc.navigatorKey,
        appBar: AppBar(
          title: const Text('Ledger Report'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _bloc.add(FetchFilterOptions());
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Date'),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () => _pickDate(isStart: true),
                                  child: Text(_selectedStartDate == null
                                      ? 'Select Start Date'
                                      : DateFormat('yyyy-MM-dd').format(_selectedStartDate!)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Date'),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () => _pickDate(isStart: false),
                                  child: Text(_selectedEndDate == null
                                      ? 'Select End Date'
                                      : DateFormat('yyyy-MM-dd').format(_selectedEndDate!)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Account'),
                          const SizedBox(height: 5),
                          BlocBuilder<LedgerReportBloc, LedgerReportState>(
                            builder: (context, state) {
                              List<String> accHeads = [];
                              if (state is FilterOptionsLoaded) {
                                accHeads = state.accHeads;
                                _selectedAccHead ??= accHeads.isNotEmpty ? accHeads.first : null;
                              }
                              return DropdownButton<String>(
                                value: _selectedAccHead,
                                items: accHeads.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedAccHead = newValue;
                                  });
                                },
                                hint: const Text('Select Account'),
                                isExpanded: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _selectedStartDate != null &&
                            _selectedEndDate != null &&
                            _selectedAccHead != null
                        ? () async {
                            final state = _bloc.state;
                            if (state is FilterOptionsLoaded) {
                              _bloc.add(FetchFilterOptions());
                              final initialResponse = await _bloc.dioClient.dio.get(
                                '/ledger/get_ledger_report/',
                                queryParameters: {'start_date': '2025-01-01', 'end_date': '2025-12-31'},
                              );
                              if (initialResponse.statusCode == 200) {
                                final initialData = LedgerReport.fromJson(initialResponse.data);
                                final account = initialData.data?.firstWhere(
                                  (acc) => acc.accountName == _selectedAccHead,
                                  orElse: () => const LedgerAccount(
                                    accountId: 0,
                                    accountName: '',
                                    openingBalance: 0.0,
                                    ledger: [],
                                  ),
                                );
                                if (account?.accountId != null && account!.accountId != 0) {
                                  _bloc.add(FetchAndDownloadLedgerReport(
                                    startDate: DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
                                    endDate: DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                                    accHead: account.accountId.toString(),
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid account selected')),
                                  );
                                }
                              }
                            }
                          }
                        : null,
                    child: const Text('Apply Filter'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFilter,
                    child: const Text('Clear Filter'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (false)
                Expanded(
                  child: Container(),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: BlocBuilder<LedgerReportBloc, LedgerReportState>(
                  builder: (context, state) {
                    if (state is LedgerReportSuccess &&
                        state.ledgerReport.data != null &&
                        state.ledgerReport.data!.isNotEmpty) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _bloc.dioClient.downloadAsPdf(
                                state.ledgerReport,
                                DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
                                DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF download initiated')),
                              );
                            },
                            child: const Text('Download PDF'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _bloc.dioClient.downloadAsExcel(
                                state.ledgerReport,
                                DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
                                DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Excel download initiated')),
                              );
                            },
                            child: const Text('Download Excel'),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}