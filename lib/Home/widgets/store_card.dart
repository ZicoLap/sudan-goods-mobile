import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const StoreCard({super.key, required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(

        width: 140,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child:
                    store.coverImageUrl != null
                        ? Image.network(store.coverImageUrl!, fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.store, size: 40),
                        ),
              ),
            ),
            const SizedBox(height: 6),

            // Store Name
           Container(
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border(
      left: BorderSide(color: Colors.grey.shade300),
      right: BorderSide(color: Colors.grey.shade300),
      bottom: BorderSide(color: Colors.grey.shade300),
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _truncateText(store.name, 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      Row(
        children: [
          const Icon(Icons.location_on, size: 14, color: Colors.red),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              _truncateText(store.address.city, 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ]
        ),
        ],
      ),
    ),
  ],
  ),
));

  }
  
    String _truncateText(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}...';
  }
  }
