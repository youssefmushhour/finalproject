import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/group_model.dart';
 
abstract class GroupsState {}
class GroupsInitial extends GroupsState {}
class GroupsLoading extends GroupsState {}
class GroupsLoaded extends GroupsState {
  final List<GroupModel> groups;
  GroupsLoaded(this.groups);
}
class GroupError extends GroupsState {
  final String message;
  GroupError(this.message);
}
 
class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit() : super(GroupsInitial());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  // ✅ Helper للحصول على uid اليوزر الحالي
  String? get _uid => _auth.currentUser?.uid;
 
  // ✅ Reference للـ collection الخاصة بالـ user
  CollectionReference? get _groupsCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('groups');
  }
 
  void fetchGroups() {
    final collection = _groupsCollection;
    if (collection == null) {
      emit(GroupError("User not logged in"));
      return;
    }
 
    // ✅ بيجيب الجروبات الخاصة بالـ user بس
    collection.snapshots().listen((snapshot) {
      final groups = snapshot.docs
          .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      emit(GroupsLoaded(groups));
    }, onError: (e) {
      emit(GroupError(e.toString()));
    });
  }
 
  Future<void> createGroup(String name, String category, List<Map<String, String>> members, double budget) async {
    final collection = _groupsCollection;
    if (collection == null) {
      emit(GroupError("User not logged in"));
      return;
    }
 
    try {
      final docRef = collection.doc();
      final newGroup = GroupModel(
        id: docRef.id,
        name: name,
        category: category,
        members: members,
        totalBalance: budget,
      );
      // ✅ بيحفظ الجروب تحت users/{uid}/groups
      await docRef.set(newGroup.toMap());
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }
 
  Future<void> addExpense({
    required String groupId,
    required double amount,
    required String description,
    required String payerName,
    required String category,
  }) async {
    final collection = _groupsCollection;
    if (collection == null) return;
 
    try {
      // ✅ الـ groupDoc بيبقى تحت users/{uid}/groups/{groupId}
      final groupDoc = collection.doc(groupId);
 
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(groupDoc);
        if (snapshot.exists) {
          double currentTotal = ((snapshot.data() as Map<String, dynamic>?)?['totalBalance'] ?? 0.0).toDouble();
          transaction.update(groupDoc, {'totalBalance': currentTotal + amount});
        }
      });
 
      await groupDoc.collection('expenses').add({
        'amount': amount,
        'description': description,
        'payerName': payerName,
        'category': category,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}