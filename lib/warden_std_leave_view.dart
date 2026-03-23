// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// --- PROJECT INTEGRATIONS ---
import 'data/models/network/api_service.dart';
import 'package:my_app/data/models/network/student_list_response.dart'; 

// --- ENHANCED DESIGN SYSTEM ---
const Color primaryIndigo = Color(0xFF3F51B5);
const Color darkIndigo = Color(0xFF303F9F);
const Color accentIndigo = Color(0xFFC5CAE9);
const Color backgroundWhite = Color(0xFFF8F9FD);
const Color cardShadow = Color(0x1A000000);
const Color textDark = Color(0xFF2D3436);
const Color warningOrange = Color(0xFFFF9F43);
const Color softRed = Color(0xFFFF7675);
const Color softGreen = Color(0xFF55E6C1);

class WardenStdLeaveView extends StatefulWidget {
  const WardenStdLeaveView({super.key});

  @override
  State<WardenStdLeaveView> createState() => _WardenStdLeaveViewState();
}

class _WardenStdLeaveViewState extends State<WardenStdLeaveView> {
  bool _isLoading = true;
  List<Student> _leaveRequests = []; 
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

  // --- LOGIC: 10 SECOND AUTO REFRESH ---
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

  // --- API: FETCH DATA ---
  Future<void> _fetchLeaveRequests({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final response = await apiService.getStudentList(); 
      if (response != null && response.success) {
        if (mounted) {
          setState(() {
            // For production: filter students who actually have a pending leave status
            _leaveRequests = response.students.toList(); 
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Sync Error: $e");
    }
  }

  // --- LOGIC: APPROVE / REJECT ACTION ---
  Future<void> _handleAction(Student student, String status) async {
    // Immediate Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Processing ${status.toUpperCase()} for ${student.firstName}..."),
        backgroundColor: darkIndigo,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      // API CALL: Ensure your ApiService has an updateLeaveStatus method
      // For now, we simulate success and update the UI locally
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() {
          _leaveRequests.removeWhere((s) => s.id == student.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully $status ${student.firstName}'s request"),
            backgroundColor: status == "Approved" ? softGreen : softRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Error. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildFancyAppBar(context),
          SliverToBoxAdapter(child: _buildSyncIndicator()),
          _isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primaryIndigo)))
            : _leaveRequests.isEmpty 
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            curve: Curves.easeOutQuart,
                            child: FadeInAnimation(
                              child: _buildLeaveCard(_leaveRequests[index]),
                            ),
                          ),
                        );
                      },
                      childCount: _leaveRequests.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: GLASS APP BAR ---
  Widget _buildFancyAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryIndigo,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 55, bottom: 16),
        title: const Text("Student Leaves", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.8)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryIndigo, darkIndigo],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Icon(Icons.beach_access_rounded, size: 150, color: Colors.white.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT: LIVE SYNC BAR ---
  Widget _buildSyncIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: softGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.radar_rounded, color: softGreen, size: 14),
                SizedBox(width: 6),
                Text("Live Monitor", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: softGreen)),
              ],
            ),
          ),
          Text("Syncing in ${_secondsRemaining}s", style: TextStyle(fontSize: 11, color: primaryIndigo.withOpacity(0.6), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- UI COMPONENT: ANIMATED LEAVE CARD ---
  Widget _buildLeaveCard(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 25, offset: Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: primaryIndigo.withOpacity(0.04),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryIndigo.withOpacity(0.1),
                    child: Text(student.firstName.isNotEmpty ? student.firstName[0] : "?", 
                        style: const TextStyle(color: primaryIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${student.firstName} ${student.lastName ?? ''}", 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textDark)),
                        const SizedBox(height: 2),
                        Text("Room: ${100 + student.id} | Code: ${student.studentCode}", 
                            style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("REQUEST DETAILS", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text("The student has requested leave for emergency family reasons. Verification via phone call is recommended before approval.", 
                    style: TextStyle(height: 1.5, color: textDark.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: _buildActionButton("Reject", softRed, Icons.close_rounded, () => _handleAction(student, "Rejected"))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildActionButton("Approve", softGreen, Icons.check_rounded, () => _handleAction(student, "Approved"))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warningOrange.withOpacity(0.2)),
      ),
      child: const Text("PENDING", style: TextStyle(color: warningOrange, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, size: 100, color: primaryIndigo.withOpacity(0.1)),
          const SizedBox(height: 25),
          const Text("Clear Desk!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 8),
          const Text("No pending leave requests to review.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          TextButton.icon(
            onPressed: () => _fetchLeaveRequests(),
            icon: const Icon(Icons.refresh, color: primaryIndigo),
            label: const Text("Check Again", style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}