// ─────────────────────────────────────────────────────────────────────────────
//  WALLET  –  Model + API + Full Page UI
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
// 1.  MODELS
// ══════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../model/walllet_data.dart';
import '../../utils/api_service.dart';
import '../../widgets/app_loader.dart';

class AddMoneyResponse {
  final int statusCode;
  final String message;
  final double walletBalance;

  AddMoneyResponse({
    required this.statusCode,
    required this.message,
    required this.walletBalance,
  });

  factory AddMoneyResponse.fromJson(Map<String, dynamic> json) {
    return AddMoneyResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      walletBalance: (json['wallet_balance'] as num).toDouble(),
    );
  }
}

const _kPrimary = Color(0xFFFF5722);
Color _kBg = Colors.grey.shade50;
const _kCard = Colors.white;
const _kText = Color(0xFF1A1A1A);
const _kSub = Color(0xFF6B6B6B);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFE6F9EE);
const _kRedBg = Color(0xFFFFEBEE);
const _kRed = Color(0xFFD32F2F);

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();

  WalletData? _data;
  bool _loading = true;

  // Balance card animation
  late final AnimationController _balCtrl;
  late final Animation<double> _balScale;

  @override
  void initState() {
    super.initState();
    _balCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _balScale = CurvedAnimation(parent: _balCtrl, curve: Curves.elasticOut);
    _fetchWallet();
  }

  @override
  void dispose() {
    _balCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchWallet() async {
    setState(() => _loading = true);
    final res = await _api.getWallet();
    if (res['statusCode'] == 1) {
      setState(() {
        _data = WalletData.fromJson(res);
        _loading = false;
      });
      _balCtrl.forward(from: 0);
    } else {
      setState(() => _loading = false);
    }
  }

  void _openAddMoney() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMoneySheet(
        currentBalance: _data?.walletBalance ?? 0,
        onSuccess: (newBalance) {
          setState(() {
            _data = WalletData(
              walletBalance: newBalance,
              transactions: _data?.transactions ?? [],
            );
          });
          _balCtrl.forward(from: 0);
          _fetchWallet(); // refresh full list
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: _loading
          ? Center(child: AppDefaultLoader(color: _kPrimary, loading: _loading))
          : RefreshIndicator(
              color: _kPrimary,
              onRefresh: _fetchWallet,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildBalanceCard(),
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                  if (_data != null && _data!.transactions.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _TransactionTile(
                            tx: _data!.transactions[i],
                            isFirst: i == 0,
                            isLast: i == _data!.transactions.length - 1,
                          ),
                          childCount: _data!.transactions.length,
                        ),
                      ),
                    ),
                  ] else
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💸', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('No transactions yet',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _kText)),
                            const SizedBox(height: 4),
                            Text('Add money to get started',
                                style: TextStyle(fontSize: 13, color: _kSub)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddMoney,
              backgroundColor: _kPrimary,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Add Money',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      shadowColor: Colors.grey.shade200,
      backgroundColor: _kBg,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _kText, size: 16),
        ),
      ),
      title: const Text(
        'My Wallet',
        style:
            TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kText),
      ),
    );
  }

  // ── Balance hero card ─────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    final balance = _data?.walletBalance ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightGreen.shade600, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '● Active',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          ScaleTransition(
            scale: _balScale,
            child: Text(
              '₹${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bottom: add money button
          GestureDetector(
            onTap: _openAddMoney,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      color: _kPrimary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add Money to Wallet',
                    style: TextStyle(
                      color: _kPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick stat chips ──────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    if (_data == null) return const SizedBox.shrink();

    final credits = _data!.transactions
        .where((t) => t.isCredit)
        .fold(0.0, (s, t) => s + t.amount);
    final debits = _data!.transactions
        .where((t) => !t.isCredit)
        .fold(0.0, (s, t) => s + t.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
              child: _StatChip(
            icon: Icons.arrow_downward_rounded,
            label: 'Total Added',
            value: '₹${credits.toStringAsFixed(0)}',
            iconColor: _kGreen,
            bgColor: _kGreenBg,
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _StatChip(
            icon: Icons.arrow_upward_rounded,
            label: 'Total Spent',
            value: '₹${debits.toStringAsFixed(0)}',
            iconColor: _kRed,
            bgColor: _kRedBg,
          )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4.  TRANSACTION TILE
// ══════════════════════════════════════════════════════════════════════════════

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  final bool isFirst;
  final bool isLast;

  const _TransactionTile({
    required this.tx,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final fmt = DateFormat('d MMM y, h:mm a');

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCredit ? _kGreenBg : _kRedBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                isCredit
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isCredit ? _kGreen : _kRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fmt.format(tx.createdAt.toLocal()),
                    style: const TextStyle(fontSize: 11, color: _kSub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '−'} ₹${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isCredit ? _kGreen : _kRed,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCredit ? _kGreenBg : _kRedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCredit ? 'Credit' : 'Debit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isCredit ? _kGreen : _kRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 5.  ADD MONEY BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _AddMoneySheet extends StatefulWidget {
  final double currentBalance;
  final ValueChanged<double> onSuccess;

  const _AddMoneySheet({
    required this.currentBalance,
    required this.onSuccess,
  });

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  double? _selected; // quick-select preset
  bool _loading = false;
  String? _error;

  static const _presets = [100.0, 200.0, 500.0, 1000.0];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selected != null) return _selected;
    return double.tryParse(_ctrl.text.trim());
  }

  Future<void> _submit() async {
    final amt = _amount;
    if (amt == null || amt <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amt < 10) {
      setState(() => _error = 'Minimum amount is ₹10');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    HapticFeedback.mediumImpact();

    final res = await _api.addMoneyToWallet(amount: amt.toString());
    if (!mounted) return;

    if (res['statusCode'] == 1) {
      final resp = AddMoneyResponse.fromJson(res);
      Navigator.pop(context);
      HapticFeedback.heavyImpact();
      widget.onSuccess(resp.walletBalance);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Text('✅  '),
            Text(resp.message,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      setState(() {
        _loading = false;
        _error = res['message'] ?? 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 55 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: _kPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Money',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _kText)),
                  Text(
                    'Balance: ₹${widget.currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: _kSub),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick select presets
          const Text('Quick Add',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _kSub)),
          const SizedBox(height: 10),
          Row(
            children: _presets.map((p) {
              final active = _selected == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selected = active ? null : p;
                      if (!active) _ctrl.clear();
                      _error = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: p == _presets.last ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? _kPrimary : const Color(0xFFFAF8F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? _kPrimary : Colors.grey.shade200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '₹${p.toInt()}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: active ? Colors.white : _kText,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Or divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or enter amount',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(height: 16),

          // Amount input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _error != null
                    ? Colors.red.shade300
                    : _focus.hasFocus
                        ? _kPrimary
                        : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('₹',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _selected != null
                              ? Colors.grey.shade400
                              : _kPrimary)),
                ),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    enabled: _selected == null,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kText),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText:
                          _selected != null ? '${_selected!.toInt()}' : '0',
                      hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _selected != null
                              ? _kPrimary
                              : Colors.grey.shade300),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (_) => setState(() {
                      _selected = null;
                      _error = null;
                    }),
                  ),
                ),
                if (_ctrl.text.isNotEmpty || _selected != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      _ctrl.clear();
                      _selected = null;
                      _error = null;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded,
                          color: Colors.grey.shade400, size: 20),
                    ),
                  ),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 14),
                const SizedBox(width: 5),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Add button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                disabledBackgroundColor: _kPrimary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(),
                    )
                  : Text(
                      _amount != null && _amount! > 0
                          ? 'Add ₹${_amount!.toStringAsFixed(0)} to Wallet'
                          : 'Add Money',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 6.  HELPER WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _kSub)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _kText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
