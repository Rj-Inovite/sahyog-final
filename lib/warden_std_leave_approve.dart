// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/warden_leave_response.dart';

// --- DESIGN SYSTEM ---
const Color primaryIndigo = Color(0xFF1A237E);
const Color backgroundWhite = Color(0xFFF8F9FD);
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
  // ✅ Changed to use the typed model for better data handling
  List<WardenLeaveRecord> _allLeaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeaves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ Fetches leaves and maps them to the WardenLeaveRecord model
  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.getWardenLeaveRequests(); 
      
      if (mounted && response != null) {
        setState(() {
          _allLeaves = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching warden leaves: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ✅ FIXED: Now passes both Student ID and Leave ID as required by your API
  Future<void> _handleAction(WardenLeaveRecord leave, bool approve) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryIndigo)),
    );

    try {
      final int leaveId = leave.id ?? 0;
      final int studentId = leave.student?.id ?? 0;

      if (leaveId == 0 || studentId == 0) {
        throw Exception("Invalid Student or Leave ID");
      }

      bool success = false;

      if (approve) {
        // ✅ Matches updated ApiService: wardenApproveLeave(studentId, leaveId)
        success = await apiService.wardenApproveLeave(studentId, leaveId);
      } else {
        success = await apiService.wardenRejectLeave(leaveId);
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loader

      if (success) {
        _showSnackBar(
          "Leave ${approve ? 'Approved' : 'Rejected'} Successfully", 
          approve ? successGreen : Colors.redAccent
        );
        _fetchLeaves(); // Refresh the list from server
      } else {
        _showSnackBar("Action failed. Request might already be processed.", Colors.orange);
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
      final status = (l.status ?? "").toLowerCase();
      if (filterStatus == "pending") {
        // Show anything that needs Warden attention
        return status == "pending" || status == "waiting" || status == "parent_approved";
      } else {
        // Show processed items
        return status == "approved" || status == "rejected" || status == "manager_approved";
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

  Widget _buildLeaveCard(WardenLeaveRecord leave, bool isPending) {
    final studentName = leave.student?.email?.split('@')[0] ?? "Student";
    final studentEmail = leave.student?.email ?? "N/A";

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
                                  Text(studentName.toUpperCase(), 
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textDark)),
                                  Text(studentEmail, 
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip((leave.status ?? "PENDING").toUpperCase()),
                    ],
                  ),
                  const Divider(height: 25),
                  _infoRow(Icons.calendar_month_rounded, "Requested Date", 
                      leave.startDate ?? "N/A"),
                  const SizedBox(height: 8),
                  _infoRow(Icons.category_outlined, "Type", leave.leaveType?.toUpperCase() ?? "GENERAL"),
                  const SizedBox(height: 8),
                  _infoRow(Icons.info_outline_rounded, "Reason", leave.reason ?? "No reason provided"),
                ],
              ),
            ),
            if (isPending) 
              Row(
                children: [
                  Expanded(
                    child: _actionButton("REJECT", Colors.redAccent, () => _handleAction(leave, false)),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade100), 
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
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
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
    bool isPending = label == "PENDING" || label == "WAITING" || label == "PARENT_APPROVED";
    bool isApproved = label == "APPROVED" || label == "MANAGER_APPROVED";
    Color chipColor = isPending ? Colors.orange : (isApproved ? successGreen : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label.replaceAll('_', ' '), style: TextStyle(color: chipColor, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}