// lib/auth/view/createCompany/screen/create_company_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/auth/view/companyCreate/bloc/create_company_bloc.dart';
import 'package:saleup_app/auth/view/companyCreate/bloc/create_company_event.dart';
import 'package:saleup_app/auth/view/companyCreate/bloc/create_company_state.dart';
import 'package:saleup_app/auth/view/companyCreate/widget/domain_field.dart';
import 'package:saleup_app/auth/view/companyCreate/widget/labeled_text_field.dart';
import 'package:saleup_app/auth/view/companyCreate/widget/trial_banner.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/navigation/app_routes.dart';

class CreateCompanyPage extends StatelessWidget {
  const CreateCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateCompanyBloc(),
      child: const _CreateCompanyView(),
    );
  }
}

class _CreateCompanyView extends StatefulWidget {
  const _CreateCompanyView();

  @override
  State<_CreateCompanyView> createState() => _CreateCompanyViewState();
}

class _CreateCompanyViewState extends State<_CreateCompanyView> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _contactController = TextEditingController();
  final _slugController = TextEditingController();
  final _domainController = TextEditingController();

  late String _paidUntil;
  final bool _onTrial = true;

  @override
  void initState() {
    super.initState();
    _companyNameController.addListener(_syncSlug);

    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    _paidUntil = DateFormat('yyyy-MM-dd').format(sevenDaysFromNow);
  }

  void _syncSlug() {
    _slugController.text = _companyNameController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-');
  }

  @override
  void dispose() {
    _companyNameController.removeListener(_syncSlug);
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _contactController.dispose();
    _slugController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateCompanyBloc>().add(
          SubmitCreateCompany(
            companyName: _companyNameController.text.trim(),
            companyAddress: _companyAddressController.text.trim(),
            companyContact: _contactController.text.trim(),
            domain: _domainController.text.trim(),
            paidUntil: _paidUntil,
            onTrial: _onTrial,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<CreateCompanyBloc, CreateCompanyState>(
      listener: (context, state) {
        if (state.isSuccess && state.createdCompany != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Company "${state.createdCompany!.displayName}" created successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // Navigate immediately — bloc is scoped to this page
          // and disposed automatically, no manual reset needed.
          context.go(AppRoutes.selectCompany);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // ── Header (background + logo + back button) ──────────────
                SizedBox(
                  height: screenHeight * 0.4,
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/login_bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Logo
                      Positioned(
                        top: screenHeight * 0.05,
                        left: 10,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/Logo.png',
                            height: screenHeight * 0.11,
                          ),
                        ),
                      ),

                      // Back button
                      Positioned(
                        top: 10,
                        left: 1,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/images/back_button_logo.png',
                            width: 60,
                            height: 60,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form content ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Add Company header image
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Image.asset(
                            'assets/images/add_company.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Company Name ──────────────────────────────────
                        LabeledTextField(
                          label: 'Company Name:',
                          hint: 'e.g. Himalayan Traders',
                          controller: _companyNameController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Company Address ───────────────────────────────
                        LabeledTextField(
                          label: 'Company Address:',
                          hint: 'e.g. Kathmandu, Nepal',
                          controller: _companyAddressController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Contact Number ────────────────────────────────
                        LabeledTextField(
                          label: 'Contact Number:',
                          hint: 'e.g. +977-9800000000',
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Slug (read-only, auto-generated) ──────────────
                        LabeledTextField(
                          label: 'Slug (schema & name — auto-generated):',
                          controller: _slugController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),

                        // ── Domain ────────────────────────────────────────
                        DomainField(
                          controller: _domainController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // ── Trial Banner ──────────────────────────────────
                        const TrialBanner(),
                        const SizedBox(height: 20),

                        // ── Submit Button ─────────────────────────────────
                        BlocBuilder<CreateCompanyBloc, CreateCompanyState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFF97316).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Create Company',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
