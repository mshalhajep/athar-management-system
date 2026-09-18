import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/purchase.dart';

/// [خدمة المزامنة السحابية الحقيقية - Cloud Firestore Service]:
/// تتولى الربط المباشر مع سيرفر Google Firebase السحابي لمزامنة الفواتير
/// بشكل لحظي (Realtime) بين مختلف أجهزة الأندرويد والآيفون.
class FirestoreSyncService {
  FirestoreSyncService._privateConstructor();
  static final FirestoreSyncService instance = FirestoreSyncService._privateConstructor();

  static const String collectionName = 'purchases';

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  /// رفع أو تحديث فاتورة سحابياً
  Future<void> syncPurchaseToCloud(Purchase purchase) async {
    final db = _firestore;
    if (db == null) return;

    try {
      final data = purchase.toJson();
      // التأكد من حفظ البريد موحداً
      if (purchase.userEmail != null) {
        data['userEmail'] = purchase.userEmail!.trim().toLowerCase();
        data['user_email'] = purchase.userEmail!.trim().toLowerCase();
      }

      await db
          .collection(collectionName)
          .doc(purchase.id)
          .set(data, SetOptions(merge: true));
      debugPrint('Cloud sync success for purchase: ${purchase.id}');
    } catch (e) {
      debugPrint('Cloud sync error (upload): $e');
    }
  }

  /// حذف فاتورة من السحابة
  Future<void> deletePurchaseFromCloud(String id) async {
    final db = _firestore;
    if (db == null) return;

    try {
      await db.collection(collectionName).doc(id).delete();
      debugPrint('Cloud delete success for purchase: $id');
    } catch (e) {
      debugPrint('Cloud sync error (delete): $e');
    }
  }

  /// جلب كافة الفواتير من السيرفر السحابي لحساب معين
  Future<List<Purchase>> fetchPurchasesFromCloud({String? userEmail}) async {
    final db = _firestore;
    if (db == null) return [];

    try {
      Query query = db.collection(collectionName);
      final normalized = userEmail?.trim().toLowerCase();

      if (normalized != null && normalized.isNotEmpty && normalized != 'guest' && normalized != 'local@device') {
        query = query.where('userEmail', isEqualTo: normalized);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Purchase.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Cloud fetch error: $e');
      return [];
    }
  }

  /// الاستماع اللحظي (Stream) لأي تحديث أو فاتورة جديدة في السحابة
  Stream<List<Purchase>> streamPurchases({String? userEmail}) {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    try {
      Query query = db.collection(collectionName);
      final normalized = userEmail?.trim().toLowerCase();

      if (normalized != null && normalized.isNotEmpty && normalized != 'guest' && normalized != 'local@device') {
        query = query.where('userEmail', isEqualTo: normalized);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Purchase.fromJson(data);
        }).toList();
      });
    } catch (e) {
      debugPrint('Cloud stream setup error: $e');
      return const Stream.empty();
    }
  }
}
