// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/network/api_service.dart';

import 'package:my_app/data/models/network/auth_local_storage.dart';  

// --- DESIGN SYSTEM ---
const Color primaryIndigo = Color(0xFF3F51B5);
const Color backgroundWhite = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3436);
const Color successGreen = Color(0xFF00B894);
const Color cardShadow = Color(0x0F000000);

class WardenStdLeaveApprovePage extends StatefulWidget {
  const WardenStdLeaveApprovePage({super.key});

  @override
  State<WardenStdLeaveApprovePage> createState() => _WardenStdLeaveApprovePageState();
}

class _WardenStdLeaveApprovePageState extends State<WardenStdLeaveApprovePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allLeaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeaves();
  }

  /// ✅ Fetches leaves and handles potential data format variations
  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.getWardenLeaves(); 
      
      if (mounted) {
        setState(() {
          // Robust check for list vs map response
          if (response is List) {
            _allLeaves = response;
          } else if (response is Map && response['data'] != null) {
            _allLeaves = response['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching warden leaves: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ✅ FIXED: Handles the Approval/Rejection with Explicit Int Parsing
  Future<void> _handleAction(dynamic leave, bool approve) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
    );

    try {
      // --- THE FIX ---
      // We use int.tryParse or .toInt() to ensure we pass an integer to the ApiService
      final int studentId = int.tryParse(leave['user_id'].toString()) ?? 0;
      final int leaveId = int.tryParse(leave['id'].toString()) ?? 0;

      if (studentId == 0 || leaveId == 0) {
        throw Exception("Invalid ID format detected");
      }

      final response = await apiService.wardenApproveLeave(
        studentId: studentId,
        leaveId: leaveId,
        isApprove: approve,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loader

      if (response != null && (response['success'] == true || response['status'] == 'success')) {
        _showSnackBar(
          "Leave ${approve ? 'Approved' : 'Rejected'} Successfully", 
          approve ? successGreen : Colors.redAccent
        );
        _fetchLeaves(); // Refresh the list to reflect changes
      } else {
        _showSnackBar(response?['message'] ?? "Action failed", Colors.orange);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar("Error: ${e.toString()}", Colors.redAccent);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text("Leave Management", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: primaryIndigo,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          tabs: const [
            Tab(text: "PENDING"),
            Tab(text: "HISTORY"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildLeaveList(filterStatus: "pending"),
              _buildLeaveList(filterStatus: "history"),
            ],
          ),
    );
  }

  Widget _buildLeaveList({required String filterStatus}) {
    final filteredList = _allLeaves.where((l) {
      final status = l['status'].toString().toLowerCase();
      if (filterStatus == "pending") {
        return status == "pending" || status == "waiting";
      } else {
        return status == "approved" || status == "rejected";
      }
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("No $filterStatus requests", style: const TextStyle(color: Colors.grey)),
          ],
        )
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      color: primaryIndigo,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return _buildLeaveCard(filteredList[index], filterStatus == "pending");
        },
      ),
    );
  }

  Widget _buildLeaveCard(dynamic leave, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryIndigo.withOpacity(0.1),
                              child: const Icon(Icons.person, color: primaryIndigo, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(leave['student_name'] ?? "Student", 
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textDark)),
                                  Text("Student ID: ${leave['user_id']}", 
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(leave['status'].toString().toUpperCase()),
                    ],
                  ),
                  const Divider(height: 25),
                  _infoRow(Icons.calendar_month_rounded, "Dates", 
                      "${leave['start_date'].toString().split(' ')[0]} - ${leave['end_date'].toString().split(' ')[0]}"),
                  const SizedBox(height: 8),
                  _infoRow(Icons.info_outline_rounded, "Reason", leave['reason'] ?? "N/A"),
                ],
              ),
            ),
            if (isPending) 
              Row(
                children: [
                  Expanded(
                    child: _actionButton("REJECT", Colors.redAccent, () => _handleAction(leave, false)),
                  ),
                  const SizedBox(width: 1), // Thin separator
                  Expanded(
                    child: _actionButton("APPROVE", successGreen, () => _handleAction(leave, true)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: primaryIndigo.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: textDark))),
      ],
    );
  }

  Widget _statusChip(String label) {
    bool isPending = label == "PENDING" || label == "WAITING";
    bool isApproved = label == "APPROVED";
    Color chipColor = isPending ? Colors.orange : (isApproved ? successGreen : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: TextStyle(color: chipColor, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}