import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- REQUIRED PROJECT IMPORTS ---
import 'login.dart';
import 'student_profile.dart'; 
import 'warden_chat_screen.dart'; 

// --- DATA & MODELS LAYER ---
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

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  
  // Professional Theme Palette
  final Color primaryIndigo = const Color(0xFF3F51B5);
  final Color accentPink = const Color(0xFFE91E63);
  final Color softBg = const Color(0xFFF1F4F9);

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
    _pageController.animateToPage(
      index, 
      duration: const Duration(milliseconds: 600), 
      curve: Curves.easeInOutQuart
    );
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
          _HomeContent(userData: widget.userData, primaryIndigo: primaryIndigo, accentPink: accentPink),
          const AttendancePage(),
          WardenChatScreen(userData: widget.userData),
          SettingsPage(userData: widget.userData), // FIXED: Passing actual userData
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: accentPink,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _navigateToPage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "Attendance"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: "Inbox"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

// --- MODULE: HOME CONTENT ---
class _HomeContent extends StatelessWidget {
  final Map<String, String> userData;
  final Color primaryIndigo;
  final Color accentPink;

  const _HomeContent({required this.userData, required this.primaryIndigo, required this.accentPink});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 80,
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryIndigo, accentPink]),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticePage())),
          ),
          title: const Text("SAHYOG PORTAL", 
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 20, color: Colors.white)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => StudentProfile(userData: userData)) // FIXED: Pass real data
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 10),
              _buildSectionHeader("Overview"),
              _buildIdentityCard(),
              const SizedBox(height: 20),
              _buildResidenceInfo(),
              const SizedBox(height: 25),
              _buildSectionHeader("Hostel Services"),
              _buildBentoGrid(context),
              const SizedBox(height: 25),
              _buildSectionHeader("Primary Support"),
              _buildWardenQuickLink(context),
              const SizedBox(height: 100), 
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D3142))),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const CircleAvatar(radius: 35, backgroundColor: Colors.white24, child: Icon(Icons.school, color: Colors.white, size: 35)),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, ${userData['name'] ?? "Student"}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("Status: Verified Student", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceInfo() {
    return Row(
      children: [
        Expanded(child: _infoTile("ROOM", userData['room'] ?? "102", Icons.meeting_room, const Color(0xFFFF9800))),
        const SizedBox(width: 15),
        Expanded(child: _infoTile("BLOCK", "A-WING", Icons.domain, const Color(0xFF4CAF50))),
      ],
    );
  }

  Widget _infoTile(String label, String val, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          Icon(icon, color: col, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF3F51B5))),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _bentoItem(context, "Leave", Icons.holiday_village, const Color(0xFF6366F1), const LeavePage()),
        _bentoItem(context, "Mess", Icons.restaurant, const Color(0xFFF59E0B), const MessMenuPage()),
        _bentoItem(context, "Payments", Icons.account_balance_wallet, const Color(0xFFEC4899), const PaymentsPage()),
        _bentoItem(context, "Complaints", Icons.assignment_late, const Color(0xFFEF4444), const RaiseComplaintPage()),
        _bentoItem(context, "Support", Icons.support_agent, const Color(0xFF10B981), const ServiceDeskPage()),
        _bentoItem(context, "Notice", Icons.campaign, const Color(0xFF8B5CF6), const NoticePage()),
      ],
    );
  }

  Widget _bentoItem(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        borderRadius: BorderRadius.circular(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildWardenQuickLink(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: primaryIndigo.withOpacity(0.1), child: Icon(Icons.person_4, color: primaryIndigo)),
        title: const Text("Mrs. Sunita Sharma", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Block Warden | Available"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WardenChatScreen(userData: userData))),
      ),
    );
  }
}

// --- MODULE 1: LEAVE APPLICATION ---
class LeavePage extends StatefulWidget {
  const LeavePage({super.key});
  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final Color primaryColor = const Color(0xFF6366F1);
  final TextEditingController _reasonController = TextEditingController();
  bool isSingleDay = true;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;

  void _submit() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a reason")));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Application Submitted"),
        content: const Text("Your leave request is under review by the warden."),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("DONE"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(title: const Text("Leave Portal"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _toggleBtn("One Day", isSingleDay, () => setState(() => isSingleDay = true)),
                  _toggleBtn("Multiple", !isSingleDay, () => setState(() => isSingleDay = false)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            isSingleDay 
              ? CalendarDatePicker(initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027), onDateChanged: (d) => setState(() => selectedDate = d))
              : _rangePicker(),
            const SizedBox(height: 25),
            TextField(controller: _reasonController, maxLines: 4, decoration: InputDecoration(hintText: "Reason for leave...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none))),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: _submit,
              child: const Text("SEND APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _rangePicker() {
    return InkWell(
      onTap: () async {
        final r = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2027));
        if (r != null) setState(() => selectedRange = r);
      },
      child: Container(
        height: 150, width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.date_range, size: 50, color: Color(0xFF6366F1)),
          const SizedBox(height: 10),
          Text(selectedRange == null ? "Select From - To Date" : "${DateFormat('dd MMM').format(selectedRange!.start)} - ${DateFormat('dd MMM').format(selectedRange!.end)}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Log"), backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildProgressCircle(),
          const SizedBox(height: 30),
          const Text("Monthly Record", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
                itemCount: 30,
                itemBuilder: (ctx, i) {
                  bool isPresent = i % 7 != 0;
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isPresent ? Colors.green : Colors.red, width: 2)),
                    child: Center(child: Text("${i+1}", style: TextStyle(color: isPresent ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(height: 150, width: 150, child: CircularProgressIndicator(value: 0.94, strokeWidth: 12, color: Colors.indigo, backgroundColor: Colors.indigo.withOpacity(0.1))),
        const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("94%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), Text("OVERALL")]),
      ],
    );
  }
}

// --- MODULE 3: MESS MENU ---
class MessMenuPage extends StatelessWidget {
  const MessMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> menu = [
      {"day": "Mon", "b": "Aloo Paratha", "l": "Rajma Rice", "d": "Mix Veg"},
      {"day": "Tue", "b": "Poha & Tea", "l": "Kadhi Pakoda", "d": "Paneer Butter"},
      {"day": "Wed", "b": "Idli Sambhar", "l": "Veg Biryani", "d": "Dal Tadka"},
      {"day": "Thu", "b": "Upma", "l": "Chole Bhature", "d": "Egg Curry"},
      {"day": "Fri", "b": "Bread Butter", "l": "Aloo Gobhi", "d": "Chicken/Soya"},
      {"day": "Sat", "b": "Puri Sabzi", "l": "Dal Makhani", "d": "Kofta"},
      {"day": "Sun", "b": "Special Breakfast", "l": "Special Veg", "d": "Special Feast"},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(title: const Text("Weekly Menu"), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menu.length,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            title: Text(menu[i]['day']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              _menuRow("Breakfast", menu[i]['b']!),
              _menuRow("Lunch", menu[i]['l']!),
              _menuRow("Dinner", menu[i]['d']!),
            ],
          ),
        ),
      ),
    );
  }
  Widget _menuRow(String type, String dish) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(type, style: const TextStyle(color: Colors.grey)), Text(dish, style: const TextStyle(fontWeight: FontWeight.w600))]));
}

// --- MODULE 4: PAYMENTS ---
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFEC4899);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(title: const Text("Fee Status"), backgroundColor: pink, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _feeCard("Hostel Accommodation", "50,000", "PAID", Colors.green),
            _feeCard("Mess Charges (Term 1)", "12,000", "PENDING", Colors.orange),
            _feeCard("Security Deposit", "5,000", "PAID", Colors.green),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Outstanding Balance"), Text("₹ 12,000", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: pink))]),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: pink, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("PROCEED TO PAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              ]),
            )
          ],
        ),
      ),
    );
  }
  Widget _feeCard(String t, String a, String s, Color c) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(t), subtitle: Text("₹$a"), trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(s, style: TextStyle(color: c, fontWeight: FontWeight.bold)))));
}

// --- MODULE 5: COMPLAINTS ---
class RaiseComplaintPage extends StatefulWidget {
  const RaiseComplaintPage({super.key});
  @override
  State<RaiseComplaintPage> createState() => _RaiseComplaintPageState();
}

class _RaiseComplaintPageState extends State<RaiseComplaintPage> {
  String? category;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(title: const Text("Report Issue"), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          DropdownButtonFormField<String>(items: ["Electric", "Plumbing", "Wifi", "Cleaning"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => category = v), decoration: const InputDecoration(hintText: "Category", filled: true, fillColor: Colors.white)),
          const SizedBox(height: 20),
          TextField(maxLines: 5, decoration: const InputDecoration(hintText: "Explain problem...", filled: true, fillColor: Colors.white)),
          const Spacer(),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 60)), onPressed: () => Navigator.pop(context), child: const Text("FILE COMPLAINT", style: TextStyle(color: Colors.white)))
        ]),
      ),
    );
  }
}

// --- MODULE 6: SERVICE DESK ---
class ServiceDeskPage extends StatelessWidget {
  const ServiceDeskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _contact("Block Warden", "9876543201", Icons.person),
          _contact("Hostel Security", "9876543202", Icons.security),
          _contact("Plumbing Service", "9876543203", Icons.plumbing),
          _contact("Electrician", "9876543204", Icons.electrical_services),
        ],
      ),
    );
  }
  Widget _contact(String n, String ph, IconData i) => Card(child: ListTile(leading: Icon(i, color: Colors.teal), title: Text(n), subtitle: Text(ph), trailing: const Icon(Icons.call, color: Colors.green)));
}

// --- MODULE 7: SETTINGS & ACCOUNT ---
class SettingsPage extends StatelessWidget {
  final Map<String, String> userData;
  const SettingsPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings"), backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50))),
          const SizedBox(height: 10),
          Center(child: Text(userData['email'] ?? "user@sahyog.com", style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          _settingTile(context, "Edit Profile", Icons.person_outline, StudentProfile(userData: userData)), // FIXED
          _settingTile(context, "Update Password", Icons.lock_outline, StudentProfile(userData: userData)), // FIXED
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), 
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => LoginPage(onRoleChange: (role) {}))),
          ),
        ],
      ),
    );
  }
  Widget _settingTile(BuildContext context, String t, IconData i, Widget target) => Card(child: ListTile(leading: Icon(i, color: Colors.indigo), title: Text(t), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => target))));
}

// --- MODULE 8: NOTICES ---
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices"), backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          NoticeCard("Holiday Declaration", "Hostel closed from March 14th-20th.", "2026-03-05"),
          NoticeCard("Wifi Maintenance", "Connectivity issues on Friday 2-4 PM.", "2026-03-08"),
        ],
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final String t, d, dt;
  const NoticeCard(this.t, this.d, this.dt, {super.key});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 15), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)), Text(dt, style: const TextStyle(fontSize: 12))]), const SizedBox(height: 10), Text(d)])));
}