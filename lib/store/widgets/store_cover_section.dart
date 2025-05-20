
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class StoreCoverSection extends StatelessWidget {
  final Store store;
  const StoreCoverSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Cover Image
            Container(
              height: isTablet ? 400 : 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: store.coverImageUrl != null && store.coverImageUrl!.isNotEmpty
                      ? NetworkImage(store.coverImageUrl!)
                      : const AssetImage('assets/images/placeholder.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Store Logo (bottom left)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                      ? Image.network(store.logoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.storefront, size: 32),
                ),
              ),
            ),

            // Open/Closed Badge (bottom right)
            Positioned(
              bottom: 20,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: store.isOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  store.isOpen ? 'OPEN' : 'CLOSED',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}