// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/setting/bloc/profile_bloc.dart';
// import 'package:saleup_app/screen/setting/bloc/profile_event.dart';
// import 'package:saleup_app/screen/setting/bloc/profile_state.dart';
// import 'package:saleup_app/screen/setting/model/profile.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final _companyName = TextEditingController();
//   final _tagline = TextEditingController();
//   final _address = TextEditingController();
//   final _contactNumber = TextEditingController();
//   final _panNumber = TextEditingController();
//   final _openingHour = TextEditingController();
//   final _establishedYear = TextEditingController();
//   final _taxPercent = TextEditingController();

//   String? _selectedManager;

//   @override
//   void initState() {
//     super.initState();
//     // Events are dispatched via BlocProvider in router → no need to call here
//   }

//   @override
//   void dispose() {
//     _companyName.dispose();
//     _tagline.dispose();
//     _address.dispose();
//     _contactNumber.dispose();
//     _panNumber.dispose();
//     _openingHour.dispose();
//     _establishedYear.dispose();
//     _taxPercent.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       final profile = Profile(
//         companyName: _companyName.text.trim(),
//         tagline: _tagline.text.trim(),
//         address: _address.text.trim(),
//         contactNumber: _contactNumber.text.trim(),
//         panNumber: _panNumber.text.trim(),
//         openingHour: _openingHour.text.trim(),
//         establishedYear: _establishedYear.text.trim(),
//         taxPercent: double.tryParse(_taxPercent.text.trim()),
//         manager: _selectedManager,
//       );

//       context.read<ProfileBloc>().add(CreateProfile(profile));
//     }
//   }

//   void _clearForm() {
//     _companyName.clear();
//     _tagline.clear();
//     _address.clear();
//     _contactNumber.clear();
//     _panNumber.clear();
//     _openingHour.clear();
//     _establishedYear.clear();
//     _taxPercent.clear();
//     setState(() => _selectedManager = null);
//   }

//   Future<void> _confirmAndDelete(int profileId, String? companyName) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Profile'),
//         content: Text(
//           'Are you sure you want to delete "${companyName ?? "this profile"}"?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       context.read<ProfileBloc>().add(DeleteProfile(profileId));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ProfileBloc, ProfileState>(
//       listener: (context, state) {
//         if (state is ProfileCreated) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile created successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           _clearForm();
//           // Optional: reload list immediately
//           context.read<ProfileBloc>().add(const LoadProfile());
//         }

//         if (state is ProfileDeleted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile deleted successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           // List auto-refreshes because Bloc already calls LoadProfile on success
//         }

//         if (state is ProfileError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         final isLoading = state is ProfileLoading ||
//             state is ManagersLoading ||
//             state is ProfileCreating ||
//             state is ProfileDeleting;

//         final profiles = state is ProfileLoaded ? state.profiles : <Profile>[];
//         final managers = state is ProfileLoaded ? state.managers : <String>[];

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Settings'),
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//           ),
//           body: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : RefreshIndicator(
//                   onRefresh: () async {
//                     context.read<ProfileBloc>()
//                       ..add(const LoadProfile())
//                       ..add(const LoadManagers());
//                   },
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Configure and update your profile information.',
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 32),

//                           // Responsive layout (already fixed with IntrinsicHeight)
//                           LayoutBuilder(
//                             builder: (context, constraints) {
//                               final isWide = constraints.maxWidth > 700;

//                               return IntrinsicHeight(
//                                 child: Flex(
//                                   direction:
//                                       isWide ? Axis.horizontal : Axis.vertical,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           _buildField(
//                                               'Company Name', _companyName,
//                                               isRequired: true),
//                                           _buildField('Tagline', _tagline),
//                                           _buildField('Address', _address,
//                                               isRequired: true),
//                                           _buildField(
//                                               'Contact Number', _contactNumber,
//                                               isRequired: true,
//                                               keyboardType:
//                                                   TextInputType.phone),
//                                           _buildField('PAN Number', _panNumber,
//                                               isRequired: true),
//                                         ],
//                                       ),
//                                     ),
//                                     if (isWide) const SizedBox(width: 32),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           _buildDropdown(
//                                             'Manager',
//                                             _selectedManager,
//                                             managers,
//                                             (v) => setState(
//                                                 () => _selectedManager = v),
//                                             isRequired: true,
//                                           ),
//                                           _buildField(
//                                               'Opening Hour', _openingHour,
//                                               hint: 'e.g. 09:00 AM'),
//                                           _buildField('Established Year',
//                                               _establishedYear,
//                                               keyboardType:
//                                                   TextInputType.number),
//                                           _buildField(
//                                               'Tax Percent', _taxPercent,
//                                               keyboardType:
//                                                   TextInputType.number,
//                                               isRequired: true),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),

//                           const SizedBox(height: 32),

//                           SizedBox(
//                             width: double.infinity,
//                             height: 54,
//                             child: ElevatedButton(
//                               onPressed:
//                                   state is ProfileCreating ? null : _submit,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFF59422),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12)),
//                               ),
//                               child: state is ProfileCreating
//                                   ? const SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Create Profile',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                             ),
//                           ),

//                           const SizedBox(height: 40),

//                           if (profiles.isNotEmpty) ...[
//                             const Text(
//                               'Existing Profiles',
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 16),
//                             ...profiles.map(
//                               (p) => Card(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 child: ListTile(
//                                   leading: const Icon(Icons.business,
//                                       color: Color(0xFFF59422)),
//                                   title: Text(
//                                     p.companyName ?? 'Unnamed Company',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                   subtitle: Text(
//                                     'Manager: ${p.manager ?? "Not assigned"} • PAN: ${p.panNumber ?? "N/A"}',
//                                   ),
//                                   trailing: IconButton(
//                                     icon: const Icon(
//                                       Icons.delete_forever,
//                                       color: Colors.red,
//                                       size: 28,
//                                     ),
//                                     tooltip: 'Delete this profile',
//                                     onPressed: p.id != null
//                                         ? () => _confirmAndDelete(
//                                               p.id!,
//                                               p.companyName,
//                                             )
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ] else ...[
//                             const SizedBox(height: 20),
//                             const Center(
//                               child: Text(
//                                 'No profiles created yet',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//         );
//       },
//     );
//   }

//   Widget _buildField(
//     String label,
//     TextEditingController controller, {
//     String? hint,
//     TextInputType? keyboardType,
//     bool isRequired = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             isRequired ? '* $label:' : '$label:',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             decoration: InputDecoration(
//               hintText: hint ?? 'Enter $label',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//             validator: isRequired
//                 ? (v) =>
//                     v == null || v.trim().isEmpty ? '$label is required' : null
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown(
//     String label,
//     String? value,
//     List<String> options,
//     void Function(String?) onChanged, {
//     bool isRequired = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             isRequired ? '* $label:' : '$label:',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             initialValue: value,
//             isExpanded: true,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//             hint: Text('Select $label'),
//             items: options
//                 .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//                 .toList(),
//             onChanged: onChanged,
//             validator: isRequired
//                 ? (v) => v == null ? '$label is required' : null
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/setting/bloc/profile_bloc.dart';
import 'package:saleup_app/screen/setting/bloc/profile_event.dart';
import 'package:saleup_app/screen/setting/bloc/profile_state.dart';
import 'package:saleup_app/screen/setting/model/profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _companyName = TextEditingController();
  final _tagline = TextEditingController();
  final _address = TextEditingController();
  final _contactNumber = TextEditingController();
  final _panNumber = TextEditingController();
  final _openingHour = TextEditingController();
  final _taxPercent = TextEditingController();

  String? _selectedManager;
  DateTime? _selectedEstablishedDate;
  int? _editingProfileId; // null = create, non-null = update

  bool get _isUpdateMode => _editingProfileId != null;

  @override
  void dispose() {
    _companyName.dispose();
    _tagline.dispose();
    _address.dispose();
    _contactNumber.dispose();
    _panNumber.dispose();
    _openingHour.dispose();
    _taxPercent.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final profile = Profile(
        id: _editingProfileId,
        companyName: _companyName.text.trim(),
        tagline: _tagline.text.trim(),
        address: _address.text.trim(),
        contactNumber: _contactNumber.text.trim(),
        panNumber: _panNumber.text.trim(),
        openingHour: _openingHour.text.trim(),
        establishedYear: _selectedEstablishedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedEstablishedDate!)
            : null,
        taxPercent: double.tryParse(_taxPercent.text.trim()),
        manager: _selectedManager,
      );

      if (_isUpdateMode) {
        context.read<ProfileBloc>().add(UpdateProfile(profile));
      } else {
        context.read<ProfileBloc>().add(CreateProfile(profile));
      }
    }
  }

  void _fillFormForEdit(Profile profile) {
    setState(() {
      _editingProfileId = profile.id;
      _companyName.text = profile.companyName ?? '';
      _tagline.text = profile.tagline ?? '';
      _address.text = profile.address ?? '';
      _contactNumber.text = profile.contactNumber ?? '';
      _panNumber.text = profile.panNumber ?? '';
      _openingHour.text = profile.openingHour ?? '';
      _taxPercent.text = profile.taxPercent?.toString() ?? '';
      _selectedManager = profile.manager;
      _selectedEstablishedDate = profile.establishedYear != null
          ? DateTime.tryParse(profile.establishedYear!)
          : null;
    });
  }

  void _clearForm() {
    setState(() {
      _editingProfileId = null;
      _companyName.clear();
      _tagline.clear();
      _address.clear();
      _contactNumber.clear();
      _panNumber.clear();
      _openingHour.clear();
      _taxPercent.clear();
      _selectedManager = null;
      _selectedEstablishedDate = null;
    });
  }

  Future<void> _pickEstablishedDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEstablishedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Select Established Date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEstablishedDate = selectedDate;
      });
    }
  }

  String _getFormattedEstablishedDate() {
    if (_selectedEstablishedDate == null) return '';
    return DateFormat('yyyy-MM-dd').format(_selectedEstablishedDate!);
  }

  Future<void> _confirmAndDelete(int profileId, String? companyName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
            'Are you sure you want to delete "${companyName ?? "this profile"}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ProfileBloc>().add(DeleteProfile(profileId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileCreated || state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile saved successfully'),
                backgroundColor: Colors.green),
          );
          _clearForm();
          context.read<ProfileBloc>().add(const LoadProfile());
        }
        if (state is ProfileDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile deleted successfully'),
                backgroundColor: Colors.green),
          );
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading ||
            state is ManagersLoading ||
            state is ProfileCreating ||
            state is ProfileDeleting;

        final profiles = state is ProfileLoaded ? state.profiles : <Profile>[];
        final managers = state is ProfileLoaded ? state.managers : <String>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              if (profiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Delete Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Optional: delete all or first profile - adjust as needed
                      if (profiles.isNotEmpty && profiles.first.id != null) {
                        _confirmAndDelete(
                            profiles.first.id!, profiles.first.companyName);
                      }
                    },
                  ),
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>()
                      ..add(const LoadProfile())
                      ..add(const LoadManagers());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configure and update your profile information.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;

                              return IntrinsicHeight(
                                child: Flex(
                                  direction:
                                      isWide ? Axis.horizontal : Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildField(
                                              'Company Name', _companyName,
                                              isRequired: true),
                                          _buildField('Tagline', _tagline),
                                          _buildField('Address', _address,
                                              isRequired: true),
                                          _buildField(
                                            'Contact Number',
                                            _contactNumber,
                                            isRequired: true,
                                            keyboardType: TextInputType.phone,
                                          ),
                                          _buildField('PAN Number', _panNumber,
                                              isRequired: true),
                                        ],
                                      ),
                                    ),
                                    if (isWide) const SizedBox(width: 32),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDropdown(
                                            'Manager',
                                            _selectedManager,
                                            managers,
                                            (v) => setState(
                                                () => _selectedManager = v),
                                            isRequired: true,
                                          ),
                                          _buildField(
                                              'Opening Hour', _openingHour,
                                              hint: 'e.g. 09:00 AM'),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '* Established Year:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 8),
                                                InkWell(
                                                  onTap: _pickEstablishedDate,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: InputDecorator(
                                                    decoration: InputDecoration(
                                                      hintText: 'Select date',
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                      filled: true,
                                                      fillColor:
                                                          Colors.grey[50],
                                                      suffixIcon: const Icon(
                                                          Icons.calendar_today),
                                                      errorText:
                                                          _selectedEstablishedDate ==
                                                                  null
                                                              ? 'Required'
                                                              : null,
                                                    ),
                                                    child: Text(
                                                      _selectedEstablishedDate !=
                                                              null
                                                          ? _getFormattedEstablishedDate()
                                                          : 'Tap to select date',
                                                      style: TextStyle(
                                                        color:
                                                            _selectedEstablishedDate ==
                                                                    null
                                                                ? Colors.grey
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildField(
                                            'Tax Percent',
                                            _taxPercent,
                                            keyboardType: TextInputType.number,
                                            isRequired: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  state is ProfileCreating ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59422),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: state is ProfileCreating
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isUpdateMode
                                          ? 'Update Profile'
                                          : 'Create Profile',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          if (_isUpdateMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: _clearForm,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancel Edit',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),
                          if (profiles.isNotEmpty) ...[
                            const Text(
                              'Existing Profiles',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ...profiles.map(
                              (p) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const Icon(Icons.business,
                                      color: Color(0xFFF59422)),
                                  title: Text(
                                    p.companyName ?? 'Unnamed Company',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Manager: ${p.manager ?? "Not assigned"} • PAN: ${p.panNumber ?? "N/A"}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        tooltip: 'Edit Profile',
                                        onPressed: () => _fillFormForEdit(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever,
                                            color: Colors.red, size: 28),
                                        tooltip: 'Delete Profile',
                                        onPressed: p.id != null
                                            ? () => _confirmAndDelete(
                                                p.id!, p.companyName)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                'No profiles created yet',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequired ? '* $label:' : '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: isRequired
                ? (v) =>
                    v == null || v.trim().isEmpty ? '$label is required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequired ? '* $label:' : '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            hint: Text('Select $label'),
            items: options
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged:
                _isUpdateMode ? null : onChanged, // Disable during update
            validator: isRequired
                ? (v) => v == null ? '$label is required' : null
                : null,
          ),
        ],
      ),
    );
  }
}
