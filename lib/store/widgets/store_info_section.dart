
import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class StoreInfoSection extends StatelessWidget {
  final Store store;
  const StoreInfoSection({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to store info page or show modal
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                
                child: const Text('+ Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ],
          ),
          const SizedBox(height: 2),

          // Description
          if (store.description != null && store.description!.isNotEmpty)
          
            Row(
              children: [
                const Icon(Icons.description, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  store.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),

          const SizedBox(height: 2),

          // Min order and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                
              Row(
              
                children: [
                  const Icon(Icons.shopping_basket, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Min. Order: €${store.minimumOrderAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${store.rating.toStringAsFixed(1)} (${store.ratingCount})',
                   
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 2),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                '${store.address.country} / ${store.address.city}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
