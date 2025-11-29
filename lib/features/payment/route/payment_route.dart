// lib/features/payment/payment_route.dart
import 'package:flutter/material.dart';
import 'package:tenangin_mobile/features/payment/presentation/package_page.dart';
import '../presentation/payment_page.dart';

class PaymentRoute {
  static const path = "/payment";

  static Route<dynamic> go({
    required int sessionCount,
    required int pricePerSession,
  }) {
    return MaterialPageRoute(
      builder: (_) => TenanginPaymentPage(
        sessionCount: sessionCount,
        pricePerSession: pricePerSession,
      ),
    );
  }
}

class PackageRoute {
  static const path = "/package";

  // Method to navigate to the payment page with the threadId
  static Route<dynamic> go() {
    return MaterialPageRoute(
      builder: (_) => TenanginPackagePage(), // Pass threadId to the PaymentPage
    );
  }
  
}
