import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../logic/groups_cubit.dart';
import '../data/models/group_model.dart';
 
class SplitBillScreen extends StatefulWidget {
  final VoidCallback onSaveSuccess;
  const SplitBillScreen({super.key, required this.onSaveSuccess});
 
  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}
 
class _SplitBillScreenState extends State<SplitBillScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsCubit>().fetchGroups();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Builder(builder: (context) {
            final user = FirebaseAuth.instance.currentUser;
            final String name = user?.displayName ?? user?.email?.split('@').first ?? 'U';
            final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
            final String? photoURL = user?.photoURL;
            return CircleAvatar(
              backgroundColor: const Color(0xFF085652),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                  : null,
            );
          }),
        ),
        title: const Text("Masroufy",
            style: TextStyle(color: Color(0xFF085652), fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<GroupsCubit, GroupsState>(
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF085652)));
          }
          
          if (state is GroupsLoaded) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  if (state.groups.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text("No groups created yet.", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ...state.groups.map((group) => _buildGroupLargeCard(context, group)),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          
          if (state is GroupError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          
          return const SizedBox();
        },
      ),
    );
  }
 
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FINANCIAL CURATOR",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            Text("Groups",
                style: TextStyle(
                    color: Color(0xFF085652),
                    fontWeight: FontWeight.bold,
                    fontSize: 32)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const CreateGroupScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFF085652),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 5),
                Text("New Group",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildGroupLargeCard(BuildContext context, GroupModel group) {
    IconData getIcon() {
      switch (group.category) {
        case 'Travel':
          return Icons.airplanemode_active_rounded;
        case 'Household':
          return Icons.home_rounded;
        case 'Social':
          return Icons.restaurant_rounded;
        case 'Gym':
          return Icons.fitness_center_rounded;
        default:
          return Icons.group_rounded;
      }
    }
 
    return GestureDetector(
      // التصليح هنا: شلنا الـ groupName وبعتنا الـ group بس
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupDetailScreen(group: group))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(30)),
        child: Stack(
          children: [
            Positioned(
                right: -10,
                bottom: -10,
                child: Icon(getIcon(),
                    size: 130, color: Colors.black.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF085652),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(getIcon(), color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(group.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF085652))),
                  Text("${group.members.length} Members • ${group.category}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 30),
                  Text("EGP ${group.totalBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("TOTAL SHARED",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}