import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParentPortal extends StatefulWidget {
  final Map<String, String> userData;
  const ParentPortal({super.key, required this.userData});

  @override
  State<ParentPortal> createState() => _ParentPortalState();
}

class _ParentPortalState extends State<ParentPortal> {
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color bgGreen = const Color(0xFFF1F8E9);

  // Simulation of Child Data Sync
  bool isViewingGirl = true; 
  String girlName = "Ananya Sharma";
  String boyName = "Aryan Sharma";
  
  // Simulated Leave Request from Child
  Map<String, dynamic>? pendingLeave = {
    "reason": "Diwali Festival Leave",
    "duration": "4 Days",
    "date": "Oct 28 - Nov 1",
    "status": "Pending"
  };

  @override
  Widget build(BuildContext context) {
    String currentChild = isViewingGirl ? girlName : boyName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Parental Monitoring", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_active), onPressed: () => _showLeaveNotification(context)),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${widget.userData['name'] ?? 'Parent'}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Monitoring your children's safety and well-being.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            _buildChildSelector(),
            const SizedBox(height: 25),
            
            _buildSectionHeader("Active Child: $currentChild"),
            _buildChildQuickOverview(),
            const SizedBox(height: 25),
            
            _buildSectionHeader("Parental Controls"),
            _buildActionGrid(context),
            const SizedBox(height: 25),
            
            if (pendingLeave != null) _buildPendingLeaveCard(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryGreen,
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => ChildAttendancePage(childName: currentChild)));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _childAvatar(girlName, "assets/girl_profile.png", isViewingGirl, () => setState(() => isViewingGirl = true)),
        _childAvatar(boyName, "assets/boy_profile.png", !isViewingGirl, () => setState(() => isViewingGirl = false)),
      ],
    );
  }

  Widget _childAvatar(String name, String img, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: selected ? primaryGreen : Colors.grey.shade300,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              // In a real app, use NetworkImage linked to Child's profile
              child: Icon(name.contains("Ananya") ? Icons.face_3 : Icons.face, size: 40, color: selected ? primaryGreen : Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? primaryGreen : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
    );
  }

  Widget _buildChildQuickOverview() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgGreen, borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryGreen.withOpacity(0.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat("Fee Dues", "₹4,500", Colors.red),
          _miniStat("Meal Today", "Taken", Colors.blue),
          _miniStat("Attendance", "94%", Colors.green),
        ],
      ),
    );
  }

  Widget _miniStat(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)),
    Text(l, style: const TextStyle(fontSize: 12, color: Colors.black54)),
  ]);

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _actionCard(context, "Leave History", Icons.time_to_leave, Colors.green.shade700, const ParentLeavePage()),
        _actionCard(context, "Mess Menu", Icons.restaurant_menu, Colors.green.shade600, const ParentMessPage()),
        _actionCard(context, "Fee Ledger", Icons.receipt_long, Colors.green.shade500, const FeeDetailsPage()),
        _actionCard(context, "Security Logs", Icons.admin_panel_settings, Colors.green.shade400, const SecurityLogsPage()),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String t, IconData i, Color c, Widget p) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => p)),
    child: Container(
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(15)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: Colors.white), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    ),
  );

  Widget _buildPendingLeaveCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orange)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [const Icon(Icons.warning, color: Colors.orange), const SizedBox(width: 10), Text("Leave Approval Required", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900))]),
            const SizedBox(height: 10),
            Text("${isViewingGirl ? girlName : boyName} has applied for: ${pendingLeave!['reason']}", style: const TextStyle(fontSize: 14)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _handleLeave(false), 
                  child: const Text("REJECT", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _handleLeave(true), 
                  child: const Text("APPROVE", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleLeave(bool approved) {
    setState(() => pendingLeave = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(approved ? "Leave Approved. Child notified." : "Leave Rejected. Child notified."),
      backgroundColor: approved ? Colors.green : Colors.red,
    ));
  }

  void _showLeaveNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Child Activity"),
        content: const Text("Ananya applied for 'Diwali Festival Leave' 10 minutes ago."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }
}

// --- 1. CHILD ATTENDANCE (Calendar + Filters) ---
class ChildAttendancePage extends StatefulWidget {
  final String childName;
  const ChildAttendancePage({super.key, required this.childName});
  @override
  State<ChildAttendancePage> createState() => _ChildAttendancePageState();
}

class _ChildAttendancePageState extends State<ChildAttendancePage> {
  String filter = "Month";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.childName}'s Attendance"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Filter: $filter View", style: const TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: filter,
                    items: ["Week", "Month", "Year"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => filter = v!),
                  )
                ],
              ),
            ),
            const Text("Attendance Summary: 94%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: filter == "Week" ? 7 : 30,
              itemBuilder: (ctx, i) => Card(color: i == 12 || i == 13 ? Colors.red.shade100 : Colors.green.shade100, child: Center(child: Text("${i + 1}"))),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. MESS MENU VIEW ---
class ParentMessPage extends StatelessWidget {
  const ParentMessPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child's Mess Plan"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Today's Diet Record", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _dietTile("Breakfast", "Poha & Tea", "Taken at 08:15 AM", true),
          _dietTile("Lunch", "Dal, Roti, Salad", "Taken at 01:30 PM", true),
          _dietTile("Dinner", "Paneer & Rice", "Pending", false),
        ],
      ),
    );
  }
  Widget _dietTile(String m, String f, String s, bool t) => Card(
    child: ListTile(
      leading: Icon(t ? Icons.check_circle : Icons.radio_button_unchecked, color: t ? Colors.green : Colors.grey),
      title: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(f),
      trailing: Text(s, style: const TextStyle(fontSize: 10)),
    ),
  );
}

// --- 3. FEE DETAILS ---
class FeeDetailsPage extends StatelessWidget {
  const FeeDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fee Payment Status"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Card(
              color: Color(0xFFC8E6C9),
              child: ListTile(title: Text("Paid Fees"), trailing: Text("₹85,000", style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            const Card(
              color: Color(0xFFFFCDD2),
              child: ListTile(title: Text("Pending Dues"), trailing: Text("₹4,500", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text("PAY PENDING DUES", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// --- 4. LEAVE HISTORY ---
class ParentLeavePage extends StatelessWidget {
  const ParentLeavePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave History"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          ListTile(title: Text("Medical Leave"), subtitle: Text("Reason: Fever | 2 Days"), trailing: Text("Approved", style: TextStyle(color: Colors.green))),
          Divider(),
          ListTile(title: Text("Weekend Home Trip"), subtitle: Text("Reason: Family Visit | 2 Days"), trailing: Text("Approved", style: TextStyle(color: Colors.green))),
        ],
      ),
    );
  }
}

// --- 5. SECURITY LOGS ---
class SecurityLogsPage extends StatelessWidget {
  const SecurityLogsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Security & Gate Logs"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (ctx, i) => ListTile(
          leading: const Icon(Icons.sensor_door, color: Colors.blue),
          title: Text("Gate Entry: Block ${i % 2 == 0 ? 'A' : 'B'}"),
          subtitle: Text("Time: 07:15 PM"),
          trailing: const Text("Safe", style: TextStyle(color: Colors.green)),
        ),
      ),
    );
  }
}

// --- 6. SETTINGS PAGE (Same as others) ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: ListView(
        children: [
          const ListTile(leading: Icon(Icons.notifications), title: Text("Push Notifications")),
          const ListTile(leading: Icon(Icons.lock), title: Text("Privacy Settings")),
          const ListTile(leading: Icon(Icons.help), title: Text("Support Center")),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout"), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}