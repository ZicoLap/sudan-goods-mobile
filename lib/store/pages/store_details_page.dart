import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sudan_goods/cart/widgets/floating_cart_bar.dart';
import 'package:sudan_goods/models/store/store_model.dart';
import 'package:sudan_goods/store/widgets/collection_section.dart';
import 'package:sudan_goods/store/widgets/featured_product_section.dart';
import 'package:sudan_goods/store/widgets/store_cover_section.dart';
import 'package:sudan_goods/store/widgets/store_info_section.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class StoreDetailsPage extends StatelessWidget {
  final String storeId;
  const StoreDetailsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('stores')
                .doc(storeId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Store not found'));
          }

          final store = Store.fromDocument(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StoreCoverSection(store: store),
                StoreInfoSection(store: store),
                const SizedBox(height: 16),
                FeaturedProductsSection(storeId: storeId),
                const SizedBox(height: 16),
                CollectionsSection(storeId: storeId),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 32),
        child: FloatingCartBar(storeId: storeId),
      ),
    );
  }
}
