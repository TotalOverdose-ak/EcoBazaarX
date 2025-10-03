import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class CarbonFootprintService {
  static const String baseUrl = '${FirebaseConfig.baseApiUrl}/api/carbon-footprint';

  // Calculate carbon footprint for a product
  static Future<Map<String, dynamic>> calculateCarbonFootprint({
    required String userId,
    required String productId,
    required String productName,
    required String category,
    required String materials,
    required double weight,
    required String transportMode,
    required double transportDistance,
    required String manufacturingType,
    required String packagingType,
    required double packagingWeight,
    required String disposalMethod,
  }) async {
    try {
      print('🔄 Calculating carbon footprint from backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'productName': productName,
          'category': category,
          'materials': materials,
          'weight': weight,
          'transportMode': transportMode,
          'transportDistance': transportDistance,
          'manufacturingType': manufacturingType,
          'packagingType': packagingType,
          'packagingWeight': packagingWeight,
          'disposalMethod': disposalMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Carbon footprint calculated: ${data['totalCarbonFootprint']} kg CO2');
        return data;
      } else {
        print('❌ Failed to calculate carbon footprint: ${response.statusCode}');
        throw Exception('Failed to calculate carbon footprint: ${response.body}');
      }
    } catch (e) {
      print('❌ Error calculating carbon footprint: $e');
      rethrow;
    }
  }

  // Get user's carbon footprint history
  static Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    try {
      print('🔄 Fetching user carbon history from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} carbon footprint records');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch carbon history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching carbon history: $e');
      return [];
    }
  }

  // Get user's carbon statistics
  static Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      print('🔄 Fetching user carbon statistics from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Loaded carbon statistics');
        return data;
      } else {
        print('❌ Failed to fetch carbon statistics: ${response.statusCode}');
        return _getDefaultStatistics();
      }
    } catch (e) {
      print('❌ Error fetching carbon statistics: $e');
      return _getDefaultStatistics();
    }
  }

  // Initialize emission factors in backend
  static Future<bool> initializeEmissionFactors() async {
    try {
      print('🔄 Initializing emission factors in backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/initialize-emission-factors'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Emission factors initialized successfully');
        return true;
      } else {
        print('❌ Failed to initialize emission factors: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing emission factors: $e');
      return false;
    }
  }

  // Check backend health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend health check failed: $e');
      return false;
    }
  }

  // Default statistics when backend is unavailable
  static Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalCalculations': 0,
      'totalCarbonFootprint': 0.0,
      'totalCarbonSavings': 0.0,
      'averageCarbonFootprint': 0.0,
      'averageSavingsPercentage': 0.0,
      'totalTreesEquivalent': 0.0,
      'totalCarKmEquivalent': 0.0,
      'totalElectricityEquivalent': 0.0,
      'totalPlasticBottlesEquivalent': 0,
      'ecoRatingDistribution': {
        'A+': 0,
        'A': 0,
        'B': 0,
        'C': 0,
        'D': 0,
        'F': 0,
      },
      'categoryCarbonSavings': {},
      'monthlyTrend': [],
    };
  }

  // Compare carbon footprint of multiple products
  static Future<Map<String, dynamic>> compareProducts(List<String> productIds) async {
    try {
      print('🔄 Comparing ${productIds.length} products...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/compare'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'productIds': productIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Products compared successfully');
        return data['comparison'] ?? data;
      } else {
        print('❌ Failed to compare products: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to compare products',
          'products': [],
        };
      }
    } catch (e) {
      print('❌ Error comparing products: $e');
      return {
        'success': false,
        'message': 'Error comparing products: $e',
        'products': [],
      };
    }
  }

  // Get category benchmark
  static Future<Map<String, dynamic>> getCategoryBenchmark(String category) async {
    try {
      print('🔄 Fetching benchmark for category: $category');
      
      final response = await http.get(
        Uri.parse('$baseUrl/category/$category/benchmark'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Benchmark loaded for $category');
        return data;
      } else {
        print('❌ Failed to fetch benchmark: ${response.statusCode}');
        return {
          'category': category,
          'averageFootprint': 0.0,
          'lowestFootprint': 0.0,
          'highestFootprint': 0.0,
          'totalProducts': 0,
        };
      }
    } catch (e) {
      print('❌ Error fetching benchmark: $e');
      return {
        'category': category,
        'averageFootprint': 0.0,
        'lowestFootprint': 0.0,
        'highestFootprint': 0.0,
        'totalProducts': 0,
      };
    }
  }

  // Get carbon footprint leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      print('🔄 Fetching carbon footprint leaderboard...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Leaderboard loaded: ${data.length} entries');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching leaderboard: $e');
      return [];
    }
  }

  // Get all categories with statistics
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      print('🔄 Fetching all categories...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Categories loaded: ${data.length} categories');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

  // Get sustainability tips by category
  static Future<List<String>> getSustainabilityTips(String category) async {
    try {
      print('🔄 Fetching sustainability tips for $category...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/tips/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tips = data['tips'] ?? [];
        print('✅ Tips loaded: ${tips.length} tips');
        return tips.cast<String>();
      } else {
        print('❌ Failed to fetch tips: ${response.statusCode}');
        return _getDefaultTips(category);
      }
    } catch (e) {
      print('❌ Error fetching tips: $e');
      return _getDefaultTips(category);
    }
  }

  // Default tips fallback
  static List<String> _getDefaultTips(String category) {
    return [
      'Choose products with minimal packaging',
      'Buy locally made products to reduce transportation emissions',
      'Look for recycled or sustainable materials',
      'Consider the product\'s full lifecycle before purchasing',
      'Properly dispose of products through recycling or composting',
    ];
  }
}
