// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:foodapp/models/item.dart';

class Restuarants {
  String name;
  String nameAr;
  List<Item> menuItems = [];
  String img;
  double rating;
  String category;
  String categoryAr;
  String deliveryTime;
  String deliveryFee;
  int ordersnum;
  String id;
  List<String> categories;
  List<String>? menuCategories;
  List<String>? menuCategoriesAr;

  // Updated location structure
  List<String>
      mainAreas; // List of areas where restaurant is physically located (no out-of-area fee)
  List<String>
      secondaryAreas; // List of areas they deliver to with out-of-area fee

  // Keep old fields for backward compatibility during migration
  String area;
  List<String> areas;

  String? outOfAreaFee; // Fee for delivery outside main areas

  Restuarants({
    required this.name,
    required this.nameAr,
    required this.menuItems,
    required this.img,
    required this.rating,
    required this.category,
    required this.categoryAr,
    required this.deliveryFee,
    required this.ordersnum,
    required this.deliveryTime,
    required this.id,
    required this.categories,
    this.menuCategories,
    this.menuCategoriesAr,
    this.mainAreas = const [], // List of main areas where restaurant is located
    this.secondaryAreas = const [], // Areas with out-of-area fee
    this.area = 'Cairo', // Keep for backward compatibility
    this.areas = const [], // Keep for backward compatibility
    this.outOfAreaFee = '0',
  }) {
    // Ensure categories is not null
    categories = categories.isEmpty ? ['Uncategorized'] : categories;

    // Migration logic: if using old structure, convert to new
    if (mainAreas.isEmpty && areas.isNotEmpty) {
      // Use first area as main area, rest as secondary
      mainAreas = [areas.first];
      secondaryAreas = areas.skip(1).toList();
    }

    // Ensure backward compatibility
    if (areas.isEmpty && (mainAreas.isNotEmpty || secondaryAreas.isNotEmpty)) {
      areas = [...mainAreas, ...secondaryAreas];
    }
    if (area == 'Cairo' && mainAreas.isNotEmpty) {
      area = mainAreas.first;
    }
  }

  Restuarants.fromJson(Map<String, dynamic> json)
      :
        // Initialize with safe defaults and validation
        name = json['resname']?.toString() ?? '',
        nameAr = json['namear']?.toString() ?? 'مطعم',
        id = json['id']?.toString() ?? '',
        img = json['img']?.toString() ?? 'assets/images/restuarants/store.jpg',
        rating = _parseRating(json['rating']),
        deliveryFee = _parseDeliveryFee(json['delivery fee']),
        deliveryTime = json['delivery time']?.toString() ?? '30-45 min',
        ordersnum = _parseOrdersNumber(json['ordersnumber']),
        category = json['category']?.toString() ?? 'fast food',
        categoryAr = json['categoryar']?.toString() ?? 'طعام سريع',
        categories = _parseCategories(json['categories']),
        menuCategories = _parseMenuCategories(json['menuCategories']),
        menuCategoriesAr = _parseMenuCategories(json['menuCategoriesAr']),

        // New location structure
        mainAreas = _parseAreas(json['mainAreas']) ??
            (json['mainArea'] != null ? [json['mainArea'].toString()] : []) ??
            (json['area'] != null ? [json['area'].toString()] : ['Cairo']),
        secondaryAreas = _parseAreas(json['secondaryAreas']),

        // Backward compatibility
        area = json['area']?.toString() ?? 'Cairo',
        areas = _parseAreas(json['areas']),
        outOfAreaFee = json['outOfAreaFee']?.toString() ?? '0' {
    try {
      // Parse menu items with error handling
      if (json['items'] is List) {
        menuItems = (json['items'] as List)
            .map((item) {
              try {
                return Item.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing menu item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<Item>()
            .toList();
      }

      // Validate required fields after initialization
      if (name.isEmpty) name = 'Unnamed Restaurant';
      if (nameAr.isEmpty) nameAr = 'مطعم بدون اسم';
      if (category.isEmpty) category = 'Uncategorized';
      if (categoryAr.isEmpty) categoryAr = 'غير مصنف';

      // Migration logic for backward compatibility
      if (mainAreas.isEmpty && areas.isNotEmpty) {
        mainAreas = [areas.first];
        secondaryAreas = areas.skip(1).toList();
      }

      // Ensure backward compatibility arrays are populated
      if (areas.isEmpty &&
          (mainAreas.isNotEmpty || secondaryAreas.isNotEmpty)) {
        areas = [...mainAreas, ...secondaryAreas];
      }
      if (area == 'Cairo' && mainAreas.isNotEmpty) {
        area = mainAreas.first;
      }
    } catch (e) {
      print('Error initializing restaurant from JSON: $e');
      rethrow;
    }
  }

  // Static helper methods for parsing JSON values
  static double _parseRating(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing rating: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  static String _parseDeliveryFee(dynamic value) {
    print("\n=== Parsing Restaurant Delivery Fee ===");
    print("Original Value: $value");

    if (value == null) {
      print("Value is null, returning 0");
      return '0';
    }

    // Handle different formats
    String fee = value.toString().trim();
    print("Trimmed Fee: $fee");

    // If empty, return 0
    if (fee.isEmpty) {
      print("Fee is empty, returning 0");
      return '0';
    }

    // Try to clean and parse the number
    try {
      String cleanFee = fee.replaceAll(RegExp(r'[^0-9.]'), '');
      print("Cleaned Fee: $cleanFee");

      if (cleanFee.isEmpty) {
        print("No valid numbers in fee, returning 0");
        return '0';
      }

      double parsedFee = double.parse(cleanFee);
      print("Parsed Fee: $parsedFee");

      if (parsedFee <= 0) {
        print("Fee is 0 or negative, returning 0");
        return '0';
      }

      print("Final Fee: $parsedFee");
      print("=== Parsing Complete ===\n");
      return parsedFee.toString(); // Return clean number string
    } catch (e) {
      print("Error parsing fee: $e");
      return '0';
    }
  }

  static int _parseOrdersNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('Error parsing orders number: $e');
        return 0;
      }
    }
    return 0;
  }

  static List<String> _parseCategories(dynamic value) {
    if (value == null) return ['Uncategorized'];
    if (value is List) {
      try {
        return List<String>.from(value);
      } catch (e) {
        print('Error parsing categories: $e');
        return ['Uncategorized'];
      }
    }
    return ['Uncategorized'];
  }

  static List<String>? _parseMenuCategories(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      try {
        return List<String>.from(value);
      } catch (e) {
        print('Error parsing menu categories: $e');
        return null;
      }
    }
    return null;
  }

  static List<String> _parseAreas(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return List<String>.from(value);
      } catch (e) {
        print('Error parsing areas: $e');
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'resname': name,
        'namear': nameAr,
        'id': id,
        'img': img,
        'rating': rating,
        'category': category,
        'categoryar': categoryAr,
        'delivery fee': deliveryFee,
        'delivery time': deliveryTime,
        'ordersnumber': ordersnum,
        'categories': categories,
        'menuCategories': menuCategories,
        'menuCategoriesAr': menuCategoriesAr,

        // New location structure
        'mainAreas': mainAreas,
        'secondaryAreas': secondaryAreas,

        // Backward compatibility
        'area': area,
        'areas': areas,

        'outOfAreaFee': outOfAreaFee,
        'items': menuItems.map((item) => item.toJson()).toList(),
      };
    } catch (e) {
      print('Error converting restaurant to JSON: $e');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'Restaurant: $name ($nameAr), ID: $id, Category: $category, Areas: $areas';
  }

  // Static empty restaurant for null-safety fallback
  static Restuarants empty() {
    return Restuarants(
      name: '',
      nameAr: '',
      menuItems: [],
      img: '',
      rating: 0.0,
      category: '',
      categoryAr: '',
      deliveryFee: '0',
      ordersnum: 0,
      deliveryTime: '',
      id: '',
      categories: [],
      menuCategories: [],
      menuCategoriesAr: [],
      mainAreas: [],
      secondaryAreas: [],
      area: 'Cairo',
      areas: [],
      outOfAreaFee: '0',
    );
  }
}
