import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/shopping_item.dart';

class ShoppingDatabase {
  ShoppingDatabase._();

  static final ShoppingDatabase instance = ShoppingDatabase._();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'favorite_shopping_items.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE shopping_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemName TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<ShoppingItem>> getAllItems() async {
    final db = await database;
    final rows = await db.query('shopping_items', orderBy: 'id DESC');
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<List<ShoppingItem>> getWishlistItems() async {
    final db = await database;
    final rows = await db.query(
      'shopping_items',
      where: 'status = ?',
      whereArgs: const [ShoppingItem.wishlistStatus],
      orderBy: 'id DESC',
    );
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<ShoppingItem> insert(ShoppingItem item) async {
    final db = await database;
    final values = item.toMap()..remove('id');
    final id = await db.insert('shopping_items', values);
    return item.copyWith(id: id);
  }

  Future<void> update(ShoppingItem item) async {
    final db = await database;
    await db.update(
      'shopping_items',
      item.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }
}
