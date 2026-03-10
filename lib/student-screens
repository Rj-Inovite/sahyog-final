import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:my_app/student_profile.dart';
import 'login.dart';
// Updated to match your requirement
import 'student_profile.dart'; 

// --- DATA LAYER ---
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

  static String lastComplaintDate = "";
  
  static List<DateTime> declaredHolidays = [
    DateTime(2026, 3, 14), 
    DateTime(2026, 3, 30), 
    DateTime(2026, 4, 10), 
  ];
}

// --- DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const StudentDashboard({super.key, required this.userData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Custom Modern Palette
  final Color primaryDark = const Color(0xFF1A237E); // Indigo
  final Color accentCyan = const Color(0xFF00B8D4);
  final Color bgSoft = const Color(0xFFF8FAFC);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: const Text("Sahyog Student Portal",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NoticePage())),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StudentProfile(userData: widget.userData))),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSectionHeader("Overview"),
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildResidenceSection(),
              const SizedBox(height: 25),
              _buildSectionHeader("Campus Services"),
              _buildActionGrid(context),
              const SizedBox(height: 25),
              _buildWardenCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryDark,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) setState(() => _currentIndex = 0);
            if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendancePage()));
            if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
            if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(email: widget.userData['email'] ?? "")));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Attendance"),
            BottomNavigationBarItem(icon: Icon(Icons.alternate_email_rounded), label: "Inbox"),
            BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: primaryDark, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryDark, const Color(0xFF3949AB)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person_outline, color: primaryDark)),
        ),
        title: Text(widget.userData['name'] ?? "Student",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        subtitle: const Text("University Residence - Block A",
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildResidenceSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoSquare("Room No", widget.userData['room'] ?? "102", Icons.door_sliding, const Color.fromRGBO(233, 166, 65, 1)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildInfoSquare("Status", "In-Campus", Icons.location_on, const Color.fromRGBO(6, 153, 80, 1)),
        ),
      ],
    );
  }

  Widget _buildInfoSquare(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark)),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _actionCard(context, "Leave Request", Icons.time_to_leave_rounded, const Color(0xFF6366F1), const LeavePage()),
        _actionCard(context, "Support Desk", Icons.support_agent_rounded, const Color.fromRGBO(16, 75, 185, 1), const ServiceDeskPage()),
        _actionCard(context, "Meal Schedule", Icons.fastfood_rounded, const Color.fromRGBO(110, 28, 241, 1), const MessMenuPage()),
        _actionCard(context, "Fee Portal", Icons.account_balance_wallet_rounded, const Color.fromRGBO(16, 226, 233, 1), const PaymentsPage()),
        _actionCard(context, "Complaint", Icons.report_problem_rounded, const Color.fromARGB(255, 4, 55, 102), const RaiseComplaintPage()),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon, Color col, Widget page) {
    return Hero(
      tag: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: col.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: col.withOpacity(0.1), width: 1.5)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: col.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: col, size: 30),
                ),
                const SizedBox(height: 12),
                Text(label, style: TextStyle(color: primaryDark, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWardenCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade50)
      ),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFE8EAF6), child: Icon(Icons.person, color: Color(0xFF1A237E))),
        title: const Text("Warden: Mrs. Sunita Sharma",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: const Text("Emergency: 9876543210"),
        trailing: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: const Icon(Icons.phone, color: Colors.green, size: 20),
        ),
      ),
    );
  }
}

// --- 1. APPLY LEAVE ---
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

  void _submitApplication() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a reason.")));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Application Sent"),
        content: const Text("Your leave request has been submitted for approval."),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text("Close", style: TextStyle(color: primaryColor)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Leave Application"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(label: const Text("Single Day"), selected: isSingleDay, onSelected: (v) => setState(() => isSingleDay = true), selectedColor: primaryColor.withOpacity(0.2)),
                      ChoiceChip(label: const Text("Range"), selected: !isSingleDay, onSelected: (v) => setState(() => isSingleDay = false), selectedColor: primaryColor.withOpacity(0.2)),
                    ],
                  ),
                  const Divider(height: 30),
                  if (isSingleDay) 
                    CalendarDatePicker(initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027), onDateChanged: (d) => setState(() => selectedDate = d))
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                      onPressed: () async {
                        final r = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2027));
                        if (r != null) setState(() => selectedRange = r);
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text("Select Range"),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(hintText: "Reason for leave...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _submitApplication,
              child: const Text("SUBMIT REQUEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// --- 2. RAISE COMPLAINT ---
class RaiseComplaintPage extends StatefulWidget {
  const RaiseComplaintPage({super.key});
  @override
  State<RaiseComplaintPage> createState() => _RaiseComplaintPageState();
}

class _RaiseComplaintPageState extends State<RaiseComplaintPage> {
  String? _category;
  final TextEditingController _descController = TextEditingController();
  bool _mediaAttached = false;
  final Color primaryColor = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(title: const Text("Raise Complaint"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              hint: const Text("Select Issue Category"),
              items: ["Water", "Wifi", "Mess", "Electricity"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),
            TextField(controller: _descController, maxLines: 5, decoration: InputDecoration(hintText: "Description...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => _mediaAttached = true),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryColor, style: BorderStyle.none)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_mediaAttached ? Icons.check_circle : Icons.upload_file, color: _mediaAttached ? Colors.green : primaryColor, size: 40),
                  Text(_mediaAttached ? "Attached" : "Upload Proof"),
                ]),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 55)),
              onPressed: () => Navigator.pop(context),
              child: const Text("SEND TO WARDEN", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// --- 3. SERVICE DESK ---
class ServiceDeskPage extends StatelessWidget {
  const ServiceDeskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      appBar: AppBar(title: const Text("Support Desk"), backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _tile("Maintenance / Plumber", "9876543210"),
          _tile("IT / WiFi Admin", "9876543211"),
          _tile("Cleaning Staff", "9876543212"),
          _tile("Laundry Unit", "9876543213"),
        ],
      ),
    );
  }
  Widget _tile(String t, String n) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(Icons.headset_mic, color: Color(0xFF10B981)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(n, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
    ),
  );
}

// --- 4. MESS MENU ---
class MessMenuPage extends StatelessWidget {
  const MessMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> menuData = [
      {"day": "Mon", "b": "Poha", "l": "Dal Makhani", "d": "Mix Veg"},
      {"day": "Tue", "b": "Paratha", "l": "Kadi Pakoda", "d": "Paneer"},
      {"day": "Wed", "b": "Idli", "l": "Veg Biryani", "d": "Aloo Matar"},
      {"day": "Thu", "b": "Upma", "l": "Chole", "d": "Egg Curry"},
      {"day": "Fri", "b": "Dosa", "l": "Bhindi", "d": "Dal Tadka"},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(title: const Text("Mess Schedule"), backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: DataTable(
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
            columns: const [
              DataColumn(label: Text('Day')),
              DataColumn(label: Text('Breakfast')),
              DataColumn(label: Text('Lunch')),
              DataColumn(label: Text('Dinner')),
            ],
            rows: menuData.map((m) => DataRow(cells: [
              DataCell(Text(m['day']!, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(m['b']!)),
              DataCell(Text(m['l']!)),
              DataCell(Text(m['d']!)),
            ])).toList(),
          ),
        ),
      ),
    );
  }
}

// --- 5. PAYMENTS ---
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFEC4899);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(title: const Text("Fees & Payments"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _payTile("Hostel Fee", "5000", primaryColor),
            _payTile("Mess Fee", "2500", primaryColor),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pending Total:", style: TextStyle(fontSize: 16)),
                  Text("₹ 7,500", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {},
              child: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
  Widget _payTile(String title, String amt, Color col) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Amount: ₹$amt"),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text("UNPAID", style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    ),
  );
}

// --- 6. ATTENDANCE ---
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Color primaryDark = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Attendance Log"), backgroundColor: primaryDark, foregroundColor: Colors.white),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 180, width: 180,
                child: CircularProgressIndicator(value: 0.94, strokeWidth: 12, color: primaryDark, backgroundColor: Colors.indigo.shade50),
              ),
              Column(
                children: [
                  Text("94%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryDark)),
                  const Text("Monthly Score"),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: 30,
                itemBuilder: (ctx, i) {
                   bool present = i % 6 != 0;
                   return Container(
                     margin: const EdgeInsets.all(4),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                     child: Center(child: Text("${i+1}", style: TextStyle(color: present ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                   );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- 7. INBOX/CHAT ---
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final Color primaryColor = const Color(0xFF1A237E);

  void _sendMessage({String? text, bool isImage = false}) {
    if (text == null && _messageController.text.trim().isEmpty) return;
    setState(() {
      ChatData.messages.add({
        "text": text ?? _messageController.text,
        "isMe": true,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
        "status": "sent",
        "isImage": isImage,
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support Chat"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: ChatData.messages.length,
              itemBuilder: (context, index) {
                final msg = ChatData.messages[index];
                bool isMe = msg['isMe'] ?? false;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _messageController, decoration: InputDecoration(hintText: "Message...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)))),
          const SizedBox(width: 8),
          CircleAvatar(backgroundColor: primaryColor, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _sendMessage())),
        ],
      ),
    );
  }
}

// --- 8. SETTINGS ---
class SettingsPage extends StatelessWidget {
  final String email;
  const SettingsPage({super.key, required this.email});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings"), backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.notifications), title: Text("Push Notifications")),
          ListTile(leading: Icon(Icons.security), title: Text("Privacy Policy")),
          ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

// --- 9. NOTICE PAGE ---
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcements"), backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          Card(child: ListTile(title: Text("Mid-Term Holidays"), subtitle: Text("Holidays start from March 14th."))),
          Card(child: ListTile(title: Text("Mess Update"), subtitle: Text("Special Dinner on Sunday."))),
        ],
      ),
    );
  }
}