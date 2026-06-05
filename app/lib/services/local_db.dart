import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'taxeasy.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            store_id TEXT NOT NULL,
            name TEXT NOT NULL,
            price INTEGER NOT NULL,
            unit TEXT,
            category TEXT,
            image_url TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  static Future<void> upsertProducts(List<ProductDto> products) async {
    final database = await db;
    final batch = database.batch();
    for (final p in products) {
      batch.insert(
        'products',
        {
          'id': p.id,
          'store_id': p.storeId,
          'name': p.name,
          'price': p.price,
          'unit': p.unit,
          'category': p.category,
          'image_url': p.imageUrl,
          'is_active': p.isActive ? 1 : 0,
          'created_at': p.createdAt?.toIso8601String(),
          'updated_at': p.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<ProductDto>> getActiveProducts() async {
    final database = await db;
    final rows = await database.query(
      'products',
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return rows.map(_rowToProduct).toList();
  }

  static ProductDto _rowToProduct(Map<String, dynamic> row) {
    return ProductDto(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      name: row['name'] as String,
      price: row['price'] as int,
      unit: row['unit'] as String?,
      category: row['category'] as String?,
      imageUrl: row['image_url'] as String?,
      isActive: (row['is_active'] as int) == 1,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
