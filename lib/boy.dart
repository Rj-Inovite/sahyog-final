import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login.dart';
// Ensure you have a boy_profile.dart or update this import to match your file name
import 'boy_profile.dart'; 

// --- DATA LAYER ---
class ChatData {
  static List<Map<String, dynamic>> messages = [
    {
      "text": "Hello Warden, is the library open late tonight?",
      "isMe": true,
      "time": "09:00 AM",
      "status": "read",
      "isImage": false
    },
    {
      "text": "Yes, it is open until 11:00 PM for exam week.",
      "isMe": false,
      "time": "09:15 AM",
      "status": "read",
      "isImage": false
    },
  ];

  static String lastComplaintDate = "";
  
  // Declared Holidays for the calendar
  static List<DateTime> declaredHolidays = [
    DateTime(2026, 3, 14), // Holi
    DateTime(2026, 3, 30), 
    DateTime(2026, 4, 10), 
  ];
}

// --- DASHBOARD ---
class BoyDashboard extends StatefulWidget {
  final Map<String, String> userData;
  const BoyDashboard({super.key, required this.userData});

  @override
  State<BoyDashboard> createState() => _BoyDashboardState();
}

class _BoyDashboardState extends State<BoyDashboard> {
  final Color bgBlue = const Color(0xFFF0F7FF); 
  final Color primaryBlue = const Color(0xFF1976D2); 
  final Color accentBlue = const Color(0xFF42A5F5);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sahyog Boy Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
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
                    builder: (context) => BoyProfile(userData: widget.userData))),
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
        selectedItemColor: primaryBlue,
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
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: bgBlue,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: primaryBlue,
            child: const Icon(Icons.person, color: Colors.white)),
        title: Text(widget.userData['name'] ?? "Student",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text("Sahyog Block B - Boys Wing",
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
              Text(widget.userData['room'] ?? "305",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
            ]),
            Icon(Icons.meeting_room, color: primaryBlue, size: 30),
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
        _actionCard(context, "Apply Leave", Icons.holiday_village, Colors.blue.shade800, const LeavePage()),
        _actionCard(context, "Service Desk", Icons.handyman, Colors.blue.shade600, const ServiceDeskPage()),
        _actionCard(context, "Mess Menu", Icons.restaurant, Colors.blue.shade400, const MessMenuPage()),
        _actionCard(context, "Payments", Icons.payments, Colors.blue.shade300, const PaymentsPage()),
        _actionCard(context, "Raise Complaint", Icons.emergency_share, accentBlue, const RaiseComplaintPage()),
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
      color: bgBlue,
      child: ListTile(
        title: const Text("Warden: Mr. Rajesh Kumar",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text("Contact: 9876543222",
            style: TextStyle(color: Colors.black87)),
        trailing: Icon(Icons.phone_in_talk, color: primaryBlue),
      ),
    );
  }
}

// --- 1. APPLY LEAVE (BOY THEME) ---
class LeavePage extends StatefulWidget {
  const LeavePage({super.key});
  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final Color primaryBlue = const Color(0xFF1976D2);
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
        : (selectedRange == null ? "No range selected" : "${DateFormat('dd MMM').format(selectedRange!.start)} to ${DateFormat('dd MMM yyyy').format(selectedRange!.end)}");

    if (!isSingleDay && selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a date range.")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text("Applied leave for $dateInfo.\nReason: $reason"),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text("OK", style: TextStyle(color: primaryBlue)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Apply Leave"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
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
                  activeColor: primaryBlue,
                  onChanged: (val) => setState(() => isSingleDay = val as bool),
                ),
                const Text("Single Day"),
                const SizedBox(width: 20),
                Radio(
                  value: false, 
                  groupValue: isSingleDay, 
                  activeColor: primaryBlue,
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
                  colorScheme: ColorScheme.light(primary: primaryBlue),
                ),
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2027),
                  onDateChanged: (date) => setState(() => selectedDate = date),
                ),
              ),
            ] else ...[
              const Text("Select Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryBlue),
                onPressed: () async {
                  final DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primaryBlue,
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
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("${DateFormat('dd/MM/yyyy').format(selectedRange!.start)}  —  ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}", 
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ],

            const SizedBox(height: 20),
            const Text("Reason for Leave", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter valid reason here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            
            const SizedBox(height: 15),
            const Text("Declared Holidays ", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ChatData.declaredHolidays.map((h) => Chip(
                label: Text(DateFormat('dd MMM').format(h), style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: Colors.green,
              )).toList(),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, minimumSize: const Size(double.infinity, 55)),
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
  final Color primaryBlue = const Color(0xFF1976D2);

  void _submitComplaint() {
    if (!_mediaAttached) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Proof/File upload is mandatory.")));
      return;
    }
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (ChatData.lastComplaintDate == today) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Limit Reached"),
          content: const Text("You can only raise one complaint per day."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK", style: TextStyle(color: primaryBlue)))],
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
        content: const Text("Complaint submitted successfully to Warden."),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text("OK", style: TextStyle(color: primaryBlue)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Raise Complaint"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Issue Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryBlue)),
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
                hintText: "Enter complaint details...",
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryBlue)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryBlue)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_mediaAttached ? Icons.check_circle : Icons.upload_file, color: _mediaAttached ? Colors.green : primaryBlue, size: 40),
                    Text(_mediaAttached ? "File Attached" : "Upload Image/Video"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, minimumSize: const Size(double.infinity, 55)),
              onPressed: _submitComplaint,
              child: const Text("SUBMIT COMPLAINT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    const Color primaryBlue = Color(0xFF1976D2);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Service Desk"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _tile("Electrician", "9876543001"),
          _tile("Plumber", "9876543002"),
          _tile("IT / WiFi Admin", "9876543003"),
          _tile("Housekeeping", "9876543004"),
          _tile("Security Desk", "9876543005"),
        ],
      ),
    );
  }
  Widget _tile(String t, String n) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: const Icon(Icons.phone, color: Color(0xFF1976D2)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(n, style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
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
      {"day": "Saturday", "b": "Sandwich", "l": "Pasta/Rice", "d": "Kofta Curry"},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Boy's Mess Menu"), backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
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
    const Color primaryBlue = Color(0xFF1976D2);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Payments"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _payTile("Hostel Rent", "5000"),
            _payTile("Mess Rent", "2500"),
            _payTile("Late Fee", "200"),
            const Spacer(),
            Text("Total Pending: Rs. 7700", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 16)),
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
      trailing: const Text("PENDING", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
  final Color primaryBlue = const Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Attendance"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Monthly Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
            ),
            SizedBox(
              height: 280,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: 30,
                itemBuilder: (context, i) {
                  bool present = i % 4 != 0;
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${i + 1}"),
                        Icon(Icons.circle, size: 8, color: present ? Colors.green : Colors.red),
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
                  height: 140, width: 140,
                  child: CircularProgressIndicator(value: 0.88, strokeWidth: 12, color: primaryBlue, backgroundColor: Colors.blue.shade100),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("88%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
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
  final Color primaryBlue = const Color(0xFF1976D2);

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
      appBar: AppBar(title: const Text("Chat with Warden"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
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
                          color: isMe ? primaryBlue : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isMe ? 15 : 0), bottomRight: Radius.circular(isMe ? 0 : 15),
                          ),
                        ),
                        child: msg['isImage'] == true
                            ? Column(children: [
                                const Icon(Icons.image, size: 100, color: Colors.white),
                                Text(msg['text'], style: const TextStyle(color: Colors.white))
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
          IconButton(icon: Icon(Icons.attach_file, color: primaryBlue), onPressed: () => _sendMessage(text: "File shared", isImage: true)),
          Expanded(child: TextField(controller: _messageController, decoration: InputDecoration(hintText: "Type a message...", filled: true, fillColor: Colors.blue.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)))),
          CircleAvatar(backgroundColor: primaryBlue, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _sendMessage())),
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
  final Color primaryBlue = const Color(0xFF1976D2);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Settings"), backgroundColor: primaryBlue, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ListTile(leading: Icon(Icons.notifications, color: primaryBlue), title: const Text("Notification Settings")),
          ListTile(leading: Icon(Icons.security, color: primaryBlue), title: const Text("Privacy & Security")),
          ListTile(leading: Icon(Icons.help, color: primaryBlue), title: const Text("Help Center")),
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
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Notice Board"), backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.warning, color: Colors.blue), title: Text("Maintenance Notice", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Water supply will be affected from 2 PM to 4 PM today."))),
          Card(child: ListTile(leading: Icon(Icons.sports_basketball, color: Colors.blue), title: Text("Basketball Tournament", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Finals today evening at the hostel court."))),
        ],
      ),
    );
  }
}