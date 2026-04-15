// lib/screens/profile/saved_addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:food_delivery_app/widgets/common_textform_field.dart';

import '../../utils/sharedpreference_helper.dart';

class AddressModel {
  final int? id;
  final String addressType;
  final String fullAddress;
  final String landmark;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? createdAt;

  AddressModel({
    this.id,
    required this.addressType,
    required this.fullAddress,
    required this.landmark,
    required this.pincode,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'],
        addressType: json['address_type'] ?? 'home',
        fullAddress: json['full_address'] ?? '',
        landmark: json['landmark'] ?? '',
        pincode: json['pincode'] ?? '',
        latitude: json['latitude'] != null
            ? double.tryParse(json['latitude'].toString())
            : null,
        longitude: json['longitude'] != null
            ? double.tryParse(json['longitude'].toString())
            : null,
        isDefault: json['is_default'] ?? false,
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'address_type': addressType,
        'full_address': fullAddress,
        'landmark': landmark,
        'pincode': pincode,
        'latitude': latitude,
        // hardcoded for now, dynamic once map integrated
        'longitude': longitude,
        // hardcoded for now, dynamic once map integrated
        'is_default': isDefault,
      };

  AddressModel copyWith({
    int? id,
    String? addressType,
    String? fullAddress,
    String? landmark,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? createdAt,
  }) =>
      AddressModel(
        id: id ?? this.id,
        addressType: addressType ?? this.addressType,
        fullAddress: fullAddress ?? this.fullAddress,
        landmark: landmark ?? this.landmark,
        pincode: pincode ?? this.pincode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
}

// ── Hardcoded lat/lng until map integration ──────────────────────────────────
const double kDefaultLatitude = 9.9252; // TODO: replace with map picker value
const double kDefaultLongitude = 78.1198; // TODO: replace with map picker value

// ── Design tokens ─────────────────────────────────────────────────────────────
const _primary = Color(0xFFFF6B35);
final _surface = Colors.grey.shade50;
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF757575);
const _divider = Color(0xFFF0EDE8);
const _danger = Color(0xFFE53935);

// ─────────────────────────────────────────────────────────────────────────────
// ADDRESS LIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<SavedAddressesScreen> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  bool load = false;
  String? _error;
  final apiService = ApiService();

  Future<List<AddressModel>> getAddresses() async {
    final data = await apiService.getSavedAddress();
    final list = data['data'] as List; // adjust key if needed
    print(data);
    return list.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<dynamic> deleteAddress(int id) async {
    final data = await apiService.deleteAddress(id);

    return data;
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await getAddresses();

      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address',
            style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
        content: const Text('Are you sure you want to delete this address?',
            style: TextStyle(color: _textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: _danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        load = true;
      });
      await deleteAddress(address.id!);
      setState(() {
        load = false;

        _addresses.removeWhere((a) => a.id == address.id);
      });
      if (mounted) {
        _showSnackBar('Address deleted');
      }
    } catch (e) {
      _showSnackBar('Failed to delete address', isError: true);
    }
  }

  Future<void> _openAddressForm({AddressModel? address}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(existingAddress: address),
      ),
    );
    if (result == true) _loadAddresses();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _danger : _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _addresses.isNotEmpty,
      child: Scaffold(
        backgroundColor: _surface,
        appBar: AppBar(
          backgroundColor: _surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          leading: _addresses.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: _textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
          title: const Text(
            'My Addresses',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddressForm(),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Address',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
          child: AppDefaultLoader(
        color: _primary,
        loading: _isLoading,
      ));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Something went wrong',
                style: TextStyle(
                    color: _textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAddresses,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: _primary, size: 38),
            ),
            const SizedBox(height: 16),
            const Text('No addresses yet',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Add your first delivery address',
                style: TextStyle(color: _textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: _primary,
          onRefresh: _loadAddresses,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: _addresses.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () async {
                if (_addresses[i].isDefault == false) {
                  setState(() {
                    load = true;
                  });
                  final body = AddressModel(
                    id: _addresses[i].id,
                    addressType: _addresses[i].addressType,
                    fullAddress: _addresses[i].fullAddress,
                    landmark: _addresses[i].landmark,
                    pincode: _addresses[i].pincode,
                    latitude: kDefaultLatitude,
                    // TODO: replace with map picker
                    longitude: kDefaultLongitude,
                    // TODO: replace with map picker
                    isDefault: _addresses[i].isDefault == false ? true : false,
                  ).toJson();
                  await apiService.updateNewAddress(_addresses[i].id, body);
                  final list = await getAddresses();
                  final res = await apiService.getProfile();
                  SharedPreferenceHelper.setUserObject(res);
                  setState(() {
                    _addresses = list;
                    load = false;
                  });
                }
              },
              child: _AddressCard(
                address: _addresses[i],
                onEdit: () => _openAddressForm(address: _addresses[i]),
                onDelete: () => _deleteAddress(_addresses[i]),
              ),
            ),
          ),
        ),
        if (load)
          Center(
            child: AppDefaultLoader(
              loading: load,
              color: _surface,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADDRESS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  static const _typeIcons = {
    'home': Icons.home_rounded,
    'work': Icons.work_rounded,
    'other': Icons.location_on_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[address.addressType] ?? Icons.location_on_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: _primary, width: 1.5)
            : Border.all(color: _divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  address.addressType[0].toUpperCase() +
                      address.addressType.substring(1),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                const Spacer(),
                // ── Action buttons ─────────────────────────────────────────
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined,
                        color: _textSecondary, size: 18),
                  ),
                ),
                const SizedBox(width: 4),
                if (address.isDefault == false)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.delete_outline_rounded,
                          color: _danger, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Address details ──────────────────────────────────────────────
            Text(
              address.fullAddress,
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            if (address.landmark.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Near ${address.landmark}',
                style: const TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'PIN: ${address.pincode}',
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADDRESS FORM SCREEN  (Add / Edit)
// ─────────────────────────────────────────────────────────────────────────────

class AddressFormScreen extends StatefulWidget {
  final AddressModel? existingAddress;

  const AddressFormScreen({super.key, this.existingAddress});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullAddressController;
  late TextEditingController _landmarkController;
  late TextEditingController _pincodeController;
  late String _addressType;
  late bool _isDefault;
  bool _isSaving = false;

  bool get _isEditing => widget.existingAddress != null;

  static const _addressTypes = ['home', 'work', 'other'];
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _fullAddressController = TextEditingController(text: a?.fullAddress ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _pincodeController = TextEditingController(text: a?.pincode ?? '');
    _addressType = a?.addressType ?? 'home';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<dynamic> addAddress(Map<String, dynamic> body) async {
    final data = await apiService.addNewAddress(body);

    return data;
  }

  Future<dynamic> updateAddress(int id, Map<String, dynamic> body) async {
    final data = await apiService.updateNewAddress(id, body);
    return data;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final body = AddressModel(
      id: widget.existingAddress?.id,
      addressType: _addressType,
      fullAddress: _fullAddressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      pincode: _pincodeController.text.trim(),
      latitude: kDefaultLatitude,
      // TODO: replace with map picker
      longitude: kDefaultLongitude,
      // TODO: replace with map picker
      isDefault: _isDefault,
    ).toJson();

    try {
      if (_isEditing) {
        await updateAddress(widget.existingAddress?.id ?? 0, body);
      } else {
        await addAddress(body);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Address updated!' : 'Address added!'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context, true); // true = refresh list
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to save address. Try again.'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Map placeholder ──────────────────────────────────────────────
            _buildMapPlaceholder(),
            const SizedBox(height: 24),
            // ── Address type ─────────────────────────────────────────────────
            _buildSectionLabel('Address Type'),
            const SizedBox(height: 10),
            _buildAddressTypeSelector(),
            const SizedBox(height: 24),
            // ── Form fields ──────────────────────────────────────────────────
            _buildSectionLabel('Address Details'),
            const SizedBox(height: 10),
            _buildCard([
              _buildField(
                controller: _fullAddressController,
                label: 'Full Address',
                hint: 'House no, street, area...',
                icon: Icons.home_work_outlined,
                maxLines: 2,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Full address is required';
                  }
                  return null;
                },
              ),
              _buildDivider(),
              _buildField(
                controller: _landmarkController,
                label: 'Landmark (optional)',
                hint: 'e.g. Near temple, mall...',
                icon: Icons.place_outlined,
              ),
              _buildDivider(),
              _buildField(
                controller: _pincodeController,
                label: 'Pincode',
                hint: '6-digit pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Pincode is required';
                  }
                  if (v.trim().length != 6) {
                    return 'Enter a valid 6-digit pincode';
                  }
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 20),
            // ── Set as default ───────────────────────────────────────────────
            _buildDefaultToggle(),
            const SizedBox(height: 36),
            SafeArea(child: _buildSaveButton()),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _buildMapPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCE5CC)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.map_outlined, color: _primary, size: 28),
          ),
          const SizedBox(height: 10),
          const Text(
            'Map Integration Coming Soon',
            style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'Location will be set automatically',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    const icons = {
      'home': Icons.home_rounded,
      'work': Icons.work_rounded,
      'other': Icons.location_on_rounded,
    };

    return Row(
      children: _addressTypes.map((type) {
        final selected = _addressType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _addressType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: type != 'other' ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? _primary : _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? _primary : _divider, width: 1.5),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(icons[type],
                      color: selected ? Colors.white : _textSecondary,
                      size: 22),
                  const SizedBox(height: 4),
                  Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(
                      color: selected ? Colors.white : _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        // color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //       color: Colors.black.withOpacity(0.05),
        //       blurRadius: 12,
        //       offset: const Offset(0, 4))
        // ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => const Divider(
      height: 8, color: Colors.transparent, indent: 20, endIndent: 20);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AppTextField(
        ctrl: controller,
        hint: hint,
        validator: validator,
      ),
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star_rounded, color: _primary, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set as Default',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text('Use this address for all orders',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            activeColor: _primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? SizedBox(
                width: 22,
                height: 22,
                child:
                    AppDefaultLoader(loading: _isSaving, color: Colors.white))
            : Text(
                _isEditing ? 'Update Address' : 'Save Address',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2),
              ),
      ),
    );
  }
}
