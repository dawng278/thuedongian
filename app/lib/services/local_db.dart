import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/invoice.dart';

enum InvoiceStatus { pending, synced }

class LocalInvoice {
  final String id;
  final int localNumber;
  final int totalAmount;
  final String? note;
  final DateTime createdAt;
  final InvoiceStatus status;
  final int? serverInvoiceNumber;
  final List<CreateInvoiceItemInput> items;

  const LocalInvoice({
    required this.id,
    required this.localNumber,
    required this.totalAmount,
    this.note,
    required this.createdAt,
    required this.status,
    this.serverInvoiceNumber,
    required this.items,
  });
}

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
      version: 2,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
  }

  static Future<void> _create(Database db, int version) async {
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
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        local_number INTEGER NOT NULL,
        total_amount INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        server_invoice_number INTEGER,
        items_json TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE invoice_counter (
        id INTEGER PRIMARY KEY,
        counter INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.insert('invoice_counter', {'id': 1, 'counter': 0});
  }

  static Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoices (
          id TEXT PRIMARY KEY,
          local_number INTEGER NOT NULL,
          total_amount INTEGER NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          server_invoice_number INTEGER,
          items_json TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoice_counter (
          id INTEGER PRIMARY KEY,
          counter INTEGER NOT NULL DEFAULT 0
        )
      ''');
      final rows = await db.query('invoice_counter', where: 'id = 1');
      if (rows.isEmpty) {
        await db.insert('invoice_counter', {'id': 1, 'counter': 0});
      }
    }
  }

  // ── Products ──

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

  // ── Invoices ──

  static Future<int> _nextLocalNumber(Database database) async {
    await database.rawUpdate(
      'UPDATE invoice_counter SET counter = counter + 1 WHERE id = 1',
    );
    final rows = await database.query('invoice_counter', where: 'id = 1');
    return rows.first['counter'] as int;
  }

  static Future<LocalInvoice> insertPendingInvoice(CreateInvoiceDto dto) async {
    final database = await db;
    final localNumber = await _nextLocalNumber(database);
    final totalAmount = dto.items.fold(0, (sum, i) => sum + i.price * i.quantity);
    final itemsJson = jsonEncode(dto.items.map((i) => i.toJson()).toList());

    await database.insert('invoices', {
      'id': dto.id,
      'local_number': localNumber,
      'total_amount': totalAmount,
      'note': dto.note,
      'created_at': dto.createdAt.toIso8601String(),
      'status': 'pending',
      'items_json': itemsJson,
    });

    return LocalInvoice(
      id: dto.id,
      localNumber: localNumber,
      totalAmount: totalAmount,
      note: dto.note,
      createdAt: dto.createdAt,
      status: InvoiceStatus.pending,
      items: dto.items,
    );
  }

  static Future<List<LocalInvoice>> getPendingInvoices() async {
    final database = await db;
    final rows = await database.query(
      'invoices',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'local_number ASC',
    );
    return rows.map(_rowToLocalInvoice).toList();
  }

  static Future<void> markSynced(String id, int serverInvoiceNumber) async {
    final database = await db;
    await database.update(
      'invoices',
      {'status': 'synced', 'server_invoice_number': serverInvoiceNumber},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static LocalInvoice _rowToLocalInvoice(Map<String, dynamic> row) {
    final itemsRaw = jsonDecode(row['items_json'] as String) as List;
    final items = itemsRaw.map((e) => CreateInvoiceItemInput(
      productId: e['product_id'] as String?,
      productName: e['product_name'] as String,
      price: (e['price'] as num).toInt(),
      quantity: (e['quantity'] as num).toInt(),
    )).toList();

    return LocalInvoice(
      id: row['id'] as String,
      localNumber: row['local_number'] as int,
      totalAmount: row['total_amount'] as int,
      note: row['note'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      status: row['status'] == 'pending' ? InvoiceStatus.pending : InvoiceStatus.synced,
      serverInvoiceNumber: row['server_invoice_number'] as int?,
      items: items,
    );
  }
}
