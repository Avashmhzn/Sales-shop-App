import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/dayClosing/bloc/day_closing_bloc.dart';
import 'package:saleup_app/screen/dayClosing/bloc/day_closing_event.dart';
import 'package:saleup_app/screen/dayClosing/bloc/day_closing_state.dart';
import 'package:saleup_app/screen/dayClosing/model/day_closing_model.dart';

class DayClosing extends StatelessWidget {
  const DayClosing({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DayClosingBloc()..add(const FetchDayData()),
      child: const _DayClosingBody(),
    );
  }
}

class _DayClosingBody extends StatelessWidget {
  const _DayClosingBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DayClosingBloc, DayClosingState>(
      listener: (context, state) {
        if (state is DayCloseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DayOpenSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DayClosingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DayClosingBloc>().add(const FetchDayData());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card ──────────────────────────────────
                _buildHeaderCard(context),
                const SizedBox(height: 24),
                // ── Summary Items ────────────────────────────────
                BlocBuilder<DayClosingBloc, DayClosingState>(
                  builder: (context, state) {
                    final DayClosingTotals totals;
                    if (state is DayClosingLoaded) {
                      totals = state.dayData.totals;
                    } else {
                      totals = const DayClosingTotals();
                    }

                    if (state is DayClosingLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE8590C)),
                        ),
                      );
                    }

                    if (state is DayClosingNoDayOpen) {
                      return Column(
                        children: [
                          _buildNoDataPlaceholder(),
                          const SizedBox(height: 32),
                          _buildActionButton(context, state),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildSummaryGrid(totals),
                        const SizedBox(height: 24),
                        _buildTotalCard(totals.total),
                        const SizedBox(height: 32),
                        _buildActionButton(context, state),
                      ],
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

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<DayClosingBloc, DayClosingState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Day Closing Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(state),
                ],
              ),
              const SizedBox(height: 12),
              if (state is DayClosingLoaded) ...[
                Text(
                  'Date: ${state.dayData.date}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(DayClosingState state) {
    if (state is DayClosingLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is DayClosingLoaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
            SizedBox(width: 6),
            Text(
              'Day Open',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (state is DayClosingNoDayOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: Color(0xFFFF9800)),
            SizedBox(width: 6),
            Text(
              'No day data',
              style: TextStyle(
                color: Color(0xFFFF9800),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton(BuildContext context, DayClosingState state) {
    if (state is DayClosingLoading) {
      return const SizedBox.shrink();
    }

    if (state is DayClosingLoaded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showConfirmDialog(
            context,
            title: 'Close Day',
            message:
                'Are you sure you want to close the day for ${state.dayData.date}?',
            onConfirm: () {
              context.read<DayClosingBloc>().add(const CloseDay());
            },
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8590C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Day Close',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (state is DayClosingNoDayOpen) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showConfirmDialog(
            context,
            title: 'Open Day',
            message: 'Are you sure you want to open a new day?',
            onConfirm: () {
              context.read<DayClosingBloc>().add(const OpenDay());
            },
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Open Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSummaryGrid(DayClosingTotals totals) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _summaryCard('Cash', totals.cash, Icons.payments_rounded,
            const Color(0xFF4CAF50)),
        _summaryCard('Cheque/Bank', totals.bank, Icons.account_balance_rounded,
            const Color(0xFF2196F3)),
        _summaryCard('Online', totals.fonepay, Icons.qr_code_scanner_rounded,
            const Color(0xFF9C27B0)),
        _summaryCard('Credit', totals.credit, Icons.credit_card_rounded,
            const Color(0xFFF44336)),
      ],
    );
  }

  Widget _summaryCard(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${_formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8590C), Color(0xFFFF922B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8590C).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Collection',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${_formatAmount(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No open day found',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a day to see the collection summary here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8590C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
