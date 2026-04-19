import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/groups_cubit.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final groupNameController = TextEditingController();
  final budgetController = TextEditingController();
  final nameInputController = TextEditingController();

  String selectedCategory = "Travel";
  List<Map<String, String>> myContacts = [];
  List<Map<String, String>> selectedMembers = [];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Travel', 'icon': Icons.airplanemode_active_rounded},
    {'name': 'Household', 'icon': Icons.home_rounded},
    {'name': 'Social', 'icon': Icons.restaurant_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  void _addNewContact() {
    String name = nameInputController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        myContacts.add({
          'name': name,
          'img': 'https://ui-avatars.com/api/?name=$name&background=085652&color=fff',
        });
        nameInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF085652), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Group", style: TextStyle(color: Color(0xFF085652), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("GROUP IDENTITY"),
            _buildTextField(groupNameController, "Group Name"),
            const SizedBox(height: 20),
            _buildLabel("BUDGET / TOTAL PRICE"),
            _buildTextField(budgetController, "0.00 (EGP)", isNumber: true),
            const SizedBox(height: 30),
            _buildLabel("CATEGORY"),
            _buildCategoryList(),
            const SizedBox(height: 30),
            _buildLabel("ADD TO CONTACTS"),
            _buildAddContactField(),
            const SizedBox(height: 20),
            _buildLabel("SELECTED MEMBERS"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedMembers.map((m) => _buildMemberChip(m)).toList(),
            ),
            const SizedBox(height: 30),
            _buildLabel("MY CONTACTS"),
            ...myContacts.map((contact) => _buildContactTile(contact)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildCreateButton(),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) => Container(
    decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(18)),
    ),
  );

  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index]['name'];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]['name']),
            child: Container(
              width: 85,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF085652) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categories[index]['icon'], color: isSelected ? Colors.white : const Color(0xFF085652)),
                  const SizedBox(height: 5),
                  Text(categories[index]['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddContactField() => Container(
    decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: nameInputController,
      decoration: InputDecoration(
        hintText: "Type name...",
        suffixIcon: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF085652)),
          onPressed: _addNewContact,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(15),
      ),
    ),
  );

  Widget _buildMemberChip(Map<String, String> m) => Chip(
    avatar: CircleAvatar(backgroundImage: NetworkImage(m['img']!)),
    label: Text(m['name']!, style: const TextStyle(fontSize: 11)),
    onDeleted: () => setState(() => selectedMembers.remove(m)),
    deleteIcon: const Icon(Icons.cancel, size: 14),
    backgroundColor: const Color(0xFFE0F2F1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  Widget _buildContactTile(Map<String, String> contact) {
    bool isAdded = selectedMembers.contains(contact);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundImage: NetworkImage(contact['img']!)),
      title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isAdded ? Icons.check_circle : Icons.add_circle_outline, color: isAdded ? Colors.green : const Color(0xFF085652)),
            onPressed: () => setState(() => isAdded ? selectedMembers.remove(contact) : selectedMembers.add(contact)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => setState(() => myContacts.remove(contact)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() => Container(
    padding: const EdgeInsets.all(24),
    color: Colors.white,
    child: ElevatedButton(
      onPressed: () {
        if (groupNameController.text.isNotEmpty) {
          final double budgetVal = double.tryParse(budgetController.text.trim()) ?? 0.0;
          
          context.read<GroupsCubit>().createGroup(
            groupNameController.text.trim(),
            selectedCategory,
            selectedMembers,
            budgetVal,
          );
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF085652),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}