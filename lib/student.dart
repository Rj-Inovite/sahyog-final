// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/data/models/my_hostel_info_response.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:animate_do/animate_do.dart';

// --- REQUIRED PROJECT IMPORTS ---
import 'login.dart';
import 'student_profile.dart';
import 'warden_chat_screen.dart';
import 'leave_history_page.dart';

// --- MODELS LAYER ---
import 'package:my_app/data/models/network/my_room_response.dart';


class ChatData {
  static List<Map<String, dynamic>> messages = [
    {
      "text": "Hello Warden, when will the gym be open?",
      "isMe": true,
      "time": "10:00 AM",
      "status": "read",
      "isImage": false
    },
    {
      "text": "It is open from 6:00 AM to 9:00 PM.",
      "isMe": false,
      "time": "10:05 AM",
      "status": "read",
      "isImage": false
    },
  ];

  static List<DateTime> declaredHolidays = [
    DateTime(2026, 3, 14),
    DateTime(2026, 3, 30),
    DateTime(2026, 4, 10),
  ];
}

// --- MAIN DASHBOARD CONTROLLER ---
class StudentDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const StudentDashboard({super.key, required this.userData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final Color primaryBlue = const Color(0xFF1A237E);
  final Color secondaryBlue = const Color(0xFF283593);
  final Color accentBlue = const Color(0xFF3949AB);
  final Color softBg = const Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          _HomeContent(
              userData: widget.userData,
              primaryBlue: primaryBlue,
              secondaryBlue: secondaryBlue),
          const AttendancePage(),
          WardenChatScreen(userData: widget.userData),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildEnhancedBottomNav(),
    );
  }

  Widget _buildEnhancedBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: primaryBlue,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _navigateToPage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: "Attendance"),
            BottomNavigationBarItem(
                icon: Icon(Icons.forum_rounded), label: "Inbox"),
            BottomNavigationBarItem(
                icon: Icon(Icons.tune_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

// --- MODULE: HOME CONTENT (HANDLES ROOM & HOSTEL API + REFRESH) ---
class _HomeContent extends StatefulWidget {
  final Map<String, String> userData;
  final Color primaryBlue;
  final Color secondaryBlue;

  const _HomeContent(
      {required this.userData,
      required this.primaryBlue,
      required this.secondaryBlue});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isLoadingRoom = true;
  bool _isLoadingHostel = true;
  MyRoomResponse? _roomData;
  MyHostelInfoResponse? _hostelData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // Logic to refresh all dashboard data
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoadingRoom = true;
      _isLoadingHostel = true;
    });
    
    await Future.wait([
      _fetchRoomDetails(),
      _fetchHostelInfo(),
    ]);
  }

  Future<void> _fetchRoomDetails() async {
    try {
      final response = await apiService.getMyRoomDetails();
      if (mounted) {
        setState(() {
          _roomData = response;
          _isLoadingRoom = false;
        });
      }
    } catch (e) {
      debugPrint("Room Fetch Error: $e");
      if (mounted) setState(() => _isLoadingRoom = false);
    }
  }

  Future<void> _fetchHostelInfo() async {
    try {
      final response = await apiService.getMyHostelInfo();
      if (mounted) {
        setState(() {
          _hostelData = response;
          _isLoadingHostel = false;
        });
      }
    } catch (e) {
      debugPrint("Hostel Info Fetch Error: $e");
      if (mounted) setState(() => _isLoadingHostel = false);
    }
  }

  int _parseUserId(Map<String, String> data) {
    final idStr = data['id'] ?? data['user_id'] ?? '';
    return int.tryParse(idStr.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: widget.primaryBlue,
      onRefresh: _fetchDashboardData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.primaryBlue, widget.secondaryBlue]
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticePage())),
            ),
            title: const Text("SAHYOG PORTAL",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 18,
                    color: Colors.white)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentProfile(userData: widget.userData))),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                FadeInDown(duration: const Duration(milliseconds: 500), child: _buildSectionHeader("Overview")),
                FadeInDown(duration: const Duration(milliseconds: 600), child: _buildIdentityCard()),
                const SizedBox(height: 20),
                FadeInDown(duration: const Duration(milliseconds: 700), child: _buildResidenceInfo()),
                const SizedBox(height: 25),
                FadeInDown(duration: const Duration(milliseconds: 800), child: _buildSectionHeader("Hostel Services")),
                _buildBentoGrid(context, widget.userData),
                const SizedBox(height: 25),
                FadeInDown(duration: const Duration(milliseconds: 900), child: _buildSectionHeader("Primary Support")),
                _buildManagerList(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1C1E))),
    );
  }

  Widget _buildIdentityCard() {
    String name = _isLoadingHostel ? "..." : (_hostelData?.data?.studentName ?? widget.userData['name'] ?? "Student");
    String hostelName = _isLoadingHostel ? "Fetching Hostel..." : (_hostelData?.data?.hostelName ?? "No Hostel Assigned");

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.primaryBlue, widget.secondaryBlue.withBlue(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: widget.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35, 
              backgroundColor: Colors.white12, 
              child: Icon(Icons.school_rounded, color: Colors.white, size: 35)
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi, $name",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(hostelName,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: const Text("VERIFIED STUDENT",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceInfo() {
    String roomNo = _isLoadingRoom ? "..." : (_roomData?.data?.roomNumber ?? "N/A");
    String bedNo = _isLoadingRoom ? "..." : (_roomData?.data?.bedNumber ?? "N/A");

    return Row(
      children: [
        Expanded(child: _infoTile("ROOM NO", roomNo, Icons.meeting_room_rounded, widget.primaryBlue)),
        const SizedBox(width: 15),
        Expanded(child: _infoTile("BED NO", bedNo, Icons.bed_rounded, widget.secondaryBlue)),
      ],
    );
  }

  Widget _infoTile(String label, String val, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100)
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 28),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, Map<String, String> userData) {
    final int userId = _parseUserId(userData);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _bentoItem(context, "Leave", Icons.holiday_village_rounded, widget.primaryBlue, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaveHistoryPage(userId: userId)))),
        _bentoItem(context, "Payments", Icons.account_balance_wallet_rounded, widget.secondaryBlue, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsPage()))),
        _bentoItem(context, "Support", Icons.support_agent_rounded, widget.primaryBlue, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceDeskPage()))),
        _bentoItem(context, "Notice", Icons.campaign_rounded, widget.secondaryBlue, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticePage()))),
      ],
    );
  }

  Widget _bentoItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade100)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagerList() {
    if (_isLoadingHostel) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final managers = _hostelData?.data?.assignedManagers ?? [];

    if (managers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("No assigned managers found")),
      );
    }

    return Column(
      children: managers.map((manager) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade100)
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: widget.primaryBlue.withOpacity(0.1), 
              child: Icon(Icons.person_4_rounded, color: widget.primaryBlue)
            ),
            title: Text("${manager.firstName} ${manager.lastName}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text("Hostel Manager | ${manager.mobile}", 
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WardenChatScreen(userData: widget.userData))),
          ),
        ),
      )).toList(),
    );
  }
}

// --- MODULE 1: LEAVE APPLICATION ---
class LeavePage extends StatefulWidget {
  final Map<String, String> userData;
  const LeavePage({super.key, required this.userData});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final Color primaryColor = const Color(0xFF1A237E);
  final TextEditingController _reasonController = TextEditingController();
  bool isSingleDay = true;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;
  bool _loading = false;

  int _getUserId() {
    final idStr = widget.userData['id'] ?? widget.userData['user_id'] ?? '';
    return int.tryParse(idStr) ?? 0;
  }

  Future<void> _submit() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a reason")));
      return;
    }
    if (!isSingleDay && selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a date range")));
      return;
    }

    setState(() => _loading = true);

    try {
      String startDate = isSingleDay
          ? selectedDate.toIso8601String()
          : selectedRange!.start.toIso8601String();

      String endDate = isSingleDay
          ? selectedDate.toIso8601String()
          : selectedRange!.end.toIso8601String();

      await apiService.applyLeave(
        userId: _getUserId(),
        leaveType: isSingleDay ? "Casual" : "Medical",
        startDate: startDate,
        endDate: endDate,
        reason: _reasonController.text.trim(),
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Application Submitted"),
          content: const Text("Your leave request has been sent to the warden."),
          actions: [
            TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("DONE")),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(title: const Text("Leave Portal"), backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  _toggleBtn("One Day", isSingleDay, () => setState(() => isSingleDay = true)),
                  _toggleBtn("Multiple", !isSingleDay, () => setState(() => isSingleDay = false)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
              padding: const EdgeInsets.all(10),
              child: isSingleDay 
                ? CalendarDatePicker(initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027), onDateChanged: (d) => setState(() => selectedDate = d)) 
                : _rangePicker(),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _reasonController, 
              maxLines: 4, 
              decoration: InputDecoration(
                hintText: "Reason for leave...", 
                filled: true, 
                fillColor: Colors.white, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
              )
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, 
                minimumSize: const Size(double.infinity, 60), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: primaryColor.withOpacity(0.4)
              ),
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("SEND APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap, 
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), 
          padding: const EdgeInsets.symmetric(vertical: 12), 
          decoration: BoxDecoration(color: active ? primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(10)), 
          child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)))
        )
      )
    );
  }

  Widget _rangePicker() {
    return InkWell(
      onTap: () async {
        final r = await showDateRangePicker(
          context: context, 
          firstDate: DateTime.now(), 
          lastDate: DateTime(2027),
          builder: (context, child) {
            return Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: primaryColor)), child: child!);
          }
        );
        if (r != null) setState(() => selectedRange = r);
      },
      child: Container(
        height: 150, width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.date_range_rounded, size: 50, color: primaryColor),
          const SizedBox(height: 10),
          Text(selectedRange == null ? "Select From - To Date" : "${DateFormat('dd MMM').format(selectedRange!.start)} - ${DateFormat('dd MMM').format(selectedRange!.end)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
    );
  }
}

// --- MODULE 2: ATTENDANCE ---
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A237E);
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Log"), backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildProgressCircle(primaryBlue),
          const SizedBox(height: 30),
          const Text("Monthly Record", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemCount: 30,
                itemBuilder: (ctx, i) {
                  bool isPresent = i % 7 != 0;
                  return Container(
                    decoration: BoxDecoration(
                      color: isPresent ? primaryBlue.withOpacity(0.05) : Colors.red.withOpacity(0.05), 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: isPresent ? primaryBlue.withOpacity(0.2) : Colors.red.withOpacity(0.2), width: 1)
                    ),
                    child: Center(child: Text("${i+1}", style: TextStyle(color: isPresent ? primaryBlue : Colors.red, fontWeight: FontWeight.bold))),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressCircle(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(height: 160, width: 160, child: CircularProgressIndicator(value: 0.94, strokeWidth: 14, color: color, backgroundColor: color.withOpacity(0.1), strokeCap: StrokeCap.round)),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("94%", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
          Text("ATTENDANCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
        ]),
      ],
    );
  }
}

// --- MODULE 4: PAYMENTS ---
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A237E);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(title: const Text("Fee Management"), backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _feeCard("Hostel Accommodation", "50,000", "PAID", Colors.green),
          _feeCard("Mess Charges (Term 1)", "12,000", "PENDING", Colors.orange),
          const Spacer(),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, 
              minimumSize: const Size(double.infinity, 65), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: primaryBlue.withOpacity(0.4)
            ), 
            child: const Text("PROCEED TO PAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1))
          )
        ]),
      ),
    );
  }

  Widget _feeCard(String title, String amt, String status, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), 
      padding: const EdgeInsets.all(22), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text("₹ $amt", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1A237E)))
          ]), 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
            decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), 
            child: Text(status, style: TextStyle(color: col, fontWeight: FontWeight.w900, fontSize: 11))
          )
        ]
      )
    );
  }
}

// --- PLACEHOLDER PAGES ---
class NoticePage extends StatelessWidget { const NoticePage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Notices"))); }
class RaiseComplaintPage extends StatelessWidget { const RaiseComplaintPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Complaints"))); }
class ServiceDeskPage extends StatelessWidget { const ServiceDeskPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Support"))); }
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Settings"))); }
class MessMenuPage extends StatelessWidget { const MessMenuPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Mess Menu"))); }