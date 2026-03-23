// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:my_app/data/models/child_profile_response.dart';
import 'package:my_app/data/models/network/api_service.dart';

class ParentPortal extends StatefulWidget {
  final Map<String, String> userData;
  const ParentPortal({super.key, required this.userData});

  @override
  State<ParentPortal> createState() => _ParentPortalState();
}

class _ParentPortalState extends State<ParentPortal> {
  // Theme Colors
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color bgGreen = const Color(0xFFF1F8E9);
  final Color accentOrange = const Color(0xFFF57C00);

  // State Management
  ChildData? childData;
  List<dynamic> _allLeaves = [];
  bool isLoading = true;
  String currentView = "Dashboard";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Centralized data fetcher
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    // Fetching child profile and leaves concurrently
    await Future.wait([
      _fetchChildInfo(),
      _fetchLeaves(),
    ]);

    if (mounted) {
      setState(() => isLoading = false);
      _checkAndShowPendingPopup(); // Check for student applications after load
    }
  }

  /// ✅ Logic to trigger a popup if the student just applied for a leave
  void _checkAndShowPendingPopup() {
    final pending = _allLeaves.where((l) {
      final status = l['status'].toString().toLowerCase();
      return status == 'pending' || status == 'waiting';
    }).toList();

    if (pending.isNotEmpty && currentView == "Dashboard") {
      _showPendingAlertPopup(pending.length);
    }
  }

  Future<void> _fetchChildInfo() async {
    final response = await apiService.getChildProfile();
    if (response != null && response.success) {
      childData = response.data;
    }
  }

  Future<void> _fetchLeaves() async {
    try {
      // API call to guardian/leaves/pending or equivalent
      final List<dynamic> list = await apiService.getLeaves();
      if (mounted) {
        setState(() {
          _allLeaves = list.reversed.toList(); // Newest first
        });
      }
    } catch (e) {
      debugPrint("Error fetching leaves: $e");
    }
  }

  /// ✅ POPUP NOTIFICATION: Shown if a student has an active request
  void _showPendingAlertPopup(int count) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: accentOrange),
              const SizedBox(width: 10),
              const Text("Action Required", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Your child has applied for $count leave(s) that require your immediate approval.",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("LATER", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("VIEW NOW", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }

  /// ✅ DECISION LOGIC: Approves or Rejects the Student application
  Future<void> _handleLeaveDecision(int leaveId, int studentId, bool isApproved) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      dynamic response;
      if (isApproved) {
        response = await apiService.parentApproveLeave(
          studentId: studentId,
          leaveId: leaveId,
        );
      } else {
        response = await apiService.parentRejectLeave(leaveId);
      }

      if (mounted) Navigator.pop(context); // Remove Loader

      bool isSuccess = response != null && 
          (response['success'] == true || response['status'] == 'success');

      if (isSuccess) {
        _showSnackBar(
          "Decision Processed: ${isApproved ? 'Approved' : 'Rejected'}", 
          isApproved ? Colors.green : Colors.red
        );
        _loadInitialData(); // Force refresh to update the UI
      } else {
        _showSnackBar(response?['message'] ?? "Action failed", Colors.orange);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Connection error. Try again later.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: bgColor, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryGreen))
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _getSelectedBody(),
          ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: currentView != "Dashboard" 
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18), 
            onPressed: () => setState(() => currentView = "Dashboard")
          )
        : null,
      title: Text(
        currentView == "Dashboard" ? "Parent Portal" : currentView, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
      ),
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInitialData),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _getSelectedBody() {
    if (_selectedIndex == 1) return _buildAttendanceContent();
    
    switch (currentView) {
      case "Leave logs": return _buildLeaveLogContent();
      case "Mess Menu": return _buildMessMenuContent();
      case "Fees Status": return _buildFeeStatusContent();
      case "Security": return _buildSecurityContent();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final pending = _allLeaves.where((l) {
      final status = l['status'].toString().toLowerCase();
      return status == 'pending' || status == 'waiting';
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          key: const ValueKey("DashboardColumn"),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            
            _buildSectionHeader("My Child"),
            _buildChildSelector(),
            const SizedBox(height: 25),

            // DYNAMIC SECTION: Only shows when a Student applies for leave
            if (pending.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("Approvals Required"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text("${pending.length} NEW", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              ...pending.map((l) => _buildLeaveApprovalCard(l)),
              const SizedBox(height: 25),
            ],
            
            _buildSectionHeader("Campus Overview"),
            _buildChildQuickOverview(),
            const SizedBox(height: 25),
            
            _buildSectionHeader("Quick Access"),
            _buildActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveApprovalCard(dynamic leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentOrange.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: accentOrange.withOpacity(0.1), radius: 18, child: Icon(Icons.mail_outline, color: accentOrange, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave['leave_type'] ?? "General Leave", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Applied on: ${leave['created_at']?.split('T')[0] ?? 'Today'}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(Icons.date_range, "Period", "${leave['start_date']} to ${leave['end_date']}"),
          const SizedBox(height: 8),
          _infoRow(Icons.comment_outlined, "Reason", "${leave['reason']}"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleLeaveDecision(leave['id'], leave['user_id'], false), 
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleLeaveDecision(leave['id'], leave['user_id'], true), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: primaryGreen.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  Widget _buildLeaveLogContent() {
    return _allLeaves.isEmpty 
      ? const Center(child: Text("No history found"))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _allLeaves.length,
          itemBuilder: (context, index) {
            final item = _allLeaves[index];
            final status = item['status'].toString().toLowerCase();
            
            Color statusColor = Colors.orange;
            if (status.contains('approve')) statusColor = Colors.green;
            if (status.contains('reject')) statusColor = Colors.red;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.shade200)
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1), 
                  child: Icon(Icons.history, color: statusColor, size: 20)
                ),
                title: Text(item['leave_type'] ?? "Leave Request", style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${item['start_date']} - ${item['end_date']}", style: const TextStyle(fontSize: 12)),
                trailing: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            );
          },
        );
  }

  // ================= UI HELPERS =================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hello, ${widget.userData['name']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text("Safeguarding your child's campus records", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgGreen, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen.withOpacity(0.1))
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.face_retouching_natural, color: primaryGreen)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(childData?.fullName ?? "Loading Child...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Student ID: ${childData?.studentId ?? '---'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChildQuickOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryGreen, Colors.green.shade900]), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat("Attendance", "94%"),
          _miniStat("Location", "In-Campus"),
          _miniStat("Fees", "Paid"),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10))
    ]
  );

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, 
      crossAxisSpacing: 12, 
      mainAxisSpacing: 12, 
      childAspectRatio: 1.5,
      children: [
        _actionCard(Icons.assignment_turned_in, "Leave logs", Colors.indigo),
        _actionCard(Icons.fastfood, "Mess Menu", Colors.orange),
        _actionCard(Icons.account_balance_wallet, "Fees Status", Colors.redAccent),
        _actionCard(Icons.verified_user, "Security", Colors.blueGrey),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, Color color) {
    return InkWell(
      onTap: () => setState(() => currentView = title),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: color.withOpacity(0.1))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon, color: color, size: 24), 
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12))
          ]
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8), 
    child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 16))
  );

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() { _selectedIndex = i; currentView = "Dashboard"; }),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: "Attendance"),
      ],
    );
  }

  // Placeholder Views
  Widget _buildAttendanceContent() => const Center(child: Text("Attendance Monitoring Active"));
  Widget _buildMessMenuContent() => const Center(child: Text("Weekly Menu: Displaying..."));
  Widget _buildFeeStatusContent() => const Center(child: Text("All receipts are up to date."));
  Widget _buildSecurityContent() => const Center(child: Text("Campus Entry/Exit Logs"));
}