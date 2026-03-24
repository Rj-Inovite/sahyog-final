// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/data/models/child_profile_response.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/parent_leave_list.dart';

class ParentPortal extends StatefulWidget {
  final Map<String, String> userData;
  const ParentPortal({super.key, required this.userData});

  @override
  State<ParentPortal> createState() => _ParentPortalState();
}

class _ParentPortalState extends State<ParentPortal> {
  // --- Theme Colors ---
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color bgGreen = const Color(0xFFF1F8E9);
  final Color accentOrange = const Color(0xFFF57C00);

  // --- State Management ---
  ChildData? childData;
  List<Leave> _allLeaves = [];
  bool isLoading = true;
  String currentView = "Dashboard";
  int _selectedIndex = 0;

  // --- Auto-Refresh Timer ---
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Refreshes data automatically every 15 seconds while on Dashboard
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && currentView == "Dashboard" && !isLoading) {
        _silentRefresh();
      }
    });
  }

  /// Initial Load with full-screen indicator
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await _silentRefresh();
    } catch (e) {
      debugPrint("Initialization Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        _checkAndShowPendingPopup();
      }
    }
  }

  /// Silent Background Sync (No loading spinner)
  Future<void> _silentRefresh() async {
    try {
      await Future.wait([
        _fetchChildInfo(),
        _fetchLeaves(),
      ]);
    } catch (e) {
      debugPrint("Background Sync Error: $e");
    }
  }

  /// Fetches Child Profile from API (Updated for List Support)
  Future<void> _fetchChildInfo() async {
    try {
      final response = await apiService.getChildProfile();
      
      // FIX: Check for success and ensure the data list is not empty
      if (response != null && response.success && response.data != null && response.data!.isNotEmpty) {
        if (mounted) {
          setState(() {
            // Because the API returns "data": [ ... ], we take the first item
            childData = response.data![0]; 
          });
          debugPrint("Child Profile Loaded: ${childData?.fullName}");
        }
      } else {
        debugPrint("API successful but no child data found in list.");
      }
    } catch (e) {
      debugPrint("Exception in _fetchChildInfo: $e");
    }
  }

  /// Fetches Leave History and identifies pending requests
  Future<void> _fetchLeaves() async {
    try {
      final response = await apiService.getParentLeaveHistory();
      if (mounted && response != null && response.leaves != null) {
        setState(() {
          _allLeaves = List.from(response.leaves!.reversed);
        });
      }
    } catch (e) {
      debugPrint("Error fetching leaves: $e");
    }
  }

  void _checkAndShowPendingPopup() {
    final pending = _allLeaves.where((l) {
      final status = l.status?.toLowerCase() ?? '';
      return status == 'pending' || status == 'waiting';
    }).toList();

    if (pending.isNotEmpty && currentView == "Dashboard") {
      _showPendingAlertPopup(pending.length);
    }
  }

  void _showPendingAlertPopup(int count) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || !ModalRoute.of(context)!.isCurrent) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.notification_important, color: accentOrange),
              const SizedBox(width: 10),
              const Text("Action Required", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Your child has $count leave request(s) awaiting your approval."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("LATER", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => currentView = "Leave logs");
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text("VIEW NOW", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }

  /// Processes the Parent's decision (Approve/Reject)
  Future<void> _handleLeaveDecision(int leaveId, String studentCode, bool isApproved) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final int sId = int.tryParse(studentCode) ?? 0;
      dynamic response;
      
      if (isApproved) {
        response = await apiService.parentApproveLeave(
          studentId: sId,
          leaveId: leaveId,
        );
      } else {
        response = await apiService.parentRejectLeave(leaveId);
      }

      if (mounted) Navigator.pop(context); 

      if (response != null && (response['success'] == true || response['status'] == 'success')) {
        _showSnackBar("Leave ${isApproved ? 'Approved' : 'Rejected'} successfully", isApproved ? Colors.green : Colors.red);
        _loadInitialData(); 
      } else {
        _showSnackBar(response?['message'] ?? "Action failed", Colors.orange);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Process failed. Please try again.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
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
              onPressed: () => setState(() => currentView = "Dashboard"))
          : null,
      title: Text(currentView == "Dashboard" ? "Parent Portal" : currentView,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded), 
          onPressed: _loadInitialData,
          tooltip: "Refresh Data",
        ),
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
      final status = l.status?.toLowerCase() ?? '';
      return status == 'pending' || status == 'waiting';
    }).toList();

    return RefreshIndicator(
      onRefresh: _silentRefresh,
      color: primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSectionHeader("Active Student Profile"),
            _buildChildSelector(),
            const SizedBox(height: 25),
            if (pending.isNotEmpty) ...[
              _buildSectionHeader("Pending Approvals (${pending.length})"),
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

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgGreen,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryGreen.withOpacity(0.2))),
      child: Row(
        children: [
          CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_pin, color: primaryGreen, size: 30)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childData?.fullName ?? "No Profile Found",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Student ID: ${childData?.studentId ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          if (childData != null)
            const Icon(Icons.verified, color: Colors.blue, size: 20),
        ],
      ),
    );
  }

  Widget _buildLeaveApprovalCard(Leave leave) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: accentOrange, size: 20),
                const SizedBox(width: 10),
                Text(leave.leaveType ?? "Leave Request",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(5)),
                  child: const Text("PENDING", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),
            Text("Duration: ${leave.startDate} to ${leave.endDate}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text("Reason: ${leave.reason}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleLeaveDecision(leave.id!, childData?.studentId ?? "0", false),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text("REJECT"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleLeaveDecision(leave.id!, childData?.studentId ?? "0", true),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                    child: const Text("APPROVE", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveLogContent() {
    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      color: primaryGreen,
      child: _allLeaves.isEmpty
          ? const Center(child: Text("No leave history available"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _allLeaves.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _allLeaves[index];
                final status = item.status?.toLowerCase() ?? '';
                
                Color statusColor = Colors.orange;
                IconData statusIcon = Icons.hourglass_empty;

                if (status.contains('approve')) {
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle_outline;
                } else if (status.contains('reject')) {
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel_outlined;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  title: Text(item.leaveType ?? "General Leave", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.startDate} - ${item.endDate}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hello, ${widget.userData['name']}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text("Welcome to Sahyog Parent Portal",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildChildQuickOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(label: "Attendance", value: "94%"),
          _MiniStat(label: "Status", value: childData?.hostelInfo?.status ?? "In-Campus"),
          _MiniStat(label: "Fees", value: "Paid"),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(Icons.history_edu, "Leave logs", Colors.indigo),
        _actionCard(Icons.restaurant_menu, "Mess Menu", Colors.orange),
        _actionCard(Icons.payments_outlined, "Fees Status", Colors.redAccent),
        _actionCard(Icons.admin_panel_settings_outlined, "Security", Colors.blueGrey),
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
            border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13))
            ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryGreen,
              fontSize: 16)));

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() {
        _selectedIndex = i;
        currentView = "Dashboard";
      }),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: "Attendance"),
      ],
    );
  }

  Widget _buildAttendanceContent() => const Center(child: Text("Attendance Monitoring System Active"));
  Widget _buildMessMenuContent() => const Center(child: Text("Weekly Hostel Mess Menu"));
  Widget _buildFeeStatusContent() => const Center(child: Text("Fee Payment History & Dues"));
  Widget _buildSecurityContent() => const Center(child: Text("Entry/Exit Logs & Permissions"));
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))
    ]);
  }
}