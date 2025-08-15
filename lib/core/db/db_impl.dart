import '../../features/product/model/product_model.dart';
import '../../features/transaction/model/transaction_model.dart';

import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_interface.dart';

class DbServiceImpl implements DbService {
  static Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'pos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT UNIQUE,
            name TEXT,
            price REAL,
            isSynced INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionId TEXT UNIQUE,
            productId TEXT,
            productName TEXT,
            quantity INTEGER,
            price REAL,
            totalAmount REAL,
            date TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }
  
  @override
  Future<void> insertProduct(ProductModel product) async {
    try {
      final db = await _database;
      await db.insert(
        'products', 
        product.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    } catch (e) {
      log('Error inserting product: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query('products');
      return maps.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log('Error getting products: $e');
      return [];
    }
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products', 
        where: 'productId = ?', 
        whereArgs: [productId]
      );
      if (maps.isNotEmpty) {
        return ProductModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      log('Error getting product by id: $e');
      return null;
    }
  }

  @override
  Future<bool> updateProductSyncStatus(String productId, bool isSynced) async {
    try {
      final db = await _database;
      final result = await db.update(
        'products',
        {'isSynced': isSynced ? 1 : 0},
        where: 'productId = ?',
        whereArgs: [productId]
      );
      return result > 0;
    } catch (e) {
      log('Error updating product sync status: $e');
      return false;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final db = await _database;
      await db.delete(
        'products', 
        where: 'productId = ?', 
        whereArgs: [productId]
      );
    } catch (e) {
      log('Error deleting product: $e');
      rethrow;
    }
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _database;
      await db.insert(
        'transactions', 
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    } catch (e) {
      log('Error inserting transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query('transactions');
      return maps.map((e) => TransactionModel.fromMap(e)).toList();
    } catch (e) {
      log('Error getting transactions: $e');
      return [];
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'transactionId = ?',
        whereArgs: [transactionId]
      );
      if (maps.isNotEmpty) {
        return TransactionModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      log('Error getting transaction by id: $e');
      return null;
    }
  }

  @override
  Future<bool> updateTransactionSyncStatus(String transactionId, bool isSynced) async {
    try {
      final db = await _database;
      final result = await db.update(
        'transactions',
        {'isSynced': isSynced ? 1 : 0},
        where: 'transactionId = ?',
        whereArgs: [transactionId]
      );
      return result > 0;
    } catch (e) {
      log('Error updating transaction sync status: $e');
      return false;
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final db = await _database;
      await db.delete(
        'transactions',
        where: 'transactionId = ?',
        whereArgs: [transactionId]
      );
    } catch (e) {
      log('Error deleting transaction: $e');
      rethrow;
    }
  }
}