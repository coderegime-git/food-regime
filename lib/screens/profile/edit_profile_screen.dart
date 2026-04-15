// lib/screens/profile/edit_profile_screen.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:food_delivery_app/widgets/common_textform_field.dart';
import 'package:go_router/go_router.dart';

import '../../model/profile_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/sharedpreference_helper.dart';

class UpdateProfileData {
  String name;
  String dateOfBirth;
  String gender;
  bool isVeg;
  String spiceLevel;
  bool isOnboardingComplete;

  UpdateProfileData({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.isVeg,
    required this.spiceLevel,
    required this.isOnboardingComplete,
  });

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) =>
      UpdateProfileData(
        name: json['name'] ?? '',
        dateOfBirth: json['date_of_birth'] ?? '',
        gender: json['gender'] ?? 'male',
        isVeg: json['is_veg'] ?? false,
        spiceLevel: json['spice_level'] ?? 'mild',
        isOnboardingComplete: json['is_onboarding_complete'] ?? false,
      );

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'is_veg': isVeg,
        'spice_level': spiceLevel,
        'is_onboarding_complete': isOnboardingComplete,
      };
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  final bool? fromHome;

  const EditProfileScreen({super.key, this.fromHome});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedGender;
  late String _selectedSpiceLevel;
  late bool _isVeg;
  late DateTime? _selectedDob;
  bool _isSaving = false;
  bool isLoad = true;

  static const _spiceLevels = ['mild', 'medium', 'spicy'];
  static const _genders = ['male', 'female', 'other'];

  // Design tokens
  static const _primary = Color(0xFFFF6B35);
  static const _surface = Color(0xFFFFFBF8);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF757575);
  static const _divider = Color(0xFFF0EDE8);
  static const _vegGreen = Color(0xFF2E7D32);
  static const _nonVegRed = Color(0xFFC62828);

  final apiService = ApiService();
  late ProfileData profileData;

  @override
  void initState() {
    getProfileInfo();
    super.initState();
  }

  getProfileInfo() async {
    try {
      profileData = await apiService.getProfile();
      print(jsonEncode(profileData));
      if (profileData.data != null) {
        final profile = profileData.data!;
        _nameController = TextEditingController(text: profile.name);
        _selectedGender = profile.gender ?? "male";
        _selectedSpiceLevel = profile.spiceLevel ?? "spicy";
        _isVeg = profile.isVeg ?? false;
        _selectedDob = _parseDob(profile.dateOfBirth ?? "2002-12-31");
      }
      setState(() {
        isLoad = false;
      });
    } catch (e) {
      setState(() {
        isLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  DateTime? _parseDob(String dob) {
    try {
      return DateTime.parse(dob);
    } catch (_) {
      return null;
    }
  }

  String _formatDob(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  String _displayDob(DateTime? dt) {
    if (dt == null) return 'Select date of birth';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primary,
            onPrimary: Colors.white,
            surface: _cardBg,
            onSurface: _textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = UpdateProfileData(
      name: _nameController.text.trim(),
      dateOfBirth: _formatDob(_selectedDob),
      gender: _selectedGender,
      isVeg: _isVeg,
      spiceLevel: _selectedSpiceLevel,
      isOnboardingComplete: profileData.data!.isOnboardingComplete ?? false,
    );

    final data = await apiService.updateProfile(updated.toUpdateJson());
    SharedPreferenceHelper.setUserObject(data);
    setState(() {});
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (widget.fromHome != true) {
        Navigator.pop(context, updated);
      } else {
        if (mounted) context.go(AppRoutes.home);
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.fromHome == true ? false : true,
      child: Scaffold(
        backgroundColor: _surface,
        appBar: _buildAppBar(),
        body: isLoad
            ? AppDefaultLoader(loading: isLoad)
            : Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Personal Info'),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildNameField(),
                      // _buildDivider(),
                      _buildDobField(),
                      //_buildDivider(),
                      _buildGenderField(),
                    ]),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Food Preferences'),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildVegToggle(),
                      _buildDivider(),
                      _buildSpiceLevelField(),
                    ]),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: widget.fromHome == true
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: _textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAvatarSection() {
    final initials = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : 'U';
    return Center(
      child: Stack(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Container(
          //     width: 28,
          //     height: 28,
          //     decoration: BoxDecoration(
          //       color: _primary,
          //       shape: BoxShape.circle,
          //       border: Border.all(color: _surface, width: 2),
          //     ),
          //     child:
          //         const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
          //   ),
          // ),
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

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: _divider, indent: 20, endIndent: 20);
  }

  // ─── Fields ────────────────────────────────────────────────────────────────

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: AppTextField(
        ctrl: _nameController,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Name is required';
          if (v.trim().length < 2) return 'Name is too short';
          return null;
        },
        onChange: (v) {
          setState(() {});
        },
        hint: 'Full name',
      ),
    );
  }

  Widget _buildDobField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: _primary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date of Birth',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    _displayDob(_selectedDob),
                    style: TextStyle(
                      color:
                          _selectedDob != null ? _textPrimary : _textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.wc_rounded, color: _primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gender',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: _genders
                      .map((g) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _GenderChip(
                              label: g[0].toUpperCase() + g.substring(1),
                              selected: _selectedGender == g,
                              onTap: () => setState(() => _selectedGender = g),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isVeg ? _vegGreen : _nonVegRed,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isVeg ? _vegGreen : _nonVegRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dietary Preference',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  _isVeg ? 'Vegetarian' : 'Non-Vegetarian',
                  style: TextStyle(
                    color: _isVeg ? _vegGreen : _nonVegRed,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _isVeg,
            activeColor: _vegGreen,
            onChanged: (v) => setState(() => _isVeg = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiceLevelField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Text('🌶️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Spice Level',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: _spiceLevels
                      .map((level) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _SpiceChip(
                              level: level,
                              selected: _selectedSpiceLevel == level,
                              onTap: () =>
                                  setState(() => _selectedSpiceLevel = level),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isSaving
            ? SizedBox(
                width: 22,
                height: 22,
                child:
                    AppDefaultLoader(loading: _isSaving, color: Colors.white),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B35) : const Color(0xFFF5F0EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF757575),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SpiceChip extends StatelessWidget {
  final String level;
  final bool selected;
  final VoidCallback onTap;

  const _SpiceChip(
      {required this.level, required this.selected, required this.onTap});

  static const _colors = {
    'mild': Color(0xFF4CAF50),
    'medium': Color(0xFFFF9800),
    'spicy': Color(0xFFF44336),
  };

  static const _icons = {
    'mild': '🟢',
    'medium': '🟡',
    'spicy': '🔴',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[level]!;
    final icon = _icons[level]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : const Color(0xFFF5F0EB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              level[0].toUpperCase() + level.substring(1),
              style: TextStyle(
                color: selected ? color : const Color(0xFF757575),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
