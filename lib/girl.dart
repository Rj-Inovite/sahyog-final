import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login.dart';
// Ensure this file exists in your project
import 'girl_profile.dart'; 

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
  
  // Declared Holidays for the calendar
  static List<DateTime> declaredHolidays = [
    DateTime(2026, 3, 14), // Example: Holi
    DateTime(2026, 3, 30), // Example: Break
    DateTime(2026, 4, 10), // Example: Good Friday
  ];
}

// --- DASHBOARD ---
class GirlDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const GirlDashboard({super.key, required this.userData});

  @override
  State<GirlDashboard> createState() => _GirlDashboardState();
}

class _GirlDashboardState extends State<GirlDashboard> {
  final Color bgPink = const Color(0xFFFFF1F2); 
  final Color primaryPink = const Color(0xFFD81B60); 
  final Color accentPink = const Color(0xFFF06292);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sahyog Girl Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NoticePage())),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GirlProfile(userData: widget.userData))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader("Welcome Back"),
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildSectionHeader("Current Residence"),
            _buildResidenceCard(),
            const SizedBox(height: 20),
            _buildSectionHeader("Quick Actions"),
            _buildActionGrid(context),
            const SizedBox(height: 20),
            _buildWardenCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryPink,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) setState(() => _currentIndex = 0);
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendancePage()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(email: widget.userData['email'] ?? "")));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryPink)),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: bgPink,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: primaryPink,
            child: const Icon(Icons.person, color: Colors.white)),
        title: Text(widget.userData['name'] ?? "Student",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text("Sahyog Block A - Girls Wing",
            style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _buildResidenceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Room No", style: TextStyle(color: Colors.grey)),
              Text(widget.userData['room'] ?? "102",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: primaryPink)),
            ]),
            Icon(Icons.door_front_door, color: primaryPink, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _actionCard(context, "Apply Leave", Icons.holiday_village, Colors.pink.shade700, const LeavePage()),
        _actionCard(context, "Service Desk", Icons.handyman, Colors.pink.shade500, const ServiceDeskPage()),
        _actionCard(context, "Mess Menu", Icons.restaurant, Colors.pink.shade400, const MessMenuPage()),
        _actionCard(context, "Payments", Icons.payments, Colors.pink.shade300, const PaymentsPage()),
        _actionCard(context, "Raise Complaint", Icons.emergency_share, accentPink, const RaiseComplaintPage()),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon, Color col, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 35),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWardenCard() {
    return Card(
      color: bgPink,
      child: ListTile(
        title: const Text("Warden: Mrs. Sunita Sharma",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text("Contact: 9876543210",
            style: TextStyle(color: Colors.black87)),
        trailing: Icon(Icons.phone_in_talk, color: primaryPink),
      ),
    );
  }
}

// --- 1. APPLY LEAVE (UPDATED FEATURE) ---
class LeavePage extends StatefulWidget {
  const LeavePage({super.key});
  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final Color primaryPink = const Color(0xFFD81B60);
  final TextEditingController _reasonController = TextEditingController();
  
  bool isSingleDay = true;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;

  void _submitApplication() {
    String reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a reason for leave.")),
      );
      return;
    }

    String dateInfo = isSingleDay 
        ? DateFormat('dd MMM yyyy').format(selectedDate)
        : "${DateFormat('dd MMM').format(selectedRange!.start)} to ${DateFormat('dd MMM yyyy').format(selectedRange!.end)}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text("Applied leave for $dateInfo.\nReason: $reason"),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text("OK", style: TextStyle(color: primaryPink)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Apply Leave"), backgroundColor: primaryPink, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Leave Type:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio(
                  value: true, 
                  groupValue: isSingleDay, 
                  activeColor: primaryPink,
                  onChanged: (val) => setState(() => isSingleDay = val as bool),
                ),
                const Text("Single Day"),
                const SizedBox(width: 20),
                Radio(
                  value: false, 
                  groupValue: isSingleDay, 
                  activeColor: primaryPink,
                  onChanged: (val) => setState(() => isSingleDay = val as bool),
                ),
                const Text("Multiple Days"),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            
            if (isSingleDay) ...[
              const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: primaryPink),
                ),
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2027),
                  onDateChanged: (date) => setState(() => selectedDate = date),
                  selectableDayPredicate: (day) {
                    // Logic for highlighting Holidays in logic (not natively colored in this widget)
                    return true; 
                  },
                ),
              ),
            ] else ...[
              const Text("Select Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryPink),
                onPressed: () async {
                  final DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primaryPink,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (range != null) setState(() => selectedRange = range);
                },
                icon: const Icon(Icons.date_range),
                label: Text(selectedRange == null ? "Pick From & To Dates" : "Range Selected"),
              ),
              if (selectedRange != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("From: ${DateFormat('dd/MM/yyyy').format(selectedRange!.start)} To: ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}", 
                  style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold)),
                ),
            ],

            const SizedBox(height: 20),
            const Text("Reason for Leave", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter reason...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            
            const SizedBox(height: 15),
            const Text("Declared Holidays ", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
            Wrap(
              children: ChatData.declaredHolidays.map((h) => Chip(
                label: Text(DateFormat('dd MMM').format(h), style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: Colors.green,
              )).toList(),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryPink, minimumSize: const Size(double.infinity, 55)),
              onPressed: _submitApplication,
              child: const Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  final Color primaryPink = const Color(0xFFD81B60);

  void _submitComplaint() {
    if (!_mediaAttached) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Proof/File upload is mandatory to send complaint.")));
      return;
    }
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (ChatData.lastComplaintDate == today) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Limit Reached"),
          content: const Text("Note: Per day you can only raise one complaint."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK", style: TextStyle(color: primaryPink)))],
        ),
      );
      return;
    }
    if (_category == null || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all details.")));
      return;
    }
    ChatData.lastComplaintDate = today;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Complaint Sent"),
        content: const Text("Complaint along with file proof sent to Warden successfully."),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text("OK", style: TextStyle(color: primaryPink)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(title: const Text("Raise Complaint"), backgroundColor: primaryPink, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Issue Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryPink)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Select Category"),
                  value: _category,
                  items: ["Water Issue", "Electricity", "Cleaning", "Mess Food", "WiFi/Internet", "Security", "Other"]
                      .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Detailed Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Describe your problem here...",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryPink.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryPink)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Attach Proof (Required)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => _mediaAttached = true),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryPink, style: BorderStyle.solid)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_mediaAttached ? Icons.check_circle : Icons.cloud_upload, color: _mediaAttached ? Colors.green : primaryPink, size: 40),
                    Text(_mediaAttached ? "File Attached Successfully" : "Click to Upload Image/Video"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _mediaAttached ? primaryPink : Colors.grey,
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _submitComplaint,
              child: const Text("SEND COMPLAINT TO WARDEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Girl's Service Desk"), backgroundColor: const Color(0xFFD81B60), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _tile("Electrician", "9876543210"),
          _tile("Room Service / Cleaning", "9876543211"),
          _tile("IT Support / WiFi", "9876543212"),
          _tile("Plumber", "9876543213"),
          _tile("Laundry Service", "9876543214"),
        ],
      ),
    );
  }
  Widget _tile(String t, String n) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: const Icon(Icons.call, color: Color(0xFFD81B60)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(n, style: const TextStyle(color: Color(0xFFD81B60), fontWeight: FontWeight.bold)),
    ),
  );
}

// --- 4. MESS MENU ---
class MessMenuPage extends StatelessWidget {
  const MessMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> menuData = [
      {"day": "Sunday", "b": "Aloo Puri", "l": "Rajma Chawal", "d": "Special Thali"},
      {"day": "Monday", "b": "Poha", "l": "Dal Makhani", "d": "Mix Veg"},
      {"day": "Tuesday", "b": "Paratha", "l": "Kadi Pakoda", "d": "Paneer Masala"},
      {"day": "Wednesday", "b": "Idli Sambhar", "l": "Veg Biryani", "d": "Aloo Matar"},
      {"day": "Thursday", "b": "Upma", "l": "Chole Bhature", "d": "Egg/Paneer Curry"},
      {"day": "Friday", "b": "Dosa", "l": "Bhindi Fry", "d": "Dal Tadka"},
      {"day": "Saturday", "b": "Sandwich", "l": "Pasta/Fried Rice", "d": "Kofta Curry"},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Girl's Mess Menu"), backgroundColor: const Color(0xFFD81B60), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.pink.shade50),
          columns: const [
            DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Breakfast', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Lunch', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dinner', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: menuData.map((m) => DataRow(cells: [
            DataCell(Text(m['day']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataCell(Text(m['b']!, style: const TextStyle(fontSize: 12))),
            DataCell(Text(m['l']!, style: const TextStyle(fontSize: 12))),
            DataCell(Text(m['d']!, style: const TextStyle(fontSize: 12))),
          ])).toList(),
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
    const Color primaryPink = Color(0xFFD81B60);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Payments"), backgroundColor: primaryPink, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _payTile("Hostel Rent", "5000"),
            _payTile("Mess Rent", "2500"),
            _payTile("Travelling Rent", "1500"),
            const Spacer(),
            Text("Total Pending: Rs. 9000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPink)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryPink, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text("PROCEED TO PAY", style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
  Widget _payTile(String title, String amt) => Card(
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Amount: Rs. $amt"),
      trailing: const Text("UNPAID", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
  final Color primaryPink = const Color(0xFFD81B60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Attendance"), backgroundColor: primaryPink, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Monthly Log", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPink)),
            ),
            SizedBox(
              height: 300,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: 28,
                itemBuilder: (context, i) {
                  bool present = i % 5 != 0;
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${i + 1}"),
                        Icon(Icons.circle, size: 8, color: present ? Colors.green : Colors.pink),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150, width: 150,
                  child: CircularProgressIndicator(value: 0.94, strokeWidth: 15, color: primaryPink, backgroundColor: Colors.pink.shade100),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("94%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryPink)),
                    const Text("Attendance", style: TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
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
  final Color primaryPink = const Color(0xFFD81B60);

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
      appBar: AppBar(title: const Text("Official Inbox"), backgroundColor: primaryPink, foregroundColor: Colors.white),
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
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? primaryPink : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isMe ? 15 : 0), bottomRight: Radius.circular(isMe ? 0 : 15),
                          ),
                        ),
                        child: msg['isImage'] == true
                            ? Column(children: [
                                const Icon(Icons.image, size: 100, color: Colors.white),
                                Text(msg['text'], style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
                              ])
                            : Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                      ),
                      Text(msg['time'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.add_a_photo, color: primaryPink), onPressed: () => _sendMessage(text: "Shared file", isImage: true)),
          Expanded(child: TextField(controller: _messageController, decoration: InputDecoration(hintText: "Type...", filled: true, fillColor: Colors.pink.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)))),
          CircleAvatar(backgroundColor: primaryPink, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _sendMessage())),
        ],
      ),
    );
  }
}

// --- 8. SETTINGS ---
class SettingsPage extends StatefulWidget {
  final String email;
  const SettingsPage({super.key, required this.email});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryPink = const Color(0xFFD81B60);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Settings"), backgroundColor: primaryPink, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ListTile(leading: Icon(Icons.notifications, color: primaryPink), title: const Text("Notifications")),
          ListTile(leading: Icon(Icons.lock_reset, color: primaryPink), title: const Text("Change Password")),
          ListTile(leading: Icon(Icons.help_center, color: primaryPink), title: const Text("Help & Support")),
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
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(title: const Text("Notice Board"), backgroundColor: const Color(0xFFD81B60), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.security, color: Colors.pink), title: Text("Hostel Entry Time", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Must enter by 8:30 PM."))),
          Card(child: ListTile(leading: Icon(Icons.celebration, color: Colors.pink), title: Text("Festival", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Celebration in common room at 5 PM."))),
        ],
      ),
    );
  }
}