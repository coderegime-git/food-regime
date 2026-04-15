import 'package:flutter/material.dart';
import 'package:food_delivery_app/constants/app_constants.dart';
import 'package:food_delivery_app/model/home_data.dart';
import 'package:food_delivery_app/model/profile_data.dart';
import 'package:food_delivery_app/routes/app_routes.dart';
import 'package:food_delivery_app/screens/home/restaurant_detail_screen.dart';
import 'package:food_delivery_app/screens/profile/wallet_screen.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/utils/helper.dart';
import 'package:food_delivery_app/utils/sharedpreference_helper.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';
import 'package:go_router/go_router.dart';

// ─── Palette & constants ───────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFFFF8F3);
  static const primary = Color(0xFFFF5A00);
  static const primaryLight = Color(0xFFFF8C42);
  static const ink = Color(0xFF1A1A2E);
  static const muted = Color(0xFF8D8D9A);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFF0EDE8);
  static const success = Color(0xFF2ECC71);
  static const font = 'Poppins'; // add to pubspec.yaml
}

// ─── Entry ─────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileData data;

  @override
  void initState() {
    data = SharedPreferenceHelper.getUserObject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (data.data != null) _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // const SizedBox(height: 24),
                // _StatsRow(),
                //const SizedBox(height: 28),
                // _SectionLabel('My Activity'),
                // const SizedBox(height: 12),
                // _ActivityCards(),
                const SizedBox(height: 28),
                _SectionLabel('Account'),
                const SizedBox(height: 12),
                _MenuGroup(items: [
                  _MenuItem(
                    icon: Icons.location_on_rounded,
                    iconBg: const Color(0xFFFF5A00),
                    label: 'Saved Addresses',
                    onTap: () {
                      context.push(AppRoutes.savedAddresses);
                    },
                    //       trailing: _badge('2'),
                  ),
                  // _MenuItem(
                  //   icon: Icons.payment_rounded,
                  //   iconBg: const Color(0xFF6C5CE7),
                  //   label: 'Payment Methods',
                  // ),
                  _MenuItem(
                    icon: Icons.local_offer_rounded,
                    iconBg: const Color(0xFFFFB300),
                    label: 'Promo Codes',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CouponPage(
                                    orderTotal: 0,
                                    onCouponApplied: (String value) {},
                                  )));
                    },
                    // trailing: _badge('3', color: _C.success),
                  ),
                  _MenuItem(
                    icon: Icons.wallet,
                    iconBg: Colors.green,
                    label: 'Wallet',
                    onTap: () {
                      context.push(AppRoutes.wallet);
                    },
                    // trailing: _badge('3', color: _C.success),
                  ),
                  // _MenuItem(
                  //   icon: Icons.card_giftcard_rounded,
                  //   iconBg: const Color(0xFFE84393),
                  //   label: 'Rewards & Cashback',
                  // ),
                ]),
                const SizedBox(height: 16),
                _SectionLabel('Preferences'),
                const SizedBox(height: 12),
                _MenuGroup(items: [
                  _MenuItem(
                    icon: Icons.notifications_rounded,
                    iconBg: const Color(0xFF00B4D8),
                    label: 'Notifications',
                    onTap: () {
                      context.push(AppRoutes.notifications);
                    },
                    //  trailing: _switchWidget(),
                  ),
                  // _MenuItem(
                  //   icon: Icons.dark_mode_rounded,
                  //   iconBg: const Color(0xFF1A1A2E),
                  //   label: 'Dark Mode',
                  //   trailing: _switchWidget(value: false),
                  // ),
                  // const _MenuItem(
                  //   icon: Icons.language_rounded,
                  //   iconBg: const Color(0xFF43AA8B),
                  //   label: 'Language',
                  //   subtitle: 'English (US)',
                  // ),
                ]),
                const SizedBox(height: 16),
                const _SectionLabel('Support'),
                const SizedBox(height: 12),
                _MenuGroup(items: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    iconBg: const Color(0xFFFF7043),
                    label: 'Help & FAQ',
                    onTap: () {
                      context.push(AppRoutes.staticPagePath("faq"));
                    },
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    iconBg: const Color(0xFFFF7043),
                    label: 'Privacy policy',
                    onTap: () {
                      context.push(AppRoutes.staticPagePath("privacy_policy"));
                    },
                  ),
                  // _MenuItem(
                  //   icon: Icons.chat_bubble_outline_rounded,
                  //   iconBg: const Color(0xFF26C6DA),
                  //   label: 'Chat with Us',
                  // ),
                  /* _MenuItem(
                    icon: Icons.star_outline_rounded,
                    iconBg: const Color(0xFFFFB300),
                    label: 'Rate the App',
                  ), */ /*  _MenuItem(
                    icon: Icons.star_outline_rounded,
                    iconBg: const Color(0xFFFFB300),
                    label: 'Rate the App',
                  ),*/
                ]),
                const SizedBox(height: 28),
                _LogoutButton(), const SizedBox(height: 28),

                _DeleteButton(),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "App Version ${AppConstants.appVersion}",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                const SizedBox(height: 80),
                const SizedBox(height: 80),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _C.bg,
      elevation: 0,
      leading: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () async {
              await context.push(AppRoutes.editProfilePath("no"));
              data = SharedPreferenceHelper.getUserObject();
              setState(() {});
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.edit_rounded, size: 18, color: _C.ink),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          children: [
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.primary.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.primaryLight.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_C.primary, _C.primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: _C.primary.withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: Center(
                                child: Text(
                                    data.data!.name != null
                                        ? data.data!.name!.length > 0
                                        ? data.data!.name![0]
                                        : "U"
                                        : "U",
                                    style: TextStyle(
                                      fontFamily: _C.font,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: _C.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.data!.name ?? "",
                                  style: TextStyle(
                                    fontFamily: _C.font,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _C.ink,
                                  )),
                              const SizedBox(height: 2),
                              Text(data.data!.phone ?? "",
                                  style: TextStyle(
                                    fontFamily: _C.font,
                                    fontSize: 13,
                                    color: _C.muted,
                                  )),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _C.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        size: 13, color: _C.primary),
                                    SizedBox(width: 4),
                                    Text(data.data!.walletBalance ?? "",
                                        style: TextStyle(
                                          fontFamily: _C.font,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _C.primary,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Row ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            _StatItem(
                value: '48', label: 'Orders', icon: Icons.receipt_long_rounded),
            _divider(),
            _StatItem(value: '12', label: 'Reviews', icon: Icons.star_rounded),
            _divider(),
            _StatItem(
                value: '₹240', label: 'Saved', icon: Icons.savings_rounded),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(
        width: 1,
        height: 40,
        color: _C.divider,
      );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: _C.primary),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                fontFamily: _C.font,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.ink,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                fontFamily: _C.font,
                fontSize: 11,
                color: _C.muted,
              )),
        ],
      ),
    );
  }
}

// ─── Activity Cards ─────────────────────────────────────────────────────────
class _ActivityCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _ActivityCard(
            icon: Icons.shopping_bag_rounded,
            label: 'Active Order',
            sublabel: 'Arriving in 12 min',
            color: _C.primary,
            gradient: [const Color(0xFFFF5A00), const Color(0xFFFF8C42)],
            isHighlighted: true,
          ),
          const SizedBox(width: 12),
          _ActivityCard(
            icon: Icons.favorite_rounded,
            label: 'Favourites',
            sublabel: '7 restaurants',
            color: const Color(0xFFE84393),
            gradient: [const Color(0xFFE84393), const Color(0xFFFF6EB4)],
          ),
          const SizedBox(width: 12),
          _ActivityCard(
            icon: Icons.history_rounded,
            label: 'Past Orders',
            sublabel: '48 orders',
            color: const Color(0xFF6C5CE7),
            gradient: [const Color(0xFF6C5CE7), const Color(0xFF9B8FFF)],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final List<Color> gradient;
  final bool isHighlighted;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.gradient,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontFamily: _C.font,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              Text(sublabel,
                  style: TextStyle(
                    fontFamily: _C.font,
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Menu Group ─────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: items
              .asMap()
              .entries
              .map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Divider(height: 1, color: _C.divider),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final void Function()? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontFamily: _C.font,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        )),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                            fontFamily: _C.font,
                            fontSize: 11,
                            color: _C.muted,
                          )),
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: _C.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
              fontFamily: _C.font,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.muted,
              letterSpacing: 0.8,
            )),
      ),
    );
  }
}

// ─── Logout Button ──────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirm = await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Confirm Logout"),
                    content: const Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
            );

            if (confirm == true) {
              await ApiService().deleteFCMToken();
              SharedPreferenceHelper.clear();
              context.go(AppRoutes.login);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEA),
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: _C.primary.withOpacity(0.2), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 18, color: _C.primary),
                SizedBox(width: 8),
                Text('Log Out',
                    style: TextStyle(
                      fontFamily: _C.font,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.primary,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            var confirm = false;
            confirm = await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Confirm Delete"),
                    content: const Text("Are you sure you want to delete?"),
                    actions: confirm == true
                        ? [
                      Center(
                        child: AppDefaultLoader(loading: confirm),
                      )
                    ]
                        : [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                            WidgetStatePropertyAll(Colors.red)),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
            );

            if (confirm == true) {
              final userId = SharedPreferenceHelper.getUserId();
              final res =
              await ApiService().deleteAccount(userId: userId ?? "");
              Helper().showToast(context, res['message'], res['statusCode']);
              SharedPreferenceHelper.clear();
              await ApiService().deleteFCMToken();
              context.go(AppRoutes.login);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFEEEA), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, size: 18, color: _C.bg),
                SizedBox(width: 8),
                Text('Delete',
                    style: TextStyle(
                      fontFamily: _C.font,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.bg,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────
Widget _badge(String count, {Color color = _C.primary}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(count,
          style: TextStyle(
            fontFamily: _C.font,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          )),
    );

Widget _switchWidget({bool value = true}) =>
    Transform.scale(
      scale: 0.8,
      child: Switch(
        value: value,
        onChanged: (_) {},
        activeColor: _C.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
