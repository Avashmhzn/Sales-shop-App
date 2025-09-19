import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_bloc.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_event.dart';
import 'package:saleup_app/screen/ledger/bloc/ledger_report_state.dart';

class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({super.key});

  @override
  _LedgerReportScreenState createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends State<LedgerReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController(text: '2025-06-30');
  final _endDateController = TextEditingController(text: '2025-07-30');
  final _accHeadController = TextEditingController(text: '218');
  late final LedgerReportBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LedgerReportBloc(dioClient: DioClient());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _accHeadController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        key: _bloc.navigatorKey,
        appBar: AppBar(
          title: const Text('Ledger Report'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start date';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Please enter a valid date (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an end date';
                    }
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Please enter a valid date (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accHeadController,
                  decoration: const InputDecoration(labelText: 'Account Head'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an account head';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<LedgerReportBloc, LedgerReportState>(
                  builder: (context, state) {
                    if (state is LedgerReportLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is LedgerReportFailure) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage)),
                        );
                      });
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _bloc.add(FetchAndDownloadLedgerReport(
                            startDate: _startDateController.text,
                            endDate: _endDateController.text,
                            accHead: _accHeadController.text,
                          ));
                        }
                      },
                      child: const Text('Download Report'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}