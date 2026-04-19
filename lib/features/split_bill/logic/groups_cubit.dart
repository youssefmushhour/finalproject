import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void fetchGroups() {
    _firestore.collection('groups').snapshots().listen((snapshot) {
      final groups = snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
      emit(GroupsLoaded(groups));
    });
  }

  Future<void> createGroup(String name, String category, List<Map<String, String>> members, double budget) async {
    try {
      final docRef = _firestore.collection('groups').doc();
      final newGroup = GroupModel(
        id: docRef.id,
        name: name,
        category: category,
        members: members,
        totalBalance: budget,
      );
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
    try {
      final groupDoc = _firestore.collection('groups').doc(groupId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(groupDoc);
        if (snapshot.exists) {
          double currentTotal = (snapshot.data()?['totalBalance'] ?? 0.0).toDouble();
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