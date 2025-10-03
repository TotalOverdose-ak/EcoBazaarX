import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class UserChallengeData {
  final String id;
  final String userId;
  final String challengeId;
  final String status; // NOT_STARTED, IN_PROGRESS, COMPLETED, PAUSED
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progressPercentage;
  final int pointsEarned;
  final String? notes;
  final String? proofUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserChallengeData({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.progressPercentage,
    required this.pointsEarned,
    this.notes,
    this.proofUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'status': status,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressPercentage': progressPercentage,
      'pointsEarned': pointsEarned,
      'notes': notes,
      'proofUrl': proofUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserChallengeData.fromMap(Map<String, dynamic> map) {
    return UserChallengeData(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      challengeId: map['challengeId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'NOT_STARTED',
      startedAt: map['startedAt'] != null ? DateTime.tryParse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
      progressPercentage: map['progressPercentage']?.toDouble() ?? 0.0,
      pointsEarned: map['pointsEarned']?.toInt() ?? 0,
      notes: map['notes']?.toString(),
      proofUrl: map['proofUrl']?.toString(),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}

class EcoChallengeData {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final int duration;
  final String difficultyLevel;
  final String icon;
  final String color;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxParticipants;
  final int currentParticipants;
  final String? imageUrl;
  final String? requirements;
  final String? rewards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EcoChallengeData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.duration,
    required this.difficultyLevel,
    required this.icon,
    required this.color,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.maxParticipants,
    required this.currentParticipants,
    this.imageUrl,
    this.requirements,
    this.rewards,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'duration': duration,
      'difficultyLevel': difficultyLevel,
      'icon': icon,
      'color': color,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'imageUrl': imageUrl,
      'requirements': requirements,
      'rewards': rewards,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EcoChallengeData.fromMap(Map<String, dynamic> map) {
    return EcoChallengeData(
      id: map['challengeId']?.toString() ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      points: map['rewardPoints']?.toInt() ?? map['points']?.toInt() ?? 100,
      duration: map['durationDays']?.toInt() ?? map['duration']?.toInt() ?? 30,
      difficultyLevel: map['difficulty']?.toString() ?? map['difficultyLevel']?.toString() ?? 'MEDIUM',
      icon: map['iconName']?.toString() ?? map['icon']?.toString() ?? '🌱',
      color: map['colorHex']?.toString() ?? map['color']?.toString() ?? '#4CAF50',
      isActive: map['isActive'] ?? true,
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      maxParticipants: map['maxParticipants']?.toInt(),
      currentParticipants: map['currentParticipants']?.toInt() ?? 0,
      imageUrl: map['imageUrl']?.toString(),
      requirements: map['requirements']?.toString(),
      rewards: map['reward']?.toString() ?? map['rewards']?.toString(),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}

class EcoChallengesService {
  // Get all eco challenges from backend
  static Future<List<EcoChallengeData>> getAllChallenges() async {
    try {
      print('🔄 Fetching eco challenges from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['challenges'] ?? [];
        final challenges = data.map((json) => EcoChallengeData.fromMap(json)).toList();
        print('✅ Loaded ${challenges.length} eco challenges from backend');
        return challenges;
      } else {
        print('❌ Failed to fetch challenges: ${response.statusCode}');
        return getSampleChallenges(); // Fallback to sample data
      }
    } catch (e) {
      print('❌ Error fetching challenges: $e');
      return getSampleChallenges(); // Fallback to sample data
    }
  }

  // Get active eco challenges from backend
  static Future<List<EcoChallengeData>> getActiveChallenges() async {
    try {
      print('🔄 Fetching active eco challenges from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/active'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final challenges = data.map((json) => EcoChallengeData.fromMap(json)).toList();
        print('✅ Loaded ${challenges.length} active eco challenges from backend');
        return challenges;
      } else {
        print('❌ Failed to fetch active challenges: ${response.statusCode}');
        return getSampleChallenges(); // Fallback to sample data
      }
    } catch (e) {
      print('❌ Error fetching active challenges: $e');
      return getSampleChallenges(); // Fallback to sample data
    }
  }

  // Get eco challenge by ID from backend
  static Future<EcoChallengeData?> getChallengeById(String challengeId) async {
    try {
      print('🔄 Fetching eco challenge by ID: $challengeId from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/$challengeId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final challenge = EcoChallengeData.fromMap(data);
        print('✅ Found eco challenge: ${challenge.title}');
        return challenge;
      } else {
        print('❌ Failed to fetch challenge: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching challenge: $e');
      return null;
    }
  }

  // Get eco challenges by category from backend
  static Future<List<EcoChallengeData>> getChallengesByCategory(String category) async {
    try {
      print('🔄 Fetching eco challenges for category: $category from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final challenges = data.map((json) => EcoChallengeData.fromMap(json)).toList();
        print('✅ Found ${challenges.length} eco challenges for category: $category');
        return challenges;
      } else {
        print('❌ Failed to fetch challenges by category: ${response.statusCode}');
        return getSampleChallenges().where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
      }
    } catch (e) {
      print('❌ Error fetching challenges by category: $e');
      return getSampleChallenges().where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
    }
  }

  // Initialize sample challenges (for fallback)
  static Future<void> initializeSampleChallenges() async {
    print('🔄 Initializing sample challenges...');
    // This is handled by the backend's DataInitializationService
    // No action needed here as the backend auto-initializes
    print('✅ Sample challenges initialization handled by backend');
  }

  // Get user progress (mock implementation - backend has this)
  static Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    print('🔄 Getting user progress for: $userId');
    // Mock user progress data
    return [
      {
        'challengeId': '1',
        'currentProgress': 15,
        'progressPercentage': 50.0,
        'isCompleted': false,
      },
      {
        'challengeId': '2',
        'currentProgress': 8,
        'progressPercentage': 80.0,
        'isCompleted': false,
      },
    ];
  }

  // Get user challenge stats (mock implementation - backend has this)
  static Future<Map<String, dynamic>> getUserChallengeStats(String userId) async {
    print('🔄 Getting user challenge stats for: $userId');
    return {
      'totalPoints': 150,
      'completedChallenges': 2,
      'activeChallenges': 3,
      'totalChallenges': 5,
    };
  }

  // Create new eco challenge (Admin)
  static Future<Map<String, dynamic>> createChallengeAdmin({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int rewardPoints,
    required int durationDays,
    String? iconName,
    String? colorHex,
    int? targetValue,
    String? targetUnit,
  }) async {
    try {
      print('🔄 Creating eco challenge: $title');
      final response = await http.post(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'category': category,
          'difficulty': difficulty.toUpperCase(),
          'targetValue': targetValue ?? 100,
          'targetUnit': targetUnit ?? 'points',
          'durationDays': durationDays,
          'reward': '$rewardPoints Eco Points',
          'rewardPoints': rewardPoints,
          'iconName': iconName ?? 'eco',
          'colorHex': colorHex ?? '#4CAF50',
          'isActive': true,
          'createdBy': 'admin',
        }),
      );
      
      print('📤 Response status: ${response.statusCode}');
      print('📤 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Created eco challenge: $title');
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Challenge created successfully',
          'challenge': responseData['challenge'] ?? responseData,
        };
      } else {
        print('❌ Failed to create challenge: ${response.statusCode}');
        print('❌ Error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to create challenge: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error creating challenge: $e');
      return {
        'success': false,
        'message': 'Error creating challenge: $e',
      };
    }
  }

  // Create new eco challenge (User - Legacy)
  static Future<Map<String, dynamic>> createChallenge({
    required String userId,
    required String title,
    required String description,
    required String reward,
    required Color color,
    required IconData icon,
    required int targetValue,
    required String targetUnit,
    required String category,
    required int durationDays,
  }) async {
    try {
      print('🔄 Creating eco challenge: $title');
      final response = await http.post(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'category': category,
          'points': targetValue,
          'duration': durationDays,
          'difficultyLevel': 'MEDIUM',
          'icon': _getIconString(icon),
          'color': _getColorString(color),
          'isActive': true,
        }),
      );
      
      if (response.statusCode == 201) {
        print('✅ Created eco challenge: $title');
        return {
          'success': true,
          'message': 'Challenge created successfully',
          'challenge': json.decode(response.body),
        };
      } else {
        print('❌ Failed to create challenge: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to create challenge',
        };
      }
    } catch (e) {
      print('❌ Error creating challenge: $e');
      return {
        'success': false,
        'message': 'Error creating challenge: $e',
      };
    }
  }

  // Update challenge progress (Legacy - use updateChallengeProgress instead)
  static Future<Map<String, dynamic>> updateChallengeProgressLegacy({
    required String userId,
    required String challengeId,
    required int progressValue,
  }) async {
    try {
      print('🔄 Updating challenge progress: $challengeId for user: $userId');
      final response = await http.put(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/challenge/$challengeId/progress'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'progressPercentage': progressValue.toDouble()}),
      );
      
      if (response.statusCode == 200) {
        print('✅ Updated challenge progress: $challengeId');
        return {
          'success': true,
          'message': 'Progress updated successfully',
        };
      } else {
        print('❌ Failed to update progress: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to update progress',
        };
      }
    } catch (e) {
      print('❌ Error updating progress: $e');
      return {
        'success': false,
        'message': 'Error updating progress: $e',
      };
    }
  }

  // Update eco challenge (Admin)
  static Future<Map<String, dynamic>> updateChallengeAdmin({
    required String challengeId,
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int rewardPoints,
    required int durationDays,
    String? iconName,
    String? colorHex,
    int? targetValue,
    String? targetUnit,
  }) async {
    try {
      print('🔄 Updating eco challenge: $challengeId');
      final response = await http.put(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/$challengeId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'category': category,
          'difficulty': difficulty.toUpperCase(),
          'targetValue': targetValue ?? 100,
          'targetUnit': targetUnit ?? 'points',
          'durationDays': durationDays,
          'reward': '$rewardPoints Eco Points',
          'rewardPoints': rewardPoints,
          'iconName': iconName ?? 'eco',
          'colorHex': colorHex ?? '#4CAF50',
          'createdBy': 'admin',
        }),
      );
      
      print('📤 Response status: ${response.statusCode}');
      print('📤 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Updated eco challenge: $challengeId');
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Challenge updated successfully',
          'challenge': responseData['challenge'] ?? responseData,
        };
      } else {
        print('❌ Failed to update challenge: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to update challenge: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error updating challenge: $e');
      return {
        'success': false,
        'message': 'Error updating challenge: $e',
      };
    }
  }

  // Delete eco challenge (Admin)
  static Future<Map<String, dynamic>> deleteChallengeAdmin({
    required String challengeId,
  }) async {
    try {
      print('🔄 Deleting eco challenge: $challengeId');
      final response = await http.delete(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/$challengeId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📤 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Deleted eco challenge: $challengeId');
        return {
          'success': true,
          'message': 'Challenge deleted successfully',
        };
      } else {
        print('❌ Failed to delete challenge: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to delete challenge: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error deleting challenge: $e');
      return {
        'success': false,
        'message': 'Error deleting challenge: $e',
      };
    }
  }

  // Toggle challenge status (Admin)
  static Future<Map<String, dynamic>> toggleChallengeStatus({
    required String challengeId,
    required bool isActive,
  }) async {
    try {
      print('🔄 Toggling challenge status: $challengeId to $isActive');
      final response = await http.put(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/$challengeId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'isActive': isActive,
        }),
      );
      
      print('📤 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Toggled challenge status: $challengeId');
        return {
          'success': true,
          'message': 'Challenge status updated successfully',
        };
      } else {
        print('❌ Failed to toggle status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to toggle status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error toggling status: $e');
      return {
        'success': false,
        'message': 'Error toggling status: $e',
      };
    }
  }

  // Delete eco challenge (Legacy)
  static Future<Map<String, dynamic>> deleteChallenge({
    required String challengeId,
    required String userId,
  }) async {
    try {
      print('🔄 Deleting eco challenge: $challengeId');
      final response = await http.delete(
        Uri.parse('${FirebaseConfig.baseApiUrl}/api/eco-challenges/$challengeId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 204) {
        print('✅ Deleted eco challenge: $challengeId');
        return {
          'success': true,
          'message': 'Challenge deleted successfully',
        };
      } else {
        print('❌ Failed to delete challenge: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to delete challenge',
        };
      }
    } catch (e) {
      print('❌ Error deleting challenge: $e');
      return {
        'success': false,
        'message': 'Error deleting challenge: $e',
      };
    }
  }

  // Helper methods
  static String _getIconString(IconData icon) {
    // Convert IconData to string representation
    final iconMap = {
      Icons.recycling_rounded: 'recycling_rounded',
      Icons.eco_rounded: 'eco_rounded',
      Icons.store_rounded: 'store_rounded',
      Icons.water_drop_rounded: 'water_drop_rounded',
      Icons.electric_bolt_rounded: 'electric_bolt_rounded',
      Icons.restaurant_rounded: 'restaurant_rounded',
      Icons.no_drinks_rounded: 'no_drinks_rounded',
      Icons.directions_bike_rounded: 'directions_bike_rounded',
      Icons.local_florist_rounded: 'local_florist_rounded',
      Icons.park_rounded: 'park_rounded',
      Icons.forest_rounded: 'forest_rounded',
      Icons.local_drink_rounded: 'local_drink_rounded',
      Icons.directions_bus_rounded: 'directions_bus_rounded',
      Icons.directions_walk_rounded: 'directions_walk_rounded',
      Icons.lightbulb_rounded: 'lightbulb_rounded',
      Icons.solar_power_rounded: 'solar_power_rounded',
      Icons.brush_rounded: 'brush_rounded',
      Icons.spa_rounded: 'spa_rounded',
      Icons.book_rounded: 'book_rounded',
      Icons.face_rounded: 'face_rounded',
      Icons.fitness_center_rounded: 'fitness_center_rounded',
      Icons.local_cafe_rounded: 'local_cafe_rounded',
    };
    
    return iconMap[icon] ?? 'eco_rounded';
  }

  static String _getColorString(Color color) {
    // Convert Color to hex string
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Get sample challenges (fallback data matching backend structure)
  static List<EcoChallengeData> getSampleChallenges() {
    return [
      EcoChallengeData(
        id: '1',
        title: '30-Day Plastic Free Challenge',
        description: 'Go 30 days without using single-use plastic products. This includes plastic bags, bottles, straws, and packaging.',
        category: 'Sustainability',
        points: 100,
        duration: 30,
        difficultyLevel: 'MEDIUM',
        icon: '🌱',
        color: '#4CAF50',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Avoid single-use plastic products for 30 days',
        rewards: 'Eco points and environmental impact reduction',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      EcoChallengeData(
        id: '2',
        title: 'Energy Saving Challenge',
        description: 'Reduce your energy consumption by 20% for 14 days. Use energy-efficient appliances and turn off unused devices.',
        category: 'Energy',
        points: 75,
        duration: 14,
        difficultyLevel: 'EASY',
        icon: '⚡',
        color: '#FF9800',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 14)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Reduce energy consumption by 20%',
        rewards: 'Energy savings and eco points',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      EcoChallengeData(
        id: '3',
        title: 'Zero Waste Week',
        description: 'Generate zero waste for 7 days. Compost organic waste, recycle properly, and avoid single-use items.',
        category: 'Waste Reduction',
        points: 50,
        duration: 7,
        difficultyLevel: 'HARD',
        icon: '♻️',
        color: '#2196F3',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Generate zero waste for 7 days',
        rewards: 'Waste reduction and eco points',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      EcoChallengeData(
        id: '4',
        title: 'Plant-Based Diet Challenge',
        description: 'Follow a plant-based diet for 21 days. Reduce your carbon footprint through dietary choices.',
        category: 'Food & Diet',
        points: 80,
        duration: 21,
        difficultyLevel: 'MEDIUM',
        icon: '🥗',
        color: '#8BC34A',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 21)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Follow plant-based diet for 21 days',
        rewards: 'Health benefits and eco points',
        createdAt: DateTime.now().subtract(Duration(days: 4)),
        updatedAt: DateTime.now(),
      ),
      EcoChallengeData(
        id: '5',
        title: 'Water Conservation Challenge',
        description: 'Reduce water usage by 30% for 14 days. Take shorter showers, fix leaks, and use water-efficient appliances.',
        category: 'Water Conservation',
        points: 60,
        duration: 14,
        difficultyLevel: 'EASY',
        icon: '💧',
        color: '#00BCD4',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 14)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Reduce water usage by 30%',
        rewards: 'Water savings and eco points',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      EcoChallengeData(
        id: '6',
        title: 'Sustainable Transportation',
        description: 'Use only eco-friendly transportation for 30 days. Walk, bike, use public transport, or carpool.',
        category: 'Transportation',
        points: 90,
        duration: 30,
        difficultyLevel: 'HARD',
        icon: '🚲',
        color: '#9C27B0',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        maxParticipants: 100,
        currentParticipants: 0,
        imageUrl: null,
        requirements: 'Use only eco-friendly transportation',
        rewards: 'Carbon footprint reduction and eco points',
        createdAt: DateTime.now().subtract(Duration(days: 6)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // User Challenge Methods

  // Get user challenges from backend
  static Future<List<UserChallengeData>> getUserChallenges(String userId) async {
    try {
      print('🔄 Fetching user challenges for user: $userId from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final userChallenges = data.map((json) => UserChallengeData.fromMap(json)).toList();
        print('✅ Loaded ${userChallenges.length} user challenges from backend');
        return userChallenges;
      } else {
        print('❌ Failed to fetch user challenges: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching user challenges: $e');
      return [];
    }
  }

  // Join challenge
  static Future<UserChallengeData?> joinChallenge(String userId, String challengeId) async {
    try {
      print('🔄 Joining challenge $challengeId for user $userId...');
      final response = await http.post(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/join/$challengeId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final userChallenge = UserChallengeData.fromMap(data);
        print('✅ Successfully joined challenge: ${userChallenge.id}');
        return userChallenge;
      } else {
        print('❌ Failed to join challenge: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error joining challenge: $e');
      return null;
    }
  }

  // Update challenge progress
  static Future<UserChallengeData?> updateChallengeProgress(
    String userId, 
    String challengeId, 
    double progressPercentage,
    {String? notes, String? proofUrl}
  ) async {
    try {
      print('🔄 Updating challenge progress for user $userId, challenge $challengeId...');
      
      // Build URL with query parameters
      String url = '${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/challenge/$challengeId/progress?progressPercentage=${progressPercentage.toInt()}';
      if (notes != null) {
        url += '&notes=${Uri.encodeComponent(notes)}';
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final userChallenge = UserChallengeData.fromMap(data);
        print('✅ Successfully updated challenge progress: ${userChallenge.progressPercentage}%');
        return userChallenge;
      } else {
        print('❌ Failed to update challenge progress: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating challenge progress: $e');
      return null;
    }
  }

  // Complete challenge
  static Future<UserChallengeData?> completeChallenge(
    String userId, 
    String challengeId,
    {String? notes, String? proofUrl}
  ) async {
    try {
      print('🔄 Completing challenge $challengeId for user $userId...');
      
      final Map<String, dynamic> completionData = {};
      if (notes != null) completionData['notes'] = notes;
      if (proofUrl != null) completionData['proofUrl'] = proofUrl;

      final response = await http.put(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/challenge/$challengeId/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(completionData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final userChallenge = UserChallengeData.fromMap(data);
        print('✅ Successfully completed challenge! Points earned: ${userChallenge.pointsEarned}');
        return userChallenge;
      } else {
        print('❌ Failed to complete challenge: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error completing challenge: $e');
      return null;
    }
  }

  // Quit challenge  
  static Future<bool> quitChallenge(String userId, String challengeId) async {
    try {
      print('🔄 Quitting challenge $challengeId for user $userId...');
      final response = await http.put(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/challenge/$challengeId/quit'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        print('✅ Successfully quit challenge');
        return true;
      } else {
        print('❌ Failed to quit challenge: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error quitting challenge: $e');
      return false;
    }
  }

  // Get user challenges by status
  static Future<List<UserChallengeData>> getUserChallengesByStatus(String userId, String status) async {
    try {
      print('🔄 Fetching user challenges with status $status for user: $userId from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/status/$status'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final userChallenges = data.map((json) => UserChallengeData.fromMap(json)).toList();
        print('✅ Loaded ${userChallenges.length} user challenges with status $status');
        return userChallenges;
      } else {
        print('❌ Failed to fetch user challenges by status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching user challenges by status: $e');
      return [];
    }
  }

  // Get completed user challenges
  static Future<List<UserChallengeData>> getCompletedUserChallenges(String userId) async {
    return getUserChallengesByStatus(userId, 'COMPLETED');
  }

  // Get in-progress user challenges
  static Future<List<UserChallengeData>> getInProgressUserChallenges(String userId) async {
    return getUserChallengesByStatus(userId, 'IN_PROGRESS');
  }

  // Get specific user challenge
  static Future<UserChallengeData?> getUserChallenge(String userId, String challengeId) async {
    try {
      print('🔄 Fetching user challenge for user $userId, challenge $challengeId from backend...');
      final response = await http.get(
        Uri.parse('${FirebaseConfig.baseApiUrl}/eco-challenges/user/$userId/challenge/$challengeId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final userChallenge = UserChallengeData.fromMap(data);
        print('✅ Loaded user challenge: ${userChallenge.id}');
        return userChallenge;
      } else {
        print('❌ Failed to fetch user challenge: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user challenge: $e');
      return null;
    }
  }
}