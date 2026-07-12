import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  /// C1: true when the backend confirmed order creation within the poll window;
  /// false when we timed out (payment still went through, order will appear soon).
  final bool confirmed;

  const OrderSuccessPage({super.key, this.confirmed = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                confirmed ? Icons.check_circle : Icons.hourglass_top_rounded,
                color: confirmed ? Colors.green : Colors.orange,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                confirmed ? 'Order confirmed!' : 'Payment received!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                confirmed
                    ? 'Your order has been placed and will appear in your Orders tab shortly.'
                    : 'Your payment was received. Your order is being finalised and will appear in your Orders tab shortly.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Return to the root of the current tab's navigator
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
