import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sudan_goods/order/order_details_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(l10n.mustLoginToViewOrders)),
      );
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrders),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            padding: const EdgeInsets.all(DesignTokens.space12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.space12),
            itemBuilder: (context, index) {
              final doc = docs[index];
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
                onDelete: status.toLowerCase() == 'pending'
                    ? () => _confirmAndDelete(context, doc.id)
                    : null,
              );
            },
          );
        },
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
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.orderDeleted)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToDeleteOrder)),
        );
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
            const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(l10n.noOrdersYet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              l10n.ordersEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
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
    print(orderId);
    final dateStr = createdAt != null ? DateFormat('MMM d, yyyy • HH:mm').format(createdAt!) : '-';
    final shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;
    final statusChip = _buildStatusChip(context, status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
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
                      style: AppTypography.caption.copyWith(color: Colors.black54),
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
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  if (onDelete != null)
                    IconButton(
                      tooltip: l10n.deleteOrder,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                ],
              )
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
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
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
        label = status.toLowerCase() == 'preparing' ? l10n.orderStatusPreparing : l10n.orderStatusProcessing;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
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
      stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
          return Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.storefront, size: 16, color: Colors.black38),
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
              backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                  ? NetworkImage(logoUrl)
                  : null,
              child: (logoUrl == null || logoUrl.isEmpty)
                  ? const Icon(Icons.storefront, size: 16, color: Colors.black38)
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
