import 'package:flutter/material.dart';
import 'package:food_delivery_app/model/home_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FILTER STATE MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum SortOption { none, rating, distance, price, discount }

class FilterState {
  final SortOption sortBy;
  final double maxDistanceKm; // 0 = no limit
  final double minRating; // 0 = no limit
  final bool discountOnly; // only show restaurants with active offers

  const FilterState({
    this.sortBy = SortOption.none,
    this.maxDistanceKm = 0,
    this.minRating = 0,
    this.discountOnly = false,
  });

  FilterState copyWith({
    SortOption? sortBy,
    double? maxDistanceKm,
    double? minRating,
    bool? discountOnly,
  }) {
    return FilterState(
      sortBy: sortBy ?? this.sortBy,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minRating: minRating ?? this.minRating,
      discountOnly: discountOnly ?? this.discountOnly,
    );
  }

  bool get isActive =>
      sortBy != SortOption.none ||
      maxDistanceKm > 0 ||
      minRating > 0 ||
      discountOnly;
}

// ─────────────────────────────────────────────────────────────────────────────
//  FILTER LOGIC  — apply to any List<Restaurant>
// ─────────────────────────────────────────────────────────────────────────────

List<Restaurant> applyFilters(
  List<Restaurant> source,
  FilterState state,
) {
  List<Restaurant> result = List.of(source);
  ;
  // 1. Distance filter
  if (state.maxDistanceKm > 0) {
    result = result.where((r) {
      final d =
          double.tryParse(r.distance?.toString() ?? '') ?? double.infinity;
      return d <= state.maxDistanceKm;
    }).toList();
  }

  // 2. Rating filter
  if (state.minRating > 0) {
    result = result.where((r) {
      final rating = double.tryParse(r.rating?.average?.toString() ?? '') ?? 0;
      return rating >= state.minRating;
    }).toList();
  }

  // 3. Discount only — assumes `deliveryFee` starts with "Free" or restaurant
  //    has some offer indicator. Adjust the condition to match your API model.
  if (state.discountOnly) {
    result = result.where((r) {
      final hasFreeDelivery =
          r.deliveryFee?.toLowerCase().startsWith('free') == true ||
              r.deliveryFee == "0";
      // Add more conditions here if your Restaurant model has an `hasOffer` field
      return hasFreeDelivery;
    }).toList();
  }

  // 4. Sorting
  switch (state.sortBy) {
    case SortOption.rating:
      result.sort((a, b) {
        final rA = double.tryParse(a.rating?.average?.toString() ?? '') ?? 0;
        final rB = double.tryParse(b.rating?.average?.toString() ?? '') ?? 0;
        return rB.compareTo(rA); // descending
      });
      break;
    case SortOption.distance:
      result.sort((a, b) {
        final dA =
            double.tryParse(a.distance?.toString() ?? '') ?? double.infinity;
        final dB =
            double.tryParse(b.distance?.toString() ?? '') ?? double.infinity;
        return dA.compareTo(dB); // ascending (nearest first)
      });
      break;
    case SortOption.price:
      // Sort by delivery fee — free delivery first, then by numeric value
      result.sort((a, b) {
        final feeA = _parseFee(a.deliveryFee);
        final feeB = _parseFee(b.deliveryFee);
        return feeA.compareTo(feeB);
      });
      break;
    case SortOption.discount:
      // Restaurants with free delivery / offers bubble to the top
      result.sort((a, b) {
        final aFree =
            a.deliveryFee?.toLowerCase().startsWith('free') == true ? 0 : 1;
        final bFree =
            b.deliveryFee?.toLowerCase().startsWith('free') == true ? 0 : 1;
        return aFree.compareTo(bFree);
      });
      break;
    case SortOption.none:
      break;
  }
  print(result);
  print("resultresult");
  return result;
}

double _parseFee(String? fee) {
  if (fee == null) return double.infinity;
  if (fee.toLowerCase().startsWith('free')) return 0;
  // Strip currency symbols/text and parse the number
  final numeric = RegExp(r'[\d.]+').firstMatch(fee)?.group(0);
  return double.tryParse(numeric ?? '') ?? double.infinity;
}

// ─────────────────────────────────────────────────────────────────────────────
//  FILTER BOTTOM SHEET  — drop-in replacement for CategoryFilterBar
// ─────────────────────────────────────────────────────────────────────────────

class CategoryFilterBar extends StatefulWidget {
  final List<Category> categories;
  final FilterState filterState;
  final ValueChanged<FilterState> onFilterChanged;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.filterState,
    required this.onFilterChanged,
  });

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  late FilterState _current;

  static const _primary = Color(0xFFE23744);
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF8A8A8E);
  static const _bg = Color(0xFFF7F3EF);

  @override
  void initState() {
    super.initState();
    _current = widget.filterState;
  }

  void _apply() {
    widget.onFilterChanged(_current);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() => _current = const FilterState());
    widget.onFilterChanged(const FilterState());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              if (_current.isActive)
                GestureDetector(
                  onTap: _reset,
                  child: const Text(
                    'Reset all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Sort By ──────────────────────────────────────────────────────
          _SectionLabel('Sort by'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortOption.values.map((opt) {
              if (opt == SortOption.none) return const SizedBox.shrink();
              final selected = _current.sortBy == opt;
              return _FilterChip(
                label: _sortLabel(opt),
                icon: _sortIcon(opt),
                selected: selected,
                onTap: () => setState(() => _current = _current.copyWith(
                      sortBy: selected ? SortOption.none : opt,
                    )),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Max Distance ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('Max distance'),
              Text(
                _current.maxDistanceKm == 0
                    ? 'Any'
                    : '${_current.maxDistanceKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primary,
              thumbColor: _primary,
              overlayColor: _primary.withOpacity(0.12),
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 3,
            ),
            child: Slider(
              value: _current.maxDistanceKm,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (v) => setState(
                () => _current = _current.copyWith(maxDistanceKm: v),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Min Rating ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('Minimum rating'),
              Text(
                _current.minRating == 0
                    ? 'Any'
                    : '${_current.minRating.toStringAsFixed(1)} ⭐',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primary,
              thumbColor: _primary,
              overlayColor: _primary.withOpacity(0.12),
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 3,
            ),
            child: Slider(
              value: _current.minRating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (v) => setState(
                () => _current = _current.copyWith(minRating: v),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Discount Toggle ──────────────────────────────────────────────
          _ToggleRow(
            icon: Icons.local_offer_rounded,
            label: 'Free delivery / offers only',
            value: _current.discountOnly,
            onChanged: (v) => setState(
              () => _current = _current.copyWith(discountOnly: v),
            ),
          ),
          const SizedBox(height: 28),

          // ── Apply button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _apply,
              child: const Text(
                'Apply filters',
                style: TextStyle(
                  fontSize: 15,
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

  String _sortLabel(SortOption opt) {
    switch (opt) {
      case SortOption.rating:
        return 'Top rated';
      case SortOption.distance:
        return 'Nearest';
      case SortOption.price:
        return 'Delivery fee';
      case SortOption.discount:
        return 'Offers first';
      case SortOption.none:
        return '';
    }
  }

  IconData _sortIcon(SortOption opt) {
    switch (opt) {
      case SortOption.rating:
        return Icons.star_rounded;
      case SortOption.distance:
        return Icons.near_me_rounded;
      case SortOption.price:
        return Icons.delivery_dining_rounded;
      case SortOption.discount:
        return Icons.local_offer_rounded;
      case SortOption.none:
        return Icons.sort;
    }
  }
}

// ── Small reusable sub-widgets ───────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1E),
        ),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const _primary = Color(0xFFE23744);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _primary : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : const Color(0xFF8A8A8E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE23744)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE23744),
        ),
      ],
    );
  }
}
