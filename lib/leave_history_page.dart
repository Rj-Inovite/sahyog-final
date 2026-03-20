// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

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
  
  // Custom Color Palette - Matching your specific primary color
  final Color primaryColor = const Color.fromRGBO(190, 10, 109, 1); 
  final Color pendingColor = Colors.orangeAccent;
  final Color approvedColor = const Color(0xFF10B981); 
  final Color rejectedColor = const Color(0xFFEF4444); 
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
      duration: const Duration(milliseconds: 400)
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
    // Get the current logged-in user ID (Student)
    if (widget.userId != null) {
      _userId = widget.userId!;
    } else {
      final idStr = await AuthLocalStorage.getUserId();
      _userId = int.tryParse(idStr ?? '') ?? 0;
    }
    await _fetchLeaves();
  }

  /// ✅ FETCH: Links to the same database the Parent/Warden see
  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetches history specific to this student
      final List<dynamic> list = await apiService.getLeaves(_userId);
      if (mounted) {
        setState(() {
          _leaves = list.reversed.toList();
          if (_leaves.isEmpty) _error = "No leave records found.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load history. Pull down to retry.";
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// ✅ SUBMIT: Once this hits the API, the Parent & Warden Dashboards will 
  /// show this record automatically in their "Pending" sections.
  Future<void> _submitLeave() async {
    if (_rangeStart == null || _reasonController.text.trim().isEmpty) {
      _showCustomToast('Please select dates and provide a reason!', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final String start = _rangeStart!.toIso8601String().split('T')[0];
      final String end = (_rangeEnd ?? _rangeStart!).toIso8601String().split('T')[0];

      // API Integration with Sahyog Backend
      final response = await apiService.applyLeave(
        userId: _userId,
        leaveType: _selectedType,
        startDate: start,
        endDate: end,
        reason: _reasonController.text.trim(),
      );

      if (response != null) {
        _showSuccessFeedback();
        _resetForm();
        await _fetchLeaves(); // Refresh local list
      }
    } catch (e) {
      _showCustomToast('Submission Failed: Check connection', isError: true);
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
      _selectedType = 'Sick Leave';
    });
    _sheetController.reverse();
  }

  void _showCustomToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? rejectedColor : approvedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 30),
            Icon(Icons.check_circle_rounded, color: approvedColor, size: 80),
            const SizedBox(height: 20),
            const Text("Leave Submitted!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your request has been queued. It will now appear on your Parent and Warden's portals for approval.", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text('Leave Management', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchLeaves, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildApplySheet(), // The Animated Dropdown Form
              _buildHeaderSection(),
              Expanded(child: _buildListSection()),
            ],
          ),
          if (_submitting) 
            Container(
              color: Colors.black45, 
              child: const Center(child: CircularProgressIndicator(color: Colors.white))
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Past Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          GestureDetector(
            onTap: _toggleSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _sheetOpen ? rejectedColor : primaryColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(_sheetOpen ? Icons.close : Icons.add_circle_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(_sheetOpen ? 'Close Form' : 'New Leave', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection() {
    if (_loading) return Center(child: CircularProgressIndicator(color: primaryColor));
    
    if (_leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchLeaves,
        color: primaryColor,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Icon(Icons.description_outlined, size: 70, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Center(child: Text(_error ?? "No leave history found", style: const TextStyle(color: Colors.grey, fontSize: 15))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _leaves.length,
        itemBuilder: (ctx, i) => _buildLeaveCard(_leaves[i]),
      ),
    );
  }

  Widget _buildLeaveCard(dynamic item) {
    final String status = (item['status'] ?? 'pending').toString().toLowerCase();
    
    Color statusColor = pendingColor;
    String statusText = "WAITING";
    IconData statusIcon = Icons.hourglass_empty_rounded;

    if (status.contains('approve')) {
      statusColor = approvedColor;
      statusText = "APPROVED";
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (status.contains('reject')) {
      statusColor = rejectedColor;
      statusText = "REJECTED";
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['leave_type'] ?? 'Leave', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF334155))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 12),
                            const SizedBox(width: 4),
                            Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 14, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "${_formatDisplayDate(item['start_date'])} — ${_formatDisplayDate(item['end_date'])}", 
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 13)
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
                    child: Text(
                      item['reason'] ?? 'No reason provided.', 
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("Ref ID: #${item['id']}", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplySheet() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _sheetController, curve: Curves.fastOutSlowIn),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apply for Leave", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.category_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 7)),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: DateTime.now(),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontWeight: FontWeight.bold)),
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onRangeSelected: (start, end, focused) => setState(() { _rangeStart = start; _rangeEnd = end; }),
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  rangeEndDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  rangeHighlightColor: primaryColor.withOpacity(0.1),
                  todayDecoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: primaryColor)),
                  todayTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter specific reason for leave...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: const Text('SUBMIT APPLICATION', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1)),
            )
          ],
        ),
      ),
    );
  }
}