import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

// Ensure these imports match your actual folder structure
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';

class LeaveHistoryPage extends StatefulWidget {
  final int? userId;
  const LeaveHistoryPage({super.key, this.userId});

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage>
    with SingleTickerProviderStateMixin {
  
  // Theme & Constants
  final Color accent = const Color(0xFF6366F1);
  final Color success = const Color(0xFF10B981);
  final DateFormat _displayDate = DateFormat('dd MMM yyyy');

  // State
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<dynamic> _leaves = [];
  int _userId = 0;

  // Form State
  String _selectedType = 'Sick Leave';
  final List<String> _leaveTypes = ['Sick Leave', 'Vacation', 'Emergency', 'Personal', 'Other'];
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late AnimationController _sheetController;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300)
    );
    _initAndFetch();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _initAndFetch() async {
    // 1. Resolve User ID
    if (widget.userId != null) {
      _userId = widget.userId!;
    } else {
      final idStr = await AuthLocalStorage.getUserId();
      _userId = int.tryParse(idStr ?? '') ?? 0;
    }
    // 2. Fetch initial data
    await _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<dynamic> list = await apiService.getLeaves(_userId);
      
      setState(() {
        _leaves = list.reversed.toList();
        if (_leaves.isEmpty) _error = "No leave records found.";
      });
    } catch (e) {
      setState(() {
        if (e is DioException && e.response?.statusCode == 404) {
          _error = "No leave records found.";
        } else {
          _error = "Failed to load leaves. Please try again.";
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitLeave() async {
    if (_rangeStart == null || _reasonController.text.trim().isEmpty) {
      _showSnackBar('Please select dates and provide a reason');
      return;
    }

    setState(() => _submitting = true);

    try {
      // MATCHING POSTMAN: Use toUtc().toIso8601String() for the Laravel backend
      final String start = _rangeStart!.toUtc().toIso8601String();
      final String end = (_rangeEnd ?? _rangeStart!).toUtc().toIso8601String();

      await apiService.applyLeave(
        userId: _userId,
        leaveType: _selectedType,
        startDate: start,
        endDate: end,
        reason: _reasonController.text.trim(),
      );

      _showSuccessDialog();
      _resetForm();
      await _fetchLeaves();
    } catch (e) {
      _showSnackBar('Submission Failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetForm() {
    _reasonController.clear();
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
      _sheetOpen = false;
    });
    _sheetController.reverse();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Application Sent'),
        content: const Text('Your leave request has been submitted successfully.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  void _toggleSheet() {
    setState(() => _sheetOpen = !_sheetOpen);
    _sheetOpen ? _sheetController.forward() : _sheetController.reverse();
  }

  String _formatDisplayDate(String? iso) {
    if (iso == null) return "—";
    try {
      return _displayDate.format(DateTime.parse(iso).toLocal());
    } catch (e) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Leave History', style: TextStyle(color: Colors.white)),
        backgroundColor: accent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchLeaves, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildApplySheet(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Leave Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _toggleSheet,
                  icon: Icon(_sheetOpen ? Icons.close : Icons.add, size: 18),
                  label: Text(_sheetOpen ? 'Close' : 'Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildListSection()),
        ],
      ),
    );
  }

  Widget _buildListSection() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchLeaves,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Center(child: Text(_error!, style: const TextStyle(color: Colors.grey))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _leaves.length,
        itemBuilder: (ctx, i) => _buildLeaveCard(_leaves[i]),
      ),
    );
  }

  Widget _buildLeaveCard(dynamic item) {
    final String status = (item['status'] ?? 'pending').toString().toLowerCase();
    Color statusColor;
    
    if (status == 'approved') {
      statusColor = success;
    } else if (status == 'rejected') {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.orangeAccent;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['leave_type'] ?? 'Leave', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.toUpperCase(), 
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${_formatDisplayDate(item['start_date'])} - ${_formatDisplayDate(item['end_date'])}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item['reason'] ?? '', 
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const Divider(height: 20),
            Text("Request ID: #${item['id']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplySheet() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _sheetController, curve: Curves.easeInOut),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: InputDecoration(
                labelText: 'Leave Type',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _rangeStart ?? DateTime.now(),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onRangeSelected: (start, end, focused) => setState(() { _rangeStart = start; _rangeEnd = end; }),
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  rangeEndDecoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  rangeHighlightColor: accent.withOpacity(0.2),
                  todayDecoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason for leave...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}