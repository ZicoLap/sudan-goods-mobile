import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sudan_goods/order/models/order_filter.dart';
import 'package:sudan_goods/order/pages/order_details_page.dart';
import 'package:sudan_goods/order/utils/order_filter_utils.dart';
import 'package:sudan_goods/order/widgets/order_filter_sheet.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderFilter _filter = OrderFilter.defaults();
  Map<String, String> _storeNames = {};
  Set<String> _loadedStoreIds = {};

  Future<void> _ensureStoreNames(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    AppLocalizations l10n,
  ) async {
    final ids = collectStoreIds(docs);
    if (ids.difference(_loadedStoreIds).isEmpty) return;

    final names = await loadStoreNamesForOrders(docs, l10n);
    if (!mounted) return;
    setState(() {
      _storeNames = {..._storeNames, ...names};
      _loadedStoreIds = {..._loadedStoreIds, ...ids};
    });
  }

  Future<void> _openFilterSheet(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await _ensureStoreNames(docs, l10n);
    if (!mounted) return;

    final result = await OrderFilterSheet.show(
      context,
      initialFilter: _filter,
      storeOptions: _storeNames,
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  void _updateFilter(OrderFilter updated) => setState(() => _filter = updated);

  void _scheduleStoreNameLoad(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    AppLocalizations l10n,
  ) {
    final ids = collectStoreIds(docs);
    if (ids.difference(_loadedStoreIds).isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureStoreNames(docs, l10n);
    });
  }

  Widget _buildFilterBar(
    AppLocalizations l10n,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required bool loading,
  }) {
    final activeChips = buildActiveFilterChips(
      filter: _filter,
      l10n: l10n,
      storeNames: _storeNames,
      onUpdate: _updateFilter,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: loading ? null : () => _openFilterSheet(docs),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(l10n.filterButtonLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              if (_filter.activeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filter.activeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (activeChips.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: activeChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = activeChips[index];
                  return InputChip(
                    label: Text(chip.label, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: chip.onRemove,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(body: Center(child: Text(l10n.mustLoginToViewOrders)));
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Hero banner ────────────────────────────────────────────────
          _OrdersHeroBanner(l10n: l10n),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ordersQuery.snapshots(),
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData;

                if (snapshot.hasError) {
                  return Center(child: Text(l10n.failedToLoadOrders));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isNotEmpty) {
                  _scheduleStoreNameLoad(docs, l10n);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFilterBar(l10n, docs, loading: loading),
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          loading
                              ? const Center(
                                child: CircularProgressIndicator(),
                              )
                              : docs.isEmpty
                              ? _EmptyOrdersState()
                              : _buildOrdersList(context, l10n, docs),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    AppLocalizations l10n,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      applyOrderFilters(docs, _filter),
    );
    sortOrders(filtered, _filter.sortBy);

    if (filtered.isEmpty) {
      return _NoMatchingOrdersState(
        onClear: () => _updateFilter(OrderFilter.defaults()),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.space12),
      itemBuilder: (context, index) {
        final doc = filtered[index];
        final data = doc.data();
        final status = (data['status'] as String?) ?? 'pending';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final total = (data['total'] as num?)?.toDouble() ?? 0.0;
        final items = (data['items'] as List<dynamic>?);
        final itemCount = items?.length ?? 0;
        final storeId = (data['storeId'] as String?) ?? '';

        return _OrderCard(
          orderId: doc.id,
          status: status,
          createdAt: createdAt,
          total: total,
          itemCount: itemCount,
          storeId: storeId,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(orderId: doc.id),
              ),
            );
          },
          onDelete:
              status.toLowerCase() == 'pending'
                  ? () => _confirmAndDelete(context, doc.id)
                  : null,
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, String orderId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteOrderQuestion),
          content: Text(l10n.deleteOrderExplanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              label: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.orderDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedToDeleteOrder)));
      }
    }
  }
}

class _EmptyOrdersState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFEDD9), Colors.white],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: Colors.black45,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              l10n.noOrdersYet,
              style: AppTypography.heading6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              l10n.ordersEmptyHint,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchingOrdersState extends StatelessWidget {
  const _NoMatchingOrdersState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list_off, size: 48, color: Colors.black38),
            const SizedBox(height: DesignTokens.space12),
            Text(
              l10n.noOrdersMatchFilters,
              style: AppTypography.heading6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space16),
            TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final DateTime? createdAt;
  final double total;
  final int itemCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String storeId;

  const _OrderCard({
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.itemCount,
    required this.onTap,
    this.onDelete,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr =
        createdAt != null
            ? DateFormat('MMM d, yyyy • HH:mm').format(createdAt!)
            : '-';
    final shortId =
        orderId.length > 6
            ? orderId.substring(orderId.length - 6).toUpperCase()
            : orderId;
    final statusChip = _buildStatusChip(context, status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            boxShadow: DesignTokens.shadowMedium,
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              _statusIcon(status),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.orderNumber(shortId),
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        statusChip,
                      ],
                    ),
                    const SizedBox(height: 4),
                    _storeInline(),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.itemsCount(itemCount)} • $dateStr',
                      style: AppTypography.caption.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    total.toStringAsFixed(2),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (onDelete != null)
                    IconButton(
                      tooltip: l10n.deleteOrder,
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _iconBox(Icons.schedule, Colors.amber);
      case 'confirmed':
        return _iconBox(Icons.check_circle, Colors.green);
      case 'preparing':
      case 'processing':
        return _iconBox(Icons.hourglass_top, Colors.blueGrey);
      case 'shipped':
        return _iconBox(Icons.local_shipping, Colors.blue);
      case 'delivered':
        return _iconBox(Icons.done_all, Colors.green);
      case 'cancelled':
        return _iconBox(Icons.cancel, Colors.red);
      case 'fulfillment_review':
        return _iconBox(Icons.rate_review_outlined, Colors.deepPurple);
      default:
        return _iconBox(Icons.receipt_long, Colors.grey);
    }
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
        ),
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Center(
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    MaterialColor color;
    String label;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.amber;
        label = l10n.orderStatusPending;
        break;
      case 'confirmed':
        color = Colors.green;
        label = l10n.orderStatusConfirmed;
        break;
      case 'preparing':
      case 'processing':
        color = Colors.blueGrey;
        label =
            status.toLowerCase() == 'preparing'
                ? l10n.orderStatusPreparing
                : l10n.orderStatusProcessing;
        break;
      case 'shipped':
        color = Colors.blue;
        label = l10n.orderStatusShipped;
        break;
      case 'delivered':
        color = Colors.green;
        label = l10n.orderStatusDelivered;
        break;
      case 'cancelled':
        color = Colors.red;
        label = l10n.orderStatusCancelled;
        break;
      case 'fulfillment_review':
        color = Colors.deepPurple;
        label = l10n.orderStatusFulfillmentReview;
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.shade100.withOpacity(0.6), color.shade50],
        ),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _storeInline() {
    if (storeId.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .snapshots(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
          return Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(
                  Icons.storefront,
                  size: 16,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Text(l10n.unknownStore, style: AppTypography.smallBold),
            ],
          );
        }

        final store = snapshot.data!.data();
        final name = (store?['name'] as String?) ?? l10n.unknownStore;
        final logoUrl = (store?['logoUrl'] as String?);

        return Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (logoUrl != null && logoUrl.isNotEmpty)
                      ? NetworkImage(logoUrl)
                      : null,
              child:
                  (logoUrl == null || logoUrl.isEmpty)
                      ? const Icon(
                        Icons.storefront,
                        size: 16,
                        color: Colors.black38,
                      )
                      : null,
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Text(
                name,
                style: AppTypography.smallBold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Orders hero banner ─────────────────────────────────────────────────────────

class _OrdersHeroBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _OrdersHeroBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFD05000)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 24,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.myOrders,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.myOrders,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12.5,
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
