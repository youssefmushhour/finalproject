import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/groups_cubit.dart';
import '../data/models/group_model.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        // تحديث بيانات الجروب من الـ Cubit لضمان دقة الأرقام
        GroupModel currentGroup = group;
        if (state is GroupsLoaded) {
          try {
            currentGroup = state.groups.firstWhere(
              (g) => g.id == group.id,
              orElse: () => group,
            );
          } catch (e) {
            currentGroup = group;
          }
        }

        // حسبة نصيب الفرد بناءً على إجمالي المصاريف وعدد الأعضاء
        final List membersList = currentGroup.members ?? [];
        double totalBalance = currentGroup.totalBalance ?? 0.0;
        double sharePerPerson = (membersList.isEmpty) ? 0 : totalBalance / membersList.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF085652), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              currentGroup.name ?? 'Group Details',
              style: const TextStyle(color: Color(0xFF085652), fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // كارد إجمالي المصاريف الرئيسي
                _buildTotalCard(totalBalance, currentGroup.category ?? 'General'),
                const SizedBox(height: 30),
                
                // عنوان قسم الأعضاء
                const Text(
                  "MEMBERS & SETTLEMENT",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),

                // عرض قائمة الأعضاء
                if (membersList.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: membersList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final member = membersList[index];
                      return _buildMemberTile(
                        member['name']?.toString() ?? 'User',
                        member['img']?.toString() ?? '',
                        sharePerPerson,
                      );
                    },
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No members in this group", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // ويدجت الكارد الأخضر الكبير
  Widget _buildTotalCard(double total, String category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF085652),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF085652).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Expenses",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "EGP ${total.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت عرض العضو الواحد
  Widget _buildMemberTile(String name, String img, double share) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2F4F4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF2F4F4),
            backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
            child: img.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF085652),
                  ),
                ),
                const Text(
                  "Equal Split",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            "EGP ${share.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}