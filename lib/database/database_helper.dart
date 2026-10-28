import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

import '../models/brand.dart';
import '../models/computer.dart';
import '../models/computer_filter_options.dart';
import '../models/product_category.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static const String databaseName = 'ComputerStoreDB.db';
  static const int _databaseVersion = 1;
  static final DatabaseHelper instance = DatabaseHelper._();

  static bool _ffiInitialized = false;
  sqflite.Database? _database;
  String? _databasePathOverride;

  static void ensureInitialized() {
    if (kIsWeb || _ffiInitialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      ffi.sqfliteFfiInit();
      sqflite.databaseFactory = ffi.databaseFactoryFfi;
      _ffiInitialized = true;
    }
  }

  Future<sqflite.Database> get database async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;
    ensureInitialized();
    final databasesPath = await sqflite.getDatabasesPath();
    final databasePath =
        _databasePathOverride ?? p.join(databasesPath, databaseName);
    final opened = await sqflite.openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDatabase,
    );
    _database = opened;
    return opened;
  }

  Future<void> _createDatabase(sqflite.Database db, int version) async {
    // openDatabase runs onCreate inside its own transaction. Starting another
    // transaction here can deadlock on Android's sqflite implementation.
    final sqflite.DatabaseExecutor txn = db;
    await txn.execute('''
        CREATE TABLE brands (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          brand_name TEXT NOT NULL COLLATE NOCASE UNIQUE,
          country TEXT NOT NULL,
          founded_year INTEGER NOT NULL CHECK (founded_year > 1900)
        )
      ''');
    await txn.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_name TEXT NOT NULL COLLATE NOCASE UNIQUE
        )
      ''');
    await txn.execute('''
        CREATE TABLE computers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_name TEXT NOT NULL COLLATE NOCASE UNIQUE,
          brand_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          cpu TEXT NOT NULL,
          ram INTEGER NOT NULL CHECK (ram BETWEEN 4 AND 128),
          storage INTEGER NOT NULL CHECK (storage BETWEEN 128 AND 4096),
          price REAL NOT NULL CHECK (price > 0),
          stock INTEGER NOT NULL CHECK (stock >= 0),
          sold_quantity INTEGER NOT NULL CHECK (sold_quantity >= 0),
          is_featured INTEGER NOT NULL DEFAULT 0 CHECK (is_featured IN (0, 1)),
          FOREIGN KEY (brand_id) REFERENCES brands(id)
            ON UPDATE CASCADE ON DELETE RESTRICT,
          FOREIGN KEY (category_id) REFERENCES categories(id)
            ON UPDATE CASCADE ON DELETE RESTRICT
        )
      ''');
    await txn.execute(
      'CREATE INDEX idx_computers_brand_id ON computers(brand_id)',
    );
    await txn.execute(
      'CREATE INDEX idx_computers_category_id ON computers(category_id)',
    );
    await txn.execute(
      'CREATE INDEX idx_computers_featured ON computers(is_featured)',
    );
    await _insertSampleData(txn);
  }

  Future<void> _insertSampleData(sqflite.DatabaseExecutor txn) async {
    final brandIds = <String, int>{};
    const brands = <Map<String, Object>>[
      {'brand_name': 'ASUS', 'country': 'Taiwan', 'founded_year': 1989},
      {'brand_name': 'Acer', 'country': 'Taiwan', 'founded_year': 1976},
      {'brand_name': 'Dell', 'country': 'United States', 'founded_year': 1984},
      {'brand_name': 'HP', 'country': 'United States', 'founded_year': 1939},
      {'brand_name': 'Lenovo', 'country': 'China', 'founded_year': 1984},
    ];
    for (final brand in brands) {
      final id = await txn.insert('brands', brand);
      brandIds[brand['brand_name'] as String] = id;
    }

    final categoryIds = <String, int>{};
    const categories = <String>['Laptop', 'Desktop', 'Component'];
    for (final category in categories) {
      final id = await txn.insert('categories', <String, Object>{
        'category_name': category,
      });
      categoryIds[category] = id;
    }
    int brandId(String name) => brandIds[name] ?? 0;
    int categoryId(String name) => categoryIds[name] ?? 0;

    final computers = <Map<String, Object>>[
      {
        'product_name': 'ROG Strix G16',
        'brand_id': brandId('ASUS'),
        'category_id': categoryId('Laptop'),
        'cpu': 'Intel Core i7',
        'ram': 16,
        'storage': 1000,
        'price': 1250.0,
        'stock': 15,
        'sold_quantity': 32,
        'is_featured': 1,
      },
      {
        'product_name': 'Vivobook S15',
        'brand_id': brandId('ASUS'),
        'category_id': categoryId('Laptop'),
        'cpu': 'Intel Core i5',
        'ram': 16,
        'storage': 512,
        'price': 899.0,
        'stock': 10,
        'sold_quantity': 20,
        'is_featured': 1,
      },
      {
        'product_name': 'TUF Gaming A15',
        'brand_id': brandId('ASUS'),
        'category_id': categoryId('Laptop'),
        'cpu': 'AMD Ryzen 7',
        'ram': 16,
        'storage': 1000,
        'price': 1099.0,
        'stock': 4,
        'sold_quantity': 28,
        'is_featured': 1,
      },
      {
        'product_name': 'Aspire 5',
        'brand_id': brandId('Acer'),
        'category_id': categoryId('Laptop'),
        'cpu': 'Intel Core i5',
        'ram': 8,
        'storage': 512,
        'price': 649.0,
        'stock': 20,
        'sold_quantity': 18,
        'is_featured': 0,
      },
      {
        'product_name': 'Predator Orion',
        'brand_id': brandId('Acer'),
        'category_id': categoryId('Desktop'),
        'cpu': 'Intel Core i7',
        'ram': 32,
        'storage': 2048,
        'price': 1799.0,
        'stock': 3,
        'sold_quantity': 12,
        'is_featured': 1,
      },
      {
        'product_name': 'Veriton X',
        'brand_id': brandId('Acer'),
        'category_id': categoryId('Desktop'),
        'cpu': 'Intel Core i5',
        'ram': 16,
        'storage': 512,
        'price': 799.0,
        'stock': 0,
        'sold_quantity': 14,
        'is_featured': 0,
      },
      {
        'product_name': 'XPS 15',
        'brand_id': brandId('Dell'),
        'category_id': categoryId('Laptop'),
        'cpu': 'Intel Core i7',
        'ram': 32,
        'storage': 1000,
        'price': 1599.0,
        'stock': 7,
        'sold_quantity': 22,
        'is_featured': 1,
      },
      {
        'product_name': 'Inspiron Desktop',
        'brand_id': brandId('Dell'),
        'category_id': categoryId('Desktop'),
        'cpu': 'Intel Core i5',
        'ram': 16,
        'storage': 1000,
        'price': 899.0,
        'stock': 12,
        'sold_quantity': 16,
        'is_featured': 0,
      },
      {
        'product_name': 'Alienware Aurora',
        'brand_id': brandId('Dell'),
        'category_id': categoryId('Desktop'),
        'cpu': 'Intel Core i9',
        'ram': 64,
        'storage': 2048,
        'price': 2499.0,
        'stock': 2,
        'sold_quantity': 30,
        'is_featured': 1,
      },
      {
        'product_name': 'Pavilion 15',
        'brand_id': brandId('HP'),
        'category_id': categoryId('Laptop'),
        'cpu': 'AMD Ryzen 5',
        'ram': 8,
        'storage': 512,
        'price': 699.0,
        'stock': 17,
        'sold_quantity': 25,
        'is_featured': 0,
      },
      {
        'product_name': 'OMEN 45L',
        'brand_id': brandId('HP'),
        'category_id': categoryId('Desktop'),
        'cpu': 'AMD Ryzen 9',
        'ram': 64,
        'storage': 2048,
        'price': 2299.0,
        'stock': 4,
        'sold_quantity': 19,
        'is_featured': 1,
      },
      {
        'product_name': 'ProDesk 400',
        'brand_id': brandId('HP'),
        'category_id': categoryId('Desktop'),
        'cpu': 'Intel Core i5',
        'ram': 16,
        'storage': 512,
        'price': 749.0,
        'stock': 9,
        'sold_quantity': 11,
        'is_featured': 0,
      },
      {
        'product_name': 'ThinkPad X1',
        'brand_id': brandId('Lenovo'),
        'category_id': categoryId('Laptop'),
        'cpu': 'Intel Core i7',
        'ram': 16,
        'storage': 1000,
        'price': 1499.0,
        'stock': 6,
        'sold_quantity': 27,
        'is_featured': 1,
      },
      {
        'product_name': 'Legion Tower 5',
        'brand_id': brandId('Lenovo'),
        'category_id': categoryId('Desktop'),
        'cpu': 'AMD Ryzen 7',
        'ram': 32,
        'storage': 1024,
        'price': 1399.0,
        'stock': 5,
        'sold_quantity': 23,
        'is_featured': 1,
      },
      {
        'product_name': 'RTX 4060 Graphics Card',
        'brand_id': brandId('Lenovo'),
        'category_id': categoryId('Component'),
        'cpu': 'NVIDIA RTX 4060',
        'ram': 8,
        'storage': 256,
        'price': 499.0,
        'stock': 0,
        'sold_quantity': 40,
        'is_featured': 1,
      },
    ];
    for (final computer in computers) {
      await txn.insert('computers', computer);
    }
  }

  Future<List<Brand>> getBrands({String query = ''}) async {
    final db = await database;
    final keyword = query.trim();
    final where = keyword.isEmpty
        ? ''
        : 'WHERE LOWER(b.brand_name) LIKE LOWER(?) '
              'OR LOWER(b.country) LIKE LOWER(?)';
    final args = keyword.isEmpty
        ? <Object?>[]
        : <Object?>['%$keyword%', '%$keyword%'];
    final rows = await db.rawQuery('''
      SELECT b.id, b.brand_name, b.country, b.founded_year,
             COUNT(c.id) AS total_products
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      $where
      GROUP BY b.id, b.brand_name, b.country, b.founded_year
      ORDER BY b.brand_name COLLATE NOCASE ASC
    ''', args);
    return rows.map(Brand.fromMap).toList(growable: false);
  }

  Future<bool> isBrandNameUnique(String name, {int? excludeId}) async {
    final db = await database;
    final where = StringBuffer('LOWER(TRIM(brand_name)) = LOWER(TRIM(?))');
    final args = <Object?>[name];
    if (excludeId != null) {
      where.write(' AND id <> ?');
      args.add(excludeId);
    }
    final rows = await db.query(
      'brands',
      columns: const ['COUNT(*) AS total'],
      where: where.toString(),
      whereArgs: args,
    );
    return _intValue(rows.firstOrNull?['total']) == 0;
  }

  Future<int> insertBrand(Brand brand) async {
    final db = await database;
    final values = Map<String, Object?>.from(brand.toMap())..remove('id');
    return db.insert(
      'brands',
      values,
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<int> updateBrand(Brand brand) async {
    final id = brand.id;
    if (id == null) throw ArgumentError('Brand id is required for update.');
    final db = await database;
    final values = Map<String, Object?>.from(brand.toMap())..remove('id');
    return db.update('brands', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getBrandUsageCount(int brandId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM computers WHERE brand_id = ?',
      [brandId],
    );
    return _intValue(rows.firstOrNull?['total']);
  }

  Future<int> deleteBrand(int id) async {
    final db = await database;
    return db.delete('brands', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductCategory>> getCategories({String query = ''}) async {
    final db = await database;
    final keyword = query.trim();
    final where = keyword.isEmpty
        ? ''
        : 'WHERE LOWER(ca.category_name) LIKE LOWER(?)';
    final args = keyword.isEmpty ? <Object?>[] : <Object?>['%$keyword%'];
    final rows = await db.rawQuery('''
      SELECT ca.id, ca.category_name, COUNT(c.id) AS total_products
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      $where
      GROUP BY ca.id, ca.category_name
      ORDER BY ca.category_name COLLATE NOCASE ASC
    ''', args);
    return rows.map(ProductCategory.fromMap).toList(growable: false);
  }

  Future<bool> isCategoryNameUnique(String name, {int? excludeId}) async {
    final db = await database;
    final where = StringBuffer('LOWER(TRIM(category_name)) = LOWER(TRIM(?))');
    final args = <Object?>[name];
    if (excludeId != null) {
      where.write(' AND id <> ?');
      args.add(excludeId);
    }
    final rows = await db.query(
      'categories',
      columns: const ['COUNT(*) AS total'],
      where: where.toString(),
      whereArgs: args,
    );
    return _intValue(rows.firstOrNull?['total']) == 0;
  }

  Future<int> insertCategory(ProductCategory category) async {
    final db = await database;
    final values = Map<String, Object?>.from(category.toMap())..remove('id');
    return db.insert(
      'categories',
      values,
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<int> updateCategory(ProductCategory category) async {
    final id = category.id;
    if (id == null) {
      throw ArgumentError('Category id is required for update.');
    }
    final db = await database;
    final values = Map<String, Object?>.from(category.toMap())..remove('id');
    return db.update('categories', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCategoryUsageCount(int categoryId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM computers WHERE category_id = ?',
      [categoryId],
    );
    return _intValue(rows.firstOrNull?['total']);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Computer>> getComputers({
    String keyword = '',
    int? brandId,
    int? categoryId,
    bool featuredOnly = false,
    String? stockStatus,
    String? ramOption,
    String? storageOption,
    String? priceOption,
    String sortOption = ComputerFilterOptions.sortNameAsc,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <Object?>[];
    final search = keyword.trim();

    if (search.isNotEmpty) {
      conditions.add('''
        (LOWER(c.product_name) LIKE LOWER(?) OR
         LOWER(b.brand_name) LIKE LOWER(?) OR
         LOWER(c.cpu) LIKE LOWER(?))
      ''');
      final pattern = '%$search%';
      args.addAll([pattern, pattern, pattern]);
    }
    if (brandId != null) {
      conditions.add('c.brand_id = ?');
      args.add(brandId);
    }
    if (categoryId != null) {
      conditions.add('c.category_id = ?');
      args.add(categoryId);
    }
    if (featuredOnly) conditions.add('c.is_featured = 1');

    if (stockStatus == ComputerFilterOptions.stockInStock ||
        stockStatus == 'In Stock') {
      conditions.add('c.stock > 0');
    } else if (stockStatus == ComputerFilterOptions.stockLowStock ||
        stockStatus == 'Low Stock') {
      conditions.add('c.stock < 5');
    } else if (stockStatus == ComputerFilterOptions.stockOutOfStock ||
        stockStatus == 'Out of Stock') {
      conditions.add('c.stock = 0');
    }

    if (ramOption == ComputerFilterOptions.ram8 || ramOption == '8 GB') {
      conditions.add('c.ram = 8');
    } else if (ramOption == ComputerFilterOptions.ram16 ||
        ramOption == '16 GB') {
      conditions.add('c.ram = 16');
    } else if (ramOption == ComputerFilterOptions.ram32Plus ||
        ramOption == '32 GB or above' ||
        ramOption == '32+ GB') {
      conditions.add('c.ram >= 32');
    }

    if (storageOption == ComputerFilterOptions.storage256 ||
        storageOption == '256 GB') {
      conditions.add('c.storage = 256');
    } else if (storageOption == ComputerFilterOptions.storage512 ||
        storageOption == '512 GB') {
      conditions.add('c.storage = 512');
    } else if (storageOption == ComputerFilterOptions.storage1Tb ||
        storageOption == '1 TB') {
      conditions.add('c.storage IN (1000, 1024)');
    } else if (storageOption == ComputerFilterOptions.storage2TbPlus ||
        storageOption == '2 TB+') {
      conditions.add('c.storage >= 2000');
    }

    if (priceOption == ComputerFilterOptions.priceUnder500 ||
        priceOption == 'Less than 500') {
      conditions.add('c.price < 500');
    } else if (priceOption == ComputerFilterOptions.price500To1000 ||
        priceOption == '500 - 1000' ||
        priceOption == '500 – 1000') {
      conditions.add('c.price BETWEEN 500 AND 1000');
    } else if (priceOption == ComputerFilterOptions.priceOver1000 ||
        priceOption == 'Greater than 1000') {
      conditions.add('c.price > 1000');
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    const sortClauses = <String, String>{
      ComputerFilterOptions.sortNameAsc: 'c.product_name COLLATE NOCASE ASC',
      ComputerFilterOptions.sortNameDesc: 'c.product_name COLLATE NOCASE DESC',
      ComputerFilterOptions.sortPriceAsc: 'c.price ASC',
      ComputerFilterOptions.sortPriceDesc: 'c.price DESC',
      ComputerFilterOptions.sortSoldAsc: 'c.sold_quantity ASC',
      ComputerFilterOptions.sortSoldDesc: 'c.sold_quantity DESC',
      ComputerFilterOptions.sortBrandAsc:
          'b.brand_name COLLATE NOCASE ASC, c.product_name COLLATE NOCASE ASC',
      ComputerFilterOptions.sortBrandDesc:
          'b.brand_name COLLATE NOCASE DESC, c.product_name COLLATE NOCASE ASC',
      ComputerFilterOptions.sortStockAsc: 'c.stock ASC',
      ComputerFilterOptions.sortStockDesc: 'c.stock DESC',
      'Product Name A-Z': 'c.product_name COLLATE NOCASE ASC',
      'Product Name Z-A': 'c.product_name COLLATE NOCASE DESC',
      'Price Ascending': 'c.price ASC',
      'Price Descending': 'c.price DESC',
      'Sold Quantity Ascending': 'c.sold_quantity ASC',
      'Sold Quantity Descending': 'c.sold_quantity DESC',
      'Brand Name A-Z':
          'b.brand_name COLLATE NOCASE ASC, c.product_name COLLATE NOCASE ASC',
      'Brand Name Z-A':
          'b.brand_name COLLATE NOCASE DESC, c.product_name COLLATE NOCASE ASC',
      'Stock Low-High': 'c.stock ASC',
      'Stock High-Low': 'c.stock DESC',
    };
    final orderBy =
        sortClauses[sortOption] ??
        sortClauses[ComputerFilterOptions.sortNameAsc] ??
        'c.product_name COLLATE NOCASE ASC';

    final rows = await db.rawQuery('''
      SELECT c.id, c.product_name, c.brand_id, c.category_id, c.cpu,
             c.ram, c.storage, c.price, c.stock, c.sold_quantity,
             c.is_featured, b.brand_name, ca.category_name
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      $where
      ORDER BY $orderBy
    ''', args);
    return rows.map(Computer.fromMap).toList(growable: false);
  }

  Future<List<Computer>> getAllComputers() => getComputers();

  Future<List<Computer>> searchComputers(String keyword) {
    return getComputers(keyword: keyword);
  }

  Future<List<Computer>> filterComputers({
    String keyword = '',
    int? brandId,
    int? categoryId,
    bool featuredOnly = false,
    String? stockStatus,
    String? ramOption,
    String? storageOption,
    String? priceOption,
    String sortOption = ComputerFilterOptions.sortNameAsc,
  }) {
    return getComputers(
      keyword: keyword,
      brandId: brandId,
      categoryId: categoryId,
      featuredOnly: featuredOnly,
      stockStatus: stockStatus,
      ramOption: ramOption,
      storageOption: storageOption,
      priceOption: priceOption,
      sortOption: sortOption,
    );
  }

  Future<List<Computer>> sortComputers(String sortOption) {
    return getComputers(sortOption: sortOption);
  }

  Future<List<Computer>> resetFilters() => getComputers();

  Future<Computer?> getComputerById(int id) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT c.*, b.brand_name, ca.category_name
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      INNER JOIN categories ca ON c.category_id = ca.id
      WHERE c.id = ?
      LIMIT 1
    ''',
      [id],
    );
    final row = rows.firstOrNull;
    return row == null ? null : Computer.fromMap(row);
  }

  Future<bool> isProductNameUnique(String name, {int? excludeId}) async {
    final db = await database;
    final where = StringBuffer('LOWER(TRIM(product_name)) = LOWER(TRIM(?))');
    final args = <Object?>[name];
    if (excludeId != null) {
      where.write(' AND id <> ?');
      args.add(excludeId);
    }
    final rows = await db.query(
      'computers',
      columns: const ['COUNT(*) AS total'],
      where: where.toString(),
      whereArgs: args,
    );
    return _intValue(rows.firstOrNull?['total']) == 0;
  }

  Future<int> insertComputer(Computer computer) async {
    final db = await database;
    final values = Map<String, Object?>.from(computer.toMap())..remove('id');
    return db.insert(
      'computers',
      values,
      conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
    );
  }

  Future<int> updateComputer(Computer computer) async {
    final id = computer.id;
    if (id == null) {
      throw ArgumentError('Computer id is required for update.');
    }
    final db = await database;
    final values = Map<String, Object?>.from(computer.toMap())..remove('id');
    return db.update('computers', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteComputer(int id) async {
    final db = await database;
    return db.delete('computers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, num>> getStatistics() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS totalProducts,
             COALESCE(SUM(price * sold_quantity), 0) AS totalRevenue,
             COALESCE(SUM(sold_quantity), 0) AS totalSoldQuantity,
             COALESCE(AVG(price), 0) AS averagePrice,
             COALESCE(SUM(price * stock), 0) AS totalInventoryValue
      FROM computers
    ''');
    final row = rows.firstOrNull ?? const <String, Object?>{};
    return <String, num>{
      'totalProducts': _numValue(row['totalProducts']),
      'totalRevenue': _numValue(row['totalRevenue']),
      'totalSoldQuantity': _numValue(row['totalSoldQuantity']),
      'averagePrice': _numValue(row['averagePrice']),
      'totalInventoryValue': _numValue(row['totalInventoryValue']),
    };
  }

  Future<List<Map<String, Object?>>> getBrandStatistics() async {
    final db = await database;
    return db.rawQuery('''
      SELECT b.brand_name AS brandName,
             COUNT(c.id) AS totalProducts,
             COALESCE(SUM(c.sold_quantity), 0) AS totalSold,
             COALESCE(SUM(c.price * c.sold_quantity), 0) AS revenue,
             COALESCE(SUM(c.price * c.stock), 0) AS inventoryValue
      FROM brands b
      LEFT JOIN computers c ON b.id = c.brand_id
      GROUP BY b.id, b.brand_name
      ORDER BY revenue DESC
    ''');
  }

  Future<List<Map<String, Object?>>> getCategoryStatistics() async {
    final db = await database;
    return db.rawQuery('''
      SELECT ca.category_name AS categoryName,
             COUNT(c.id) AS totalProducts,
             COALESCE(SUM(c.price * c.sold_quantity), 0) AS revenue,
             COALESCE(SUM(c.sold_quantity), 0) AS totalSold
      FROM categories ca
      LEFT JOIN computers c ON ca.id = c.category_id
      GROUP BY ca.id, ca.category_name
      ORDER BY ca.category_name COLLATE NOCASE ASC
    ''');
  }

  Future<Map<String, Object?>?> getBestSellingProduct() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT product_name AS productName, sold_quantity AS soldQuantity
      FROM computers
      ORDER BY sold_quantity DESC, product_name COLLATE NOCASE ASC
      LIMIT 1
    ''');
    return rows.firstOrNull;
  }

  Future<Map<String, Object?>?> getMostExpensiveProduct() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT product_name AS productName, price
      FROM computers
      ORDER BY price DESC, product_name COLLATE NOCASE ASC
      LIMIT 1
    ''');
    return rows.firstOrNull;
  }

  Future<List<Map<String, Object?>>> getLowStockProducts() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.id,
             c.product_name AS productName,
             b.brand_name AS brandName,
             c.stock
      FROM computers c
      INNER JOIN brands b ON c.brand_id = b.id
      WHERE c.stock < 5
      ORDER BY c.stock ASC, c.product_name COLLATE NOCASE ASC
    ''');
  }

  Future<Map<String, Object?>?> getTopBrand() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT b.brand_name AS brandName,
             COALESCE(SUM(c.sold_quantity), 0) AS totalSold
      FROM brands b
      INNER JOIN computers c ON b.id = c.brand_id
      GROUP BY b.id, b.brand_name
      ORDER BY totalSold DESC, b.brand_name COLLATE NOCASE ASC
      LIMIT 1
    ''');
    return rows.firstOrNull;
  }

  Future<Map<String, num>> getFeaturedStatistics() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS totalFeaturedProducts,
             COALESCE(SUM(price * sold_quantity), 0)
               AS totalFeaturedRevenue,
             COALESCE(SUM(sold_quantity), 0)
               AS totalFeaturedSoldQuantity
      FROM computers
      WHERE is_featured = 1
    ''');
    final row = rows.firstOrNull ?? const <String, Object?>{};
    return <String, num>{
      'totalFeaturedProducts': _numValue(row['totalFeaturedProducts']),
      'totalFeaturedRevenue': _numValue(row['totalFeaturedRevenue']),
      'totalFeaturedSoldQuantity': _numValue(row['totalFeaturedSoldQuantity']),
    };
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) await db.close();
    _database = null;
  }

  Future<void> configureDatabasePathForTesting(String? filePath) async {
    await close();
    _databasePathOverride = filePath;
  }

  Future<void> deleteDatabaseForTesting() async {
    await close();
    ensureInitialized();
    final databasesPath = await sqflite.getDatabasesPath();
    final databasePath =
        _databasePathOverride ?? p.join(databasesPath, databaseName);
    await sqflite.deleteDatabase(databasePath);
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num _numValue(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
