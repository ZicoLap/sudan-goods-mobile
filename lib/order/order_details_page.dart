import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

/// Displays a read-only view of an order with live updates from Firestore.
///
/// Shows header, item list, delivery details, payment/status info,
/// and a cost summary. Provides a delete action for pending orders.
class OrderDetailsPage extends StatelessWidget {
  /// The Firestore document ID for the order to display.
  final String orderId;
  /// Creates an [OrderDetailsPage] for the given [orderId].
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  /// Builds the order details scaffold, listening to `orders/{orderId}` and
  /// rendering loading/error states and the full details on success.
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetailsTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.failedToLoadOrderWithError('${snapshot.error}'),
              ),
            );
          }
          final data = snapshot.data?.data();
          if (data == null) {
            return Center(child: Text(l10n.orderNotFound));
          }

          final status = (data['status'] as String?) ?? 'pending';
          final paymentStatus = (data['paymentStatus'] as String?) ?? '-';
          final paymentMethod = (data['paymentMethod'] as String?) ?? '-';
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

          final subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0.0;
          final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
          final total = (data['total'] as num?)?.toDouble() ?? 0.0;
          final totalWeight = (data['totalWeight'] as num?)?.toDouble() ?? 0.0;

          final items = (data['items'] as List<dynamic>?) ?? [];
          final storeId = (data['storeId'] as String?) ?? '';
          final recipientName = (data['recipientName'] as String?) ?? (data['name'] as String?) ?? '-';
          final recipientPhone = (data['recipientPhone'] as String?) ?? (data['phone'] as String?) ?? '-';
          final address = (data['address'] as Map<String, dynamic>?) ??
              (data['deliveryAddress'] as Map<String, dynamic>?) ??
              <String, dynamic>{};

          final shortId = orderId.length > 6
              ? orderId.substring(orderId.length - 6).toUpperCase()
              : orderId.toUpperCase();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: DesignTokens.shadowSmall,
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
                                        style: AppTypography.bodyBold,
                                      ),
                                      const SizedBox(width: DesignTokens.space8),
                                      _buildStatusChip(context, status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (storeId.isNotEmpty) _storeInline(storeId),
                                  const SizedBox(height: 4),
                                  Text(
                                    createdAt != null
                                        ? l10n.placedOnWithDate(
                                            DateFormat('MMM d, yyyy • HH:mm').format(createdAt),
                                          )
                                        : '-',
                                    style: AppTypography.caption.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            if (status.toLowerCase() == 'pending')
                              IconButton(
                                tooltip: l10n.deleteOrder,
                                onPressed: () => _confirmAndDelete(context),
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.space16),

                      // Items
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.itemsTitle, style: AppTypography.sectionTitle),
                            const SizedBox(height: DesignTokens.space12),
                            ...List.generate(items.length, (i) {
                              final raw = items[i] as Map<String, dynamic>;
                              final title = (raw['name'] as String?) ?? '-';
                              final qty = (raw['quantity'] as num?)?.toInt() ?? 0;
                              final price = (raw['price'] as num?)?.toDouble() ?? 0.0;
                              final imageUrl = (raw['imageUrl'] as String?);
                              final lineTotal = price * qty;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                                          boxShadow: DesignTokens.shadowSmall,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                                          child: imageUrl != null && imageUrl.isNotEmpty
                                              ? Image.network(imageUrl, fit: BoxFit.cover)
                                              : const Icon(Icons.image_outlined, color: Colors.black26),
                                        ),
                                      ),
                                      const SizedBox(width: DesignTokens.space12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(title, style: AppTypography.bodyBold),
                                            const SizedBox(height: 2),
                                            Text(
                                              l10n.qtyAndPrice(qty, price.toStringAsFixed(2)),
                                              style: AppTypography.caption.copyWith(color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: DesignTokens.space12),
                                      Text(lineTotal.toStringAsFixed(2), style: AppTypography.bodyBold),
                                    ],
                                  ),
                                  if (i != items.length - 1) const Divider(height: 24),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.space16),

                      // Delivery
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.deliverySectionTitle, style: AppTypography.sectionTitle),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(recipientName, style: AppTypography.body)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(recipientPhone, style: AppTypography.body)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatAddress(address),
                                    style: AppTypography.body,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.space16),

                      // Payment & Status
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.statusSectionTitle, style: AppTypography.sectionTitle),
                            const SizedBox(height: 8),
                            _twoCol(l10n.orderStatusLabel, _localizedStatus(context, status)),
                            _twoCol(l10n.paymentLabel, '$paymentStatus • $paymentMethod'),
                            _twoCol(
                              l10n.createdAtLabel,
                              createdAt != null
                                  ? DateFormat('MMM d, yyyy • HH:mm').format(createdAt)
                                  : '-',
                            ),
                            _twoCol(
                              l10n.updatedAtLabel,
                              updatedAt != null
                                  ? DateFormat('MMM d, yyyy • HH:mm').format(updatedAt)
                                  : '-',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.space16),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: DesignTokens.shadowSmall,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.summarySectionTitle, style: AppTypography.sectionTitle),
                            const SizedBox(height: 8),
                            _twoCol(l10n.itemsTitle, '${items.length}'),
                            _twoCol(l10n.totalWeight, '${totalWeight.toStringAsFixed(2)} ${l10n.kg}'),
                            const Divider(height: 24),
                            _twoCol(l10n.subtotal, subtotal.toStringAsFixed(2)),
                            _twoCol(l10n.deliveryFee, deliveryFee.toStringAsFixed(2)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.total, style: AppTypography.bodyBold),
                                Text(total.toStringAsFixed(2), style: AppTypography.bodyBold),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.space24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Asks the user to confirm deletion and removes the order document.
  ///
  /// Intended for pending orders only; shows snackbar feedback and pops the
  /// page when deletion succeeds.
  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.orderDeleted)),
          );
          Navigator.of(context).pop();
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

  /// Formats a plain address map [a] to a single comma-separated line.
  String _formatAddress(Map<String, dynamic> a) {
    final parts = [
      a['label'],
      a['street'],
      a['city'],
      a['postalCode'],
      a['country'],
    ];
    return parts.whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
  }

  /// Renders a two-column row with [label] on the left and [value] aligned
  /// to the right. Long values wrap gracefully.
  Widget _twoCol(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyBold,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns an icon container reflecting the current [status].
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

  /// Creates a rounded container with the given [icon] and accent [color].
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

  /// Localizes an order status code to a user-facing string.
  String _localizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'confirmed':
        return l10n.orderStatusConfirmed;
      case 'preparing':
        return l10n.orderStatusPreparing;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return status;
    }
  }

  /// Builds a small colored chip describing the order [status].
  Widget _buildStatusChip(BuildContext context, String status) {
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
        _localizedStatus(context, status),
        style: AppTypography.caption.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Inline store preview that listens to `stores/{storeId}` to show name/logo.
  Widget _storeInline(String storeId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
      builder: (context, snapshot) {
        final exists = snapshot.hasData && (snapshot.data?.exists ?? false);
        final data = exists ? snapshot.data!.data() : null;
        final l10n = AppLocalizations.of(context)!;
        final name = (data?['name'] as String?) ?? l10n.unknownStore;
        final logoUrl = (data?['logoUrl'] as String?);

        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                  ? NetworkImage(logoUrl)
                  : null,
              child: (logoUrl == null || logoUrl.isEmpty)
                  ? const Icon(Icons.storefront, size: 18, color: Colors.black38)
                  : null,
            ),
            const SizedBox(width: DesignTokens.space8),
            Expanded(
              child: Text(
                name,
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
