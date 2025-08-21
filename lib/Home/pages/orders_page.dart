import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sudan_goods/order/order_details_page.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('You need to be logged in to view orders.')),
      );
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load orders: ${snapshot.error}'));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Order?'),
          content: const Text(
              'This order has not been confirmed yet. Do you want to delete it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              label: const Text('Delete'),
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
          const SnackBar(content: Text('Order deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete order: $e')),
        );
      }
    }
  }
}

class _EmptyOrdersState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text(
              'Your orders will appear here. Start shopping to place your first order!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
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
    print(orderId);
    final dateStr = createdAt != null ? DateFormat('MMM d, yyyy • HH:mm').format(createdAt!) : '-';
    final shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;
    final statusChip = _buildStatusChip(status);

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
                          'Order #$shortId',
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
                      '$itemCount items • $dateStr',
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
                      tooltip: 'Delete order',
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

  Widget _buildStatusChip(String status) {
    MaterialColor color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.amber;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'preparing':
      case 'processing':
        color = Colors.blueGrey;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
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
        if (!snapshot.hasData || !(snapshot.data?.exists ?? false)) {
          return Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.storefront, size: 16, color: Colors.black38),
              ),
              const SizedBox(width: DesignTokens.space8),
              Text('Unknown store', style: AppTypography.smallBold),
            ],
          );
        }

        final store = snapshot.data!.data();
        final name = (store?['name'] as String?) ?? 'Unknown store';
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
