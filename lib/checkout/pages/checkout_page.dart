import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/checkout/controller/checkout_controller.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

import 'package:sudan_goods/models/store/store_model.dart';

import 'sections/checkout_user_info_section.dart';
import 'sections/checkout_address_section.dart';
import 'sections/checkout_note_section.dart';
import 'sections/checkout_store_section.dart';
import 'sections/checkout_summary_section.dart';

/// Checkout screen that reviews the order, captures payment method and note,
/// and places an order for a specific [Store].
///
/// Requires the [store], current [subtotal], and [totalWeight] which are used
/// to calculate delivery fee and total at the time of placing the order.
class CheckoutPage extends StatefulWidget {
  final Store store;
  final double subtotal;
  final double totalWeight;

  /// Creates a [CheckoutPage] bound to a particular [store].
  const CheckoutPage({
    super.key,
    required this.store,
    required this.subtotal,
    required this.totalWeight,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

/// State for [CheckoutPage] managing local UI state like payment method,
/// note input, and loading indicator.
class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController noteController = TextEditingController();

  @override
  /// Disposes text controllers to avoid memory leaks.
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  /// Triggers Stripe PaymentSheet via [CheckoutController].
  Future<void> _pay() async {
    await context.read<CheckoutController>().payAndPlaceOrder(
      context,
      store: widget.store,
      note: noteController.text,
    );
  }

  @override
  /// Builds the checkout UI composed of user info, address, note, payment,
  /// store items, and order summary sections, with a primary action button to
  /// place the order.
  Widget build(BuildContext context) {
    final isLoading = context.watch<CheckoutController>().isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.checkout,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _gradientBody(
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckoutUserInfoSection(),
              const CheckoutAddressSection(),
              CheckoutNoteSection(controller: noteController),
              CheckoutStoreSection(storeId: widget.store.id),
              CheckoutSummarySection(
                store: widget.store,
                subtotal: widget.subtotal,
                totalWeight: widget.totalWeight,
              ),
              const SizedBox(height: DesignTokens.space16),
              Opacity(
                opacity: isLoading ? 0.8 : 1.0,
                child: IgnorePointer(
                  ignoring: isLoading,
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: isLoading ? null : _pay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusRound,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.95),
                              AppColors.primary.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Pay',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientBody(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FBFF), Colors.white, Color(0xFFF8FBFF)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
