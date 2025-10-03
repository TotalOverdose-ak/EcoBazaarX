// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED - Using Spring Boot Backend
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class PaymentService {
  // DISABLED - Using Spring Boot Backend
  // All Firestore functionality has been moved to Spring Boot backend
  // This service is kept for compatibility but will be replaced with API calls

  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final CollectionReference _paymentsCollection = _firestore.collection('payments');
  // static final CollectionReference _transactionsCollection = _firestore.collection('transactions');
  // static final CollectionReference _refundsCollection = _firestore.collection('refunds');

  // Process payment (original method) - Now uses backend API
  static Future<Map<String, dynamic>> processPaymentOriginal({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required String userId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      print('🔄 Processing payment via backend...');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'paymentMethod': paymentMethod,
          'paymentGateway': 'razorpay',
          'amount': amount,
          'gatewayResponse': paymentDetails ?? {'success': true},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Payment processed: ${data['paymentId']}');
        return data;
      } else {
        print('❌ Payment failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Payment processing failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Payment error: $e');
      return {
        'success': false,
        'message': 'Payment error: $e',
      };
    }
  }

  // Get payment status - Backend API
  static Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      print('🔄 Fetching payment status: $paymentId');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Payment status: ${data['status']}');
        return data;
      } else if (response.statusCode == 404) {
        print('⚠️ Payment not found: $paymentId');
        return null;
      } else {
        print('❌ Failed to fetch payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching payment status: $e');
      return null;
    }
  }

  // Get user payments - Backend API
  static Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      print('🔄 Fetching user payments: $userId');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Loaded ${data.length} payments');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch payments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching user payments: $e');
      return [];
    }
  }

  // Get payment by ID - Backend API
  static Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    return await getPaymentStatus(paymentId);
  }

  // Refund payment - Backend API
  static Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      print('🔄 Processing refund: $paymentId');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/$paymentId/refund'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'reason': reason ?? 'Refund requested by user',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Refund processed: ${data['refundId']}');
        return data;
      } else {
        print('❌ Refund failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Refund processing failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Refund error: $e');
      return {
        'success': false,
        'message': 'Refund error: $e',
      };
    }
  }

  // Get payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    // Return predefined payment methods
    return [
      {
        'id': 'credit_card',
        'name': 'Credit Card',
        'icon': 'credit_card',
        'enabled': true,
      },
      {
        'id': 'debit_card',
        'name': 'Debit Card',
        'icon': 'account_balance',
        'enabled': true,
      },
      {
        'id': 'upi',
        'name': 'UPI',
        'icon': 'payment',
        'enabled': true,
      },
      {
        'id': 'net_banking',
        'name': 'Net Banking',
        'icon': 'account_balance',
        'enabled': true,
      },
      {
        'id': 'wallet',
        'name': 'Digital Wallet',
        'icon': 'account_balance_wallet',
        'enabled': true,
      },
    ];
  }

  // Validate payment details - Client-side validation
  static Future<Map<String, dynamic>> validatePaymentDetails(Map<String, dynamic> paymentDetails) async {
    try {
      // Basic validation
      if (paymentDetails.isEmpty) {
        return {
          'valid': false,
          'message': 'Payment details cannot be empty',
        };
      }

      final String? paymentMethod = paymentDetails['paymentMethod'];
      if (paymentMethod == null || paymentMethod.isEmpty) {
        return {
          'valid': false,
          'message': 'Payment method is required',
        };
      }

      final double? amount = paymentDetails['amount'];
      if (amount == null || amount <= 0) {
        return {
          'valid': false,
          'message': 'Invalid payment amount',
        };
      }

      print('✅ Payment details validated');
      return {
        'valid': true,
        'message': 'Payment details are valid',
      };
    } catch (e) {
      print('❌ Validation error: $e');
      return {
        'valid': false,
        'message': 'Validation error: $e',
      };
    }
  }

  // Get payment statistics - Backend API
  static Future<Map<String, dynamic>> getPaymentStatistics(String userId) async {
    try {
      print('🔄 Fetching payment statistics...');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Payment stats loaded');
        return data;
      } else {
        print('❌ Failed to fetch stats: ${response.statusCode}');
        return _getDefaultStats();
      }
    } catch (e) {
      print('❌ Error fetching stats: $e');
      return _getDefaultStats();
    }
  }

  // Get transaction history - Backend API (using user payments)
  static Future<List<Map<String, dynamic>>> getTransactionHistory(String userId, {int limit = 50}) async {
    try {
      final payments = await getUserPayments(userId);
      // Limit results if needed
      return payments.take(limit).toList();
    } catch (e) {
      print('❌ Error fetching transaction history: $e');
      return [];
    }
  }

  // Generate payment receipt - Creates receipt from payment data
  static Future<Map<String, dynamic>> generatePaymentReceipt(String paymentId) async {
    try {
      print('🔄 Generating receipt: $paymentId');
      
      final payment = await getPaymentStatus(paymentId);
      
      if (payment == null) {
        return {
          'success': false,
          'message': 'Payment not found',
        };
      }

      // Generate receipt data
      final receipt = {
        'success': true,
        'receiptId': 'RCPT_${DateTime.now().millisecondsSinceEpoch}',
        'paymentId': paymentId,
        'transactionId': payment['transactionId'],
        'orderId': payment['orderId'],
        'amount': payment['amount'],
        'paymentMethod': payment['paymentMethod'],
        'status': payment['status'],
        'date': payment['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      print('✅ Receipt generated: ${receipt['receiptId']}');
      return receipt;
    } catch (e) {
      print('❌ Receipt generation error: $e');
      return {
        'success': false,
        'message': 'Receipt generation error: $e',
      };
    }
  }

  // Get refund status - Same as payment status (checks if REFUNDED)
  static Future<Map<String, dynamic>?> getRefundStatus(String refundId) async {
    try {
      // Extract transaction ID from refund ID if needed
      final payment = await getPaymentStatus(refundId);
      return payment;
    } catch (e) {
      print('❌ Error fetching refund status: $e');
      return null;
    }
  }

  // Get user refunds - Filter refunded payments
  static Future<List<Map<String, dynamic>>> getUserRefunds(String userId) async {
    try {
      final payments = await getUserPayments(userId);
      final refunds = payments.where((p) => p['status'] == 'REFUNDED').toList();
      print('✅ Found ${refunds.length} refunds');
      return refunds;
    } catch (e) {
      print('❌ Error fetching refunds: $e');
      return [];
    }
  }

  // Calculate payment fees - Based on payment method
  static Future<Map<String, dynamic>> calculatePaymentFees({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      double feePercentage = 0.0;
      
      // Fee structure based on payment method
      switch (paymentMethod.toLowerCase()) {
        case 'credit_card':
        case 'debit_card':
          feePercentage = 0.02; // 2%
          break;
        case 'upi':
          feePercentage = 0.0; // Free
          break;
        case 'net_banking':
          feePercentage = 0.01; // 1%
          break;
        case 'wallet':
          feePercentage = 0.005; // 0.5%
          break;
        default:
          feePercentage = 0.02; // Default 2%
      }

      final fees = amount * feePercentage;
      final total = amount + fees;

      print('✅ Fees calculated: ₹$fees for $paymentMethod');
      return {
        'amount': amount,
        'fees': fees,
        'feePercentage': feePercentage * 100,
        'total': total,
        'paymentMethod': paymentMethod,
      };
    } catch (e) {
      print('❌ Fee calculation error: $e');
      return {
        'amount': amount,
        'fees': 0.0,
        'total': amount,
      };
    }
  }

  // Default statistics fallback
  static Map<String, dynamic> _getDefaultStats() {
    return {
      'totalPayments': 0,
      'completedPayments': 0,
      'failedPayments': 0,
      'totalAmount': 0.0,
    };
  }

  // Generate payment ID
  static String generatePaymentId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'PAY_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$random';
  }

  // Generate transaction ID
  static String generateTransactionId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'TXN_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$random';
  }

  // Create order (MySQL Backend Integration)
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required double totalAmount,
    required double taxAmount,
    required double shippingAmount,
    required double discountAmount,
    required double finalAmount,
    required String paymentMethod,
    String? deliveryNotes,
  }) async {
    try {
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final String orderId = generatePaymentId();
      
      // Create main order in MySQL
      final orderResponse = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'userEmail': userEmail,
          'userName': userName,
          'userPhone': userPhone,
          'totalAmount': totalAmount,
          'taxAmount': taxAmount,
          'shippingAmount': shippingAmount,
          'discountAmount': discountAmount,
          'finalAmount': finalAmount,
          'orderStatus': 'PENDING',
          'paymentStatus': 'PENDING',
          'paymentMethod': paymentMethod,
          'shippingAddress': '${shippingAddress['address']}, ${shippingAddress['city']}, ${shippingAddress['state']}, ${shippingAddress['pincode']}',
          'billingAddress': '${billingAddress['address']}, ${billingAddress['city']}, ${billingAddress['state']}, ${billingAddress['pincode']}',
          'deliveryNotes': deliveryNotes ?? '',
          'carbonFootprint': cartItems.fold(0.0, (sum, item) => sum + (item['carbonFootprint'] ?? 0.0)),
          'ecoPointsEarned': cartItems.fold<int>(0, (sum, item) => sum + (item['ecoPoints'] as int? ?? 0)),
          'currency': 'INR',
        }),
      );

      if (orderResponse.statusCode == 200) {
        final orderData = jsonDecode(orderResponse.body);
        print('🛍️ Order created successfully: $orderId');
        
        // Create order items (user_orders) for each cart item
        for (final item in cartItems) {
          final userOrderId = 'UO-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
          
          final userOrderResponse = await http.post(
            Uri.parse('$baseUrl/api/userorders'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userOrderId': userOrderId,
              'userId': userId,
              'orderId': orderId,
              'productId': item['productId'],
              'productName': item['productName'],
              'productPrice': item['price'],
              'quantity': item['quantity'],
              'totalAmount': item['price'] * item['quantity'],
              'storeId': item['storeId'] ?? 'STORE-001',
              'storeName': item['storeName'] ?? 'EcoStore',
              'orderStatus': 'PENDING',
            }),
          );
          
          if (userOrderResponse.statusCode == 200) {
            print('📦 Order item created: ${item['productName']}');
          } else {
            print('❌ Failed to create order item: ${item['productName']}');
          }
        }
        
        return {
          'success': true,
          'orderId': orderId,
          'message': 'Order created successfully',
          'orderData': orderData,
        };
      } else {
        print('❌ Failed to create order: ${orderResponse.statusCode} - ${orderResponse.body}');
        return {
          'success': false,
          'message': 'Failed to create order: ${orderResponse.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

  // Simulate Razorpay payment - Development/Testing
  static Future<Map<String, dynamic>> simulateRazorpayPayment({
    required double amount,
    required String currency,
    required String orderId,
  }) async {
    try {
      // Simulate payment delay
      await Future.delayed(const Duration(seconds: 2));
      
      // 90% success rate for simulation
      final isSuccess = Random().nextDouble() > 0.1;
      
      if (isSuccess) {
        print('✅ Simulated payment successful: $orderId');
        return {
          'success': true,
          'paymentId': generatePaymentId(),
          'orderId': orderId,
          'amount': amount,
          'currency': currency,
          'message': 'Payment successful (simulated)',
        };
      } else {
        print('❌ Simulated payment failed: $orderId');
        return {
          'success': false,
          'message': 'Payment failed (simulated)',
          'error': 'Insufficient funds',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Simulation error: $e',
      };
    }
  }

  // Cancel payment - Backend API
  static Future<Map<String, dynamic>> cancelPayment(String paymentId) async {
    try {
      print('🔄 Canceling payment: $paymentId');
      
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/$paymentId/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Payment canceled: $paymentId');
        return data;
      } else {
        print('❌ Cancel failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Payment cancellation failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Cancel error: $e');
      return {
        'success': false,
        'message': 'Cancel error: $e',
      };
    }
  }

  // Process payment (Spring Boot API implementation)
  static Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required String userId,
    required String paymentMethod,
    required String paymentGateway,
    required double amount,
    required Map<String, dynamic> gatewayResponse,
    String? failureReason,
  }) async {
    try {
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'paymentMethod': paymentMethod,
          'paymentGateway': paymentGateway,
          'amount': amount,
          'gatewayResponse': gatewayResponse,
          'failureReason': failureReason,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('💳 Payment processed successfully: ${data['paymentId']}');
        return data;
      } else {
        print('💳 Payment processing failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message': 'Payment processing failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💳 Error processing payment: $e');
      return {
        'success': false,
        'message': 'Error processing payment: $e',
      };
    }
  }
}