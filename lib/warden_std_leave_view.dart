// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// ✅ Custom import for your API service
import 'package:my_app/data/models/network/api_service.dart';

// --- SAHYOG DESIGN SYSTEM ---
const Color primaryIndigo = Color(0xFF1A237E);
const Color accentBlue = Color(0xFF2196F3);
const Color softGreen = Color(0xFF00B894);
const Color softRed = Color(0xFFFF7675);
const Color warningOrange = Color(0xFFFF9F43);
const Color backgroundWhite = Color(0xFFF8F9FD);
const Color textGrey = Color(0xFF636E72);

class WardenStdLeaveView extends StatefulWidget {
  const WardenStdLeaveView({super.key});

  @override
  State<WardenStdLeaveView> createState() => _WardenStdLeaveViewState();
}

class _WardenStdLeaveViewState extends State<WardenStdLeaveView> {
  bool _isLoading = true;
  List<dynamic> _leaveRequests = []; 
  Timer? _autoRefreshTimer;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // --- AUTO REFRESH LOGIC ---
  void _startAutoRefreshTimer() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 1) {
            _secondsRemaining--;
          } else {
            _secondsRemaining = 10;
            _fetchLeaveRequests(isSilent: true);
          }
        });
      }
    });
  }

  // --- API FETCH ---
  Future<void> _fetchLeaveRequests({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final response = await apiService.getWardenLeaveRequests(); 
      if (mounted && response != null && response['success'] == true) {
        setState(() {
          _leaveRequests = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- APPROVE (API) / REJECT (LOCAL UI) ---
  Future<void> _processAction(dynamic leave, String action) async {
    final int leaveId = leave['id'];
    try {
      if (action == "Approved") {
        bool success = await apiService.wardenApproveLeave(leaveId);
        if (success && mounted) {
          _showFeedback("Leave Approved Successfully", softGreen);
          _fetchLeaveRequests(isSilent: true);
        }
      } else {
        // UI Mock for Reject (Since API is not ready)
        setState(() {
          _leaveRequests.removeWhere((item) => item['id'] == leaveId);
        });
        _showFeedback("Leave Rejected (UI Only)", softRed);
      }
    } catch (e) {
      _showFeedback("Request failed. Try again.", Colors.black87);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- NEW: LEAVE DETAILS POPUP ---
  void _showLeaveDetails(dynamic leave) {
    final student = leave['student'] ?? {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 25),
              const Text("Request Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryIndigo)),
              const Divider(height: 30),
              _detailItem(Icons.alternate_email, "Student Email", student['email'] ?? "N/A"),
              _detailItem(Icons.fingerprint, "Student ID", student['id']?.toString() ?? "N/A"),
              _detailItem(Icons.category_outlined, "Leave Type", leave['leave_type']?.toString().toUpperCase() ?? "GENERAL"),
              _detailItem(Icons.event_available, "Date Requested", leave['start_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(leave['start_date'])) : "N/A"),
              _detailItem(Icons.info_outline, "Status", leave['status']?.toString().toUpperCase() ?? "PENDING"),
              const SizedBox(height: 10),
              const Text("Reason for Leave:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryIndigo)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: backgroundWhite, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                child: Text(leave['reason'] ?? "No reason provided by student.", style: const TextStyle(color: textGrey, height: 1.5)),
              ),
              const SizedBox(height: 30),
              if (leave['status'] == 'pending' || leave['status'] == 'parent_approved')
                Row(
                  children: [
                    Expanded(child: _actionBtn("Reject", softRed, Icons.close, () { Navigator.pop(context); _processAction(leave, "Rejected"); })),
                    const SizedBox(width: 15),
                    Expanded(child: _actionBtn("Approve", softGreen, Icons.check, () { Navigator.pop(context); _processAction(leave, "Approved"); })),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentBlue),
          const SizedBox(width: 12),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, color: textGrey)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: RefreshIndicator(
        onRefresh: () => _fetchLeaveRequests(),
        color: primaryIndigo,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildAppBar(),
            _buildSyncHeader(),
            _isLoading && _leaveRequests.isEmpty
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primaryIndigo)))
                : _leaveRequests.isEmpty ? SliverFillRemaining(child: _buildEmptyState()) : _buildLeaveList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110.0, pinned: true, elevation: 0, backgroundColor: primaryIndigo, centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      flexibleSpace: const FlexibleSpaceBar(title: Text("Leave Management", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
    );
  }

  Widget _buildSyncHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("NEXT SYNC: ${_secondsRemaining}s", style: const TextStyle(color: textGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Row(children: [Icon(Icons.circle, size: 8, color: softGreen), SizedBox(width: 5), Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: AnimationLimiter(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => AnimationConfiguration.staggeredList(
              position: index, duration: const Duration(milliseconds: 500),
              child: SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: _buildLeaveCard(_leaveRequests[index]))),
            ),
            childCount: _leaveRequests.length,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(dynamic leave) {
    final student = leave['student'] ?? {};
    final String status = leave['status'] ?? 'pending';
    
    return GestureDetector(
      onTap: () => _showLeaveDetails(leave), // ✅ Opens Detail Popup
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(backgroundColor: primaryIndigo.withOpacity(0.05), child: const Icon(Icons.person_rounded, color: primaryIndigo)),
              title: Text(student['email'] ?? 'New Student', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              subtitle: Text(leave['leave_type']?.toString().toUpperCase() ?? 'GENERAL', style: const TextStyle(fontSize: 11, color: accentBlue, fontWeight: FontWeight.bold)),
              trailing: _buildStatusChip(status),
            ),
            const Divider(indent: 20, endIndent: 20, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: textGrey),
                  const SizedBox(width: 8),
                  Text(leave['start_date'] != null ? DateFormat('EEE, dd MMM').format(DateTime.parse(leave['start_date'])) : "N/A", style: const TextStyle(fontSize: 12, color: textGrey)),
                  const Spacer(),
                  const Text("View Details", style: TextStyle(color: primaryIndigo, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Icon(Icons.chevron_right, size: 16, color: primaryIndigo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = (status == 'approved' || status == 'manager_approved') ? softGreen : (status == 'rejected' ? softRed : (status == 'parent_approved' ? accentBlue : warningOrange));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1), foregroundColor: color, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline, size: 80, color: primaryIndigo.withOpacity(0.1)), const SizedBox(height: 15), const Text("No Pending Leaves", style: TextStyle(fontWeight: FontWeight.bold, color: primaryIndigo))]));
  }
}