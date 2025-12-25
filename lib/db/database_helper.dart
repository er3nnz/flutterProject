import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:ders_project/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB, onOpen: (db) async {
      await _ensureSchema(db);
    });
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        unit TEXT NOT NULL,
        barcode TEXT UNIQUE,
        reorder_level INTEGER DEFAULT 0,
        cost_price REAL,
        sale_price REAL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS location(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        location_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        reserved_quantity REAL DEFAULT 0,
        last_counted_at TEXT,
        UNIQUE(product_id, location_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_transaction(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        location_from_id INTEGER,
        location_to_id INTEGER,
        quantity REAL NOT NULL,
        type TEXT NOT NULL,
        reference TEXT,
        note TEXT,
        created_by INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_product_name ON product(name);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_inventory_product ON inventory(product_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_invtrans_product ON inventory_transaction(product_id);');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE product(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        unit TEXT NOT NULL,
        barcode TEXT UNIQUE,
        reorder_level INTEGER DEFAULT 0,
        cost_price REAL,
        sale_price REAL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE location(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        location_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        reserved_quantity REAL DEFAULT 0,
        last_counted_at TEXT,
        UNIQUE(product_id, location_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory_transaction(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        location_from_id INTEGER,
        location_to_id INTEGER,
        quantity REAL NOT NULL,
        type TEXT NOT NULL,
        reference TEXT,
        note TEXT,
        created_by INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_product_name ON product(name);');
    await db.execute('CREATE INDEX idx_inventory_product ON inventory(product_id);');
    await db.execute('CREATE INDEX idx_invtrans_product ON inventory_transaction(product_id);');
  }

  Future<int> insertItem(String name) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('items', {'name': name, 'createdAt': now});
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await instance.database;
    return await db.query('items', orderBy: 'id DESC');
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    product['created_at'] = now;
    product['updated_at'] = now;
    return await db.insert('product', product);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('product', orderBy: 'id DESC');
  }

  Future<int> updateProduct(int id, Map<String, dynamic> changes) async {
    final db = await instance.database;
    changes['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('product', changes, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('product', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertLocation(Map<String, dynamic> location) async {
    final db = await instance.database;
    return await db.insert('location', location);
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await instance.database;
    return await db.query('location', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getInventoryRow(int productId, int locationId) async {
    final db = await instance.database;
    final res = await db.query('inventory', where: 'product_id = ? AND location_id = ?', whereArgs: [productId, locationId]);
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<int> setInventory(int productId, int locationId, double quantity) async {
    final db = await instance.database;
    final existing = await getInventoryRow(productId, locationId);
    if (existing == null) {
      return await db.insert('inventory', {'product_id': productId, 'location_id': locationId, 'quantity': quantity});
    } else {
      return await db.update('inventory', {'quantity': quantity}, where: 'id = ?', whereArgs: [existing['id']]);
    }
  }

  Future<List<Map<String, dynamic>>> getInventoryForProduct(int productId) async {
    final db = await instance.database;
    return await db.query('inventory', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<int> createInventoryTransaction({
    required int productId,
    int? locationFromId,
    int? locationToId,
    required double quantity,
    required String type,
    String? reference,
    String? note,
    int? createdBy,
  }) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    return await db.transaction<int>((txn) async {
      final transId = await txn.insert('inventory_transaction', {
        'product_id': productId,
        'location_from_id': locationFromId,
        'location_to_id': locationToId,
        'quantity': quantity,
        'type': type,
        'reference': reference,
        'note': note,
        'created_by': createdBy,
        'created_at': now,
      });

      Future<void> _inc(int locId, double q) async {
        final rows = await txn.query('inventory', where: 'product_id = ? AND location_id = ?', whereArgs: [productId, locId]);
        if (rows.isEmpty) {
          await txn.insert('inventory', {'product_id': productId, 'location_id': locId, 'quantity': q});
        } else {
          final current = (rows.first['quantity'] as num).toDouble();
          await txn.update('inventory', {'quantity': current + q}, where: 'id = ?', whereArgs: [rows.first['id']]);
        }
      }

      Future<void> _dec(int locId, double q) async {
        final rows = await txn.query('inventory', where: 'product_id = ? AND location_id = ?', whereArgs: [productId, locId]);
        if (rows.isEmpty) {
          await txn.insert('inventory', {'product_id': productId, 'location_id': locId, 'quantity': -q});
        } else {
          final current = (rows.first['quantity'] as num).toDouble();
          await txn.update('inventory', {'quantity': current - q}, where: 'id = ?', whereArgs: [rows.first['id']]);
        }
      }

      if (locationFromId != null && locationToId != null) {
        await _dec(locationFromId, quantity);
        await _inc(locationToId, quantity);
      } else if (locationFromId != null) {
        await _dec(locationFromId, quantity);
      } else if (locationToId != null) {
        await _inc(locationToId, quantity);
      }

      return transId;
    });
  }

  Future<List<Map<String, dynamic>>> getInventoryTransactions({int? productId}) async {
    final db = await instance.database;
    if (productId != null) {
      return await db.query('inventory_transaction', where: 'product_id = ?', whereArgs: [productId], orderBy: 'id DESC');
    }
    return await db.query('inventory_transaction', orderBy: 'id DESC');
  }

  // ---------------- User management ----------------
  String _generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registers a new user. Throws [Exception] if username already exists.
  Future<int> registerUser({required String username, required String password, String role = 'user'}) async {
    final db = await instance.database;
    final existing = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existing.isNotEmpty) throw Exception('Username already exists');
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final now = DateTime.now().toIso8601String();
    return await db.insert('users', {'username': username, 'password_hash': hash, 'salt': salt, 'role': role, 'created_at': now});
  }

  /// Authenticates a user. Returns [User] on success, null on failure.
  Future<User?> authenticateUser({required String username, required String password}) async {
    final db = await instance.database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final salt = row['salt'] as String;
    final hash = row['password_hash'] as String;
    final candidate = _hashPassword(password, salt);
    if (candidate == hash) {
      return User.fromMap(row);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final rows = await db.query('users', orderBy: 'id DESC');
    return rows.map((r) => User.fromMap(r)).toList();
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
