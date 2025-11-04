// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/account_heads_response.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_bloc.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_event.dart';
// import 'package:saleup_app/screen/ledger/bloc/ledger_report_state.dart';

// class LedgerReportScreen extends StatefulWidget {
//   const LedgerReportScreen({super.key});
//   @override
//   State<LedgerReportScreen> createState() => _LedgerReportScreenState();
// }

// class _LedgerReportScreenState extends State<LedgerReportScreen> {
//   late final LedgerReportBloc _bloc;
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   AccountHeadData? _selectedAccount;
//   bool _dialogShown = false;

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

//   // FIXED: Clear only selections, NOT the account list
//   void _clearFilter() {
//     setState(() {
//       _selectedStartDate = null;
//       _selectedEndDate = null;
//       _selectedAccount = null; // Only selection cleared
//       _dialogShown = false;
//     });
//     // DO NOT emit ClearFilterEvent() → it resets the account list!
//   }

//   void _applyFilter() {
//     if (_selectedStartDate == null ||
//         _selectedEndDate == null ||
//         _selectedAccount == null) {
//       return;
//     }
//     _dialogShown = false;
//     _bloc.add(FetchAndDownloadLedgerReport(
//       startDate: DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
//       endDate: DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//       accHeadId: _selectedAccount!.id,
//     ));
//   }

//   Future<void> _download(String type, Future<void> Function() fn) async {
//     try {
//       await fn();
//       final dir = Platform.isAndroid
//           ? (await getDownloadsDirectory()) ??
//               await getApplicationDocumentsDirectory()
//           : await getApplicationDocumentsDirectory();
//       final ext = type == 'PDF' ? 'pdf' : 'csv';
//       final path =
//           '${dir.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.$ext';

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('$type saved: $path')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to download $type')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => _bloc,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Ledger Report'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () => _bloc.add(FetchFilterOptions()),
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // FILTER CARD
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Filter Options',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),

//                       // START & END DATE
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
//                                   child: Text(
//                                     _selectedStartDate == null
//                                         ? 'Select Start Date'
//                                         : DateFormat('yyyy-MM-dd')
//                                             .format(_selectedStartDate!),
//                                   ),
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
//                                   child: Text(
//                                     _selectedEndDate == null
//                                         ? 'Select End Date'
//                                         : DateFormat('yyyy-MM-dd')
//                                             .format(_selectedEndDate!),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),

//                       // ACCOUNT DROPDOWN – ALWAYS SHOWS AFTER LOADED
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Account Heads'),
//                           const SizedBox(height: 5),
//                           BlocBuilder<LedgerReportBloc, LedgerReportState>(
//                             builder: (context, state) {
//                               // SHOW LOADING TEXT ONLY ONCE
//                               if (state is LedgerReportInitial ||
//                                   state is LedgerReportLoading) {
//                                 return const SizedBox(
//                                   height: 56,
//                                   child: Center(
//                                       child: Text('Loading accounts...')),
//                                 );
//                               }

//                               // SHOW DROPDOWN IF ACCOUNTS LOADED
//                               if (state is FilterOptionsLoaded) {
//                                 final accounts = state.accountHeads;
//                                 if (accounts.isEmpty) {
//                                   return const SizedBox(
//                                     height: 56,
//                                     child: Center(
//                                         child: Text(
//                                             'No accounts heads available')),
//                                   );
//                                 }

//                                 // Auto-select first if none selected
//                                 if (_selectedAccount == null) {
//                                   _selectedAccount = accounts.first;
//                                 }

//                                 final valid = accounts.firstWhere(
//                                   (a) => a.id == _selectedAccount?.id,
//                                   orElse: () => accounts.first,
//                                 );

//                                 return DropdownButtonFormField<AccountHeadData>(
//                                   value: valid,
//                                   decoration: const InputDecoration(
//                                     border: OutlineInputBorder(),
//                                     contentPadding: EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 8),
//                                   ),
//                                   hint: const Text('Select Account Head'),
//                                   isExpanded: true,
//                                   items: accounts
//                                       .map((a) => DropdownMenuItem(
//                                           value: a, child: Text(a.name)))
//                                       .toList(),
//                                   onChanged: (v) =>
//                                       setState(() => _selectedAccount = v),
//                                 );
//                               }

//                               // SHOW ERROR WITH RETRY
//                               if (state is LedgerReportFailure) {
//                                 return SizedBox(
//                                   height: 56,
//                                   child: Center(
//                                     child: TextButton.icon(
//                                       icon: const Icon(Icons.refresh),
//                                       label: Text(state.errorMessage),
//                                       onPressed: () =>
//                                           _bloc.add(FetchFilterOptions()),
//                                     ),
//                                   ),
//                                 );
//                               }

//                               // FALLBACK
//                               return const SizedBox.shrink();
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // APPLY & CLEAR BUTTONS
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: (_selectedStartDate != null &&
//                             _selectedEndDate != null &&
//                             _selectedAccount != null)
//                         ? _applyFilter
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

//               // DIALOG + DOWNLOAD BUTTONS
//               BlocConsumer<LedgerReportBloc, LedgerReportState>(
//                 listenWhen: (prev, curr) =>
//                     curr is LedgerReportSuccess &&
//                     prev is! LedgerReportSuccess &&
//                     !_dialogShown,
//                 listener: (context, state) {
//                   if (state is LedgerReportSuccess) {
//                     _dialogShown = true;
//                     Future.microtask(() {
//                       if (!mounted) return;
//                       showDialog(
//                         context: context,
//                         useRootNavigator: false, // Safe with go_router
//                         builder: (_) => AlertDialog(
//                           title: const Text('Download'),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                   _download(
//                                     'PDF',
//                                     () => _bloc.dioClient.downloadAsPdf(
//                                       state.ledgerReport,
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(_selectedStartDate!),
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(_selectedEndDate!),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text('Download PDF'),
//                               ),
//                               const SizedBox(height: 8),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                   _download(
//                                     'Excel',
//                                     () => _bloc.dioClient.downloadAsExcel(
//                                       state.ledgerReport,
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(_selectedStartDate!),
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(_selectedEndDate!),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text('Download Excel'),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ).then((_) => _dialogShown = false);
//                     });
//                   }
//                 },
//                 builder: (context, state) {
//                   if (state is LedgerReportSuccess &&
//                       state.ledgerReport.data?.isNotEmpty == true) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () => _download(
//                               'PDF',
//                               () => _bloc.dioClient.downloadAsPdf(
//                                 state.ledgerReport,
//                                 DateFormat('yyyy-MM-dd')
//                                     .format(_selectedStartDate!),
//                                 DateFormat('yyyy-MM-dd')
//                                     .format(_selectedEndDate!),
//                               ),
//                             ),
//                             child: const Text('PDF'),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () => _download(
//                               'Excel',
//                               () => _bloc.dioClient.downloadAsExcel(
//                                 state.ledgerReport,
//                                 DateFormat('yyyy-MM-dd')
//                                     .format(_selectedStartDate!),
//                                 DateFormat('yyyy-MM-dd')
//                                     .format(_selectedEndDate!),
//                               ),
//                             ),
//                             child: const Text('Excel'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screen/ledger/ledger_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_bloc.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_event.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_state.dart';

class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({super.key});
  @override
  State<LedgerReportScreen> createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends State<LedgerReportScreen> {
  late final LedgerReportBloc _bloc;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  AccountHeadData? _selectedAccount;
  bool _dialogShown = false;

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

  // Clear only selections
  void _clearFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedAccount = null; // This will show "Select Account Head"
      _dialogShown = false;
    });
  }

  void _applyFilter() {
    if (_selectedStartDate == null ||
        _selectedEndDate == null ||
        _selectedAccount == null) {
      return;
    }
    _dialogShown = false;
    _bloc.add(FetchAndDownloadLedgerReport(
      startDate: DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
      accHeadId: _selectedAccount!.id,
    ));
  }

  Future<void> _download(String type, Future<void> Function() fn) async {
    try {
      await fn();
      final dir = Platform.isAndroid
          ? (await getDownloadsDirectory()) ??
              await getApplicationDocumentsDirectory()
          : await getApplicationDocumentsDirectory();
      final ext = type == 'PDF' ? 'pdf' : 'csv';
      final path =
          '${dir.path}/ledger_report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.$ext';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type saved: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download $type')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ledger Report'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _bloc.add(FetchFilterOptions()),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FILTER CARD
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // START & END DATE
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
                                  child: Text(
                                    _selectedStartDate == null
                                        ? 'Select Start Date'
                                        : DateFormat('yyyy-MM-dd')
                                            .format(_selectedStartDate!),
                                  ),
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
                                  child: Text(
                                    _selectedEndDate == null
                                        ? 'Select End Date'
                                        : DateFormat('yyyy-MM-dd')
                                            .format(_selectedEndDate!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ACCOUNT DROPDOWN – SHOWS "Select Account Head" FIRST
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Account Heads'),
                          const SizedBox(height: 5),
                          BlocBuilder<LedgerReportBloc, LedgerReportState>(
                            builder: (context, state) {
                              // Loading
                              if (state is LedgerReportInitial ||
                                  state is LedgerReportLoading) {
                                return const SizedBox(
                                  height: 56,
                                  child: Center(
                                      child: Text('Loading accounts...')),
                                );
                              }

                              // Loaded
                              if (state is FilterOptionsLoaded) {
                                final accounts = state.accountHeads;
                                if (accounts.isEmpty) {
                                  return const SizedBox(
                                    height: 56,
                                    child: Center(
                                        child:
                                            Text('No account heads available')),
                                  );
                                }

                                return DropdownButtonFormField<AccountHeadData>(
                                  initialValue:
                                      _selectedAccount, // null = show hint
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  hint: const Text(
                                      'Select Account Head'), // Shows when null
                                  isExpanded: true,
                                  items: accounts
                                      .map((a) => DropdownMenuItem(
                                          value: a, child: Text(a.name)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedAccount = v),
                                );
                              }

                              // Error
                              if (state is LedgerReportFailure) {
                                return SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      label: Text(state.errorMessage),
                                      onPressed: () =>
                                          _bloc.add(FetchFilterOptions()),
                                    ),
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: (_selectedStartDate != null &&
                            _selectedEndDate != null &&
                            _selectedAccount != null)
                        ? _applyFilter
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

              // DIALOG + DOWNLOAD
              BlocConsumer<LedgerReportBloc, LedgerReportState>(
                listenWhen: (prev, curr) =>
                    curr is LedgerReportSuccess &&
                    prev is! LedgerReportSuccess &&
                    !_dialogShown,
                listener: (context, state) {
                  if (state is LedgerReportSuccess) {
                    _dialogShown = true;
                    Future.microtask(() {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (_) => AlertDialog(
                          title: const Text('Download'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _download(
                                    'PDF',
                                    () => _bloc.dioClient.downloadAsPdf(
                                      state.ledgerReport,
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedStartDate!),
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedEndDate!),
                                    ),
                                  );
                                },
                                child: const Text('Download PDF'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _download(
                                    'Excel',
                                    () => _bloc.dioClient.downloadAsExcel(
                                      state.ledgerReport,
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedStartDate!),
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedEndDate!),
                                    ),
                                  );
                                },
                                child: const Text('Download Excel'),
                              ),
                            ],
                          ),
                        ),
                      ).then((_) => _dialogShown = false);
                    });
                  }
                },
                builder: (context, state) {
                  if (state is LedgerReportSuccess &&
                      state.ledgerReport.data?.isNotEmpty == true) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _download(
                              'PDF',
                              () => _bloc.dioClient.downloadAsPdf(
                                state.ledgerReport,
                                DateFormat('yyyy-MM-dd')
                                    .format(_selectedStartDate!),
                                DateFormat('yyyy-MM-dd')
                                    .format(_selectedEndDate!),
                              ),
                            ),
                            child: const Text('PDF'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _download(
                              'Excel',
                              () => _bloc.dioClient.downloadAsExcel(
                                state.ledgerReport,
                                DateFormat('yyyy-MM-dd')
                                    .format(_selectedStartDate!),
                                DateFormat('yyyy-MM-dd')
                                    .format(_selectedEndDate!),
                              ),
                            ),
                            child: const Text('Excel'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
