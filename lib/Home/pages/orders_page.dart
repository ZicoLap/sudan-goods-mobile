import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sudan_goods/order/order_details_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'all';

  static const List<(String, String)> _filters = [
    ('all', 'All'),
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('preparing', 'Preparing'),
    ('shipped', 'Shipped'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                border: Border.all(color: Colors.black.withOpacity(0.07)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14.5, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search orders…',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14.5,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.black38,
                      size: 21,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon:
                      _searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                            onTap: () => setState(() => _searchCtrl.clear()),
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.07),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 6,
                  ),
                ),
              ),
            ),
          ),

          // ── Status filter chips ────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (key, label) = _filters[index];
                final isSelected = _selectedFilter == key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.black.withOpacity(0.1),
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : [],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // ── Orders list ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ordersQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.failedToLoadOrders));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _EmptyOrdersState();
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                  itemCount: docs.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: DesignTokens.space12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final status = (data['status'] as String?) ?? 'pending';
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate();
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
              },
            ),
          ),
        ],
      ),
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
