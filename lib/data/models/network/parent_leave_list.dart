import 'package:flutter/material.dart';
//import 'package:my_app/data/api_service.dart';
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/leave_response.dart';

class ParentLeaveApprovalScreen extends StatefulWidget {
  const ParentLeaveApprovalScreen({super.key});

  @override
  State<ParentLeaveApprovalScreen> createState() => _ParentLeaveApprovalScreenState();
}

class _ParentLeaveApprovalScreenState extends State<ParentLeaveApprovalScreen> {
  bool _isLoading = false;
  List<dynamic> _leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      // Reusing your existing getLeaves method
      final leaves = await apiService.getLeaves();
      setState(() {
        // Filter to show only 'pending' leaves for this parent's view
        _leaves = leaves.where((l) => l['status'] == 'pending').toList();
      });
    } catch (e) {
      _showSnackBar("Failed to load leaves", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApproval(int studentId, int leaveId) async {
    try {
      final response = await apiService.parentApproveLeave(
        studentId: studentId, 
        leaveId: leaveId
      );

      if (response['success'] == true) {
        _showSnackBar("Approved! Waiting for Warden.", Colors.green);
        _fetchLeaves(); // Refresh list
      }
    } catch (e) {
      _showSnackBar("Approval failed", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Leave Requests")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _leaves.isEmpty 
            ? const Center(child: Text("No pending requests"))
            : ListView.builder(
                itemCount: _leaves.length,
                itemBuilder: (context, index) {
                  final leave = _leaves[index];
                  return _buildLeaveCard(leave);
                },
              ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${leave['leave_type']}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text("Duration: ${leave['start_date']} to ${leave['end_date']}"),
            Text("Reason: ${leave['reason']}"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => {}, // You can add rejection logic here later
                  child: const Text("Reject", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _handleApproval(leave['user_id'], leave['id']),
                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}