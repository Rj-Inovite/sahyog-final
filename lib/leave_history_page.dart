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
  
  // Custom Color Palette
  final Color primaryColor = const Color.fromRGBO(190, 10, 109, 1); // Indigo
  final Color pendingColor = Colors.orangeAccent;
  final Color approvedColor = const Color(0xFF10B981); // Emerald Green
  final Color rejectedColor = const Color(0xFFEF4444); // Rose Red
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
    if (widget.userId != null) {
      _userId = widget.userId!;
    } else {
      final idStr = await AuthLocalStorage.getUserId();
      _userId = int.tryParse(idStr ?? '') ?? 0;
    }
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
          _error = "Failed to load history.";
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitLeave() async {
    if (_rangeStart == null || _reasonController.text.trim().isEmpty) {
      _showCustomToast('Please fill all details!', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final String start = _rangeStart!.toUtc().toIso8601String();
      final String end = (_rangeEnd ?? _rangeStart!).toUtc().toIso8601String();

      await apiService.applyLeave(
        userId: _userId,
        leaveType: _selectedType,
        startDate: start,
        endDate: end,
        reason: _reasonController.text.trim(),
      );

      _showSuccessFeedback();
      _resetForm();
      await _fetchLeaves();
    } catch (e) {
      _showCustomToast('Submission Failed: ${e.toString()}', isError: true);
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

  void _showCustomToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(msg),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        height: 300,
        child: Column(
          children: [
            Icon(Icons.check_circle_rounded, color: approvedColor, size: 80),
            const SizedBox(height: 20),
            const Text("Leave Submitted!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your request is sent to the warden for approval.", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Got it!", style: TextStyle(color: Colors.white)),
            )
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
      backgroundColor: const Color(0xFFF8FAFC), // Off-white background
      appBar: AppBar(
        title: const Text('My Leaves', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetchLeaves, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildApplySheet(),
              _buildHeaderSection(),
              Expanded(child: _buildListSection()),
            ],
          ),
          if (_submitting) 
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
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
          const Text('Leave History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          GestureDetector(
            onTap: _toggleSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _sheetOpen ? rejectedColor : primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(_sheetOpen ? Icons.close : Icons.add, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(_sheetOpen ? 'Cancel' : 'Apply', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchLeaves,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: _leaves.length,
        itemBuilder: (ctx, i) => _buildLeaveCard(_leaves[i]),
      ),
    );
  }

  Widget _buildLeaveCard(dynamic item) {
    final String status = (item['status'] ?? 'pending').toString().toLowerCase();
    
    Color statusColor = pendingColor;
    String statusText = "PENDING";
    IconData statusIcon = Icons.access_time_rounded;

    if (status == 'approved') {
      statusColor = approvedColor;
      statusText = "APPROVED BY ADMIN";
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'rejected') {
      statusColor = rejectedColor;
      statusText = "REJECTED";
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['leave_type'] ?? 'Leave', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF334155))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Row(
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
                          Icon(Icons.date_range_rounded, size: 16, color: primaryColor.withOpacity(0.6)),
                          const SizedBox(width: 8),
                          Text("${_formatDisplayDate(item['start_date'])} to ${_formatDisplayDate(item['end_date'])}", 
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                        child: Text(item['reason'] ?? '', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF475569))),
                      ),
                      const SizedBox(height: 10),
                      Text("ID: #${item['id']}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 2)),
        ),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: InputDecoration(
                labelText: 'Why are you leaving?',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onRangeSelected: (start, end, focused) => setState(() { _rangeStart = start; _rangeEnd = end; }),
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  rangeEndDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  rangeHighlightColor: primaryColor.withOpacity(0.15),
                  todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryColor)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Detailed reason...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
                elevation: 5,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: const Text('SUBMIT APPLICATION', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
            )
          ],
        ),
      ),
    );
  }
}