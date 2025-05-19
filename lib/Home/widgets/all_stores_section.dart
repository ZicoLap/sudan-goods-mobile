import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudan_goods/Home/services/store_service.dart';
import 'package:sudan_goods/Home/widgets/big_store_card.dart';
import 'package:sudan_goods/models/store/store_model.dart';

class AllStoresSection extends StatelessWidget {
  const AllStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'All Stores',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Real-time store list
        StreamBuilder<List<Store>>(
          stream: StoreServices().streamAllApprovedStores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load stores'));
            }

            final stores = snapshot.data ?? [];

            if (stores.isEmpty) {
              return const Center(child: Text('No stores available'));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                return BigStoreCard(
                  store: stores[index],
                  onTap: () {
                    // TODO: Navigate to StoreDetailsPage
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
