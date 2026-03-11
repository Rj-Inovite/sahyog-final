// File: leave_history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Update this import to your actual ApiService path
import 'package:my_app/data/models/network/api_service.dart';

class LeaveHistoryPage extends StatefulWidget {
  final int userId;
  const LeaveHistoryPage({super.key, required this.userId});

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage>
    with SingleTickerProviderStateMixin {
  // UI / theme
  final Color accent = const Color(0xFF6366F1);
  final Color success = const Color(0xFF10B981);
  final DateFormat _displayDate = DateFormat('dd MMM yyyy');

  // Data
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<dynamic> _leaves = [];

  // Apply form state
  String _selectedType = 'Sick Leave';
  final List<String> _leaveTypes = [
    'Sick Leave',
    'Vacation',
    'Emergency',
    'Personal',
    'Other'
  ];
  final TextEditingController _reasonController = TextEditingController();

  // Calendar selection
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Animation controller for the top apply sheet
  late AnimationController _sheetController;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _sheetController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fetchLeaves();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaves() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await apiService.getLeaves(widget.userId);
      if (resp.statusCode == 200) {
        final data = resp.data;
        List<dynamic> list;
        if (data is Map && data['data'] != null) {
          list = data['data'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }
        setState(() => _leaves = list.reversed.toList());
      } else {
        setState(() => _error = 'Server error: ${resp.statusMessage}');
      }
    } catch (e) {
      setState(() => _error = 'Failed to load leaves: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Toggle the apply sheet
  void _toggleSheet() {
    setState(() => _sheetOpen = !_sheetOpen);
    if (_sheetOpen) {
      _sheetController.forward();
    } else {
      _sheetController.reverse();
    }
  }

  // Submit leave to API
  Future<void> _submitLeave() async {
    if (_rangeStart == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select start and end dates')));
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please provide a reason')));
      return;
    }

    setState(() => _submitting = true);

    try {
      final start = _rangeStart!;
      final end = _rangeEnd ?? _rangeStart!;

      final startIso =
          DateTime(start.year, start.month, start.day).toUtc().toIso8601String();
      final endIso =
          DateTime(end.year, end.month, end.day).toUtc().toIso8601String();

      final response = await apiService.applyLeave(
        userId: widget.userId,
        leaveType: _selectedType,
        startDate: startIso,
        endDate: endIso,
        reason: _reasonController.text.trim(),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Application Submitted'),
            content:
                const Text('You have applied for leave waiting for approval'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        setState(() {
          _reasonController.clear();
          _rangeStart = null;
          _rangeEnd = null;
          _selectedType = _leaveTypes.first;
          _sheetOpen = false;
        });
        _sheetController.reverse();

        await _fetchLeaves();
      } else {
        final serverMsg = response.data != null && response.data['message'] != null
            ? response.data['message']
            : response.statusMessage ?? 'Failed to submit leave';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $serverMsg')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  // Calendar callbacks
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  Widget _buildApplySheet(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: _sheetController, curve: Curves.easeOut),
      axisAlignment: -1,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Apply for Leave',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accent))),
                IconButton(
                  onPressed: _toggleSheet,
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 8),

            // Leave type dropdown
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_selectedType),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    items: _leaveTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Calendar (TableCalendar)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _rangeStart ?? DateTime.now(),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onRangeSelected: (start, end, focusedDay) =>
                    _onRangeSelected(start, end, focusedDay),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
                calendarStyle: CalendarStyle(
                  withinRangeDecoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8)),
                  rangeStartDecoration: BoxDecoration(
                      color: accent, borderRadius: BorderRadius.circular(8)),
                  rangeEndDecoration: BoxDecoration(
                      color: accent, borderRadius: BorderRadius.circular(8)),
                  todayDecoration: BoxDecoration(
                      color: accent.withOpacity(0.2), shape: BoxShape.circle),
                  selectedDecoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Selected dates summary
            Row(
              children: [
                Icon(Icons.date_range, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _rangeStart == null
                        ? 'No dates selected'
                        : _rangeEnd == null
                            ? 'Start: ${_displayDate.format(_rangeStart!)}'
                            : 'From ${_displayDate.format(_rangeStart!)} to ${_displayDate.format(_rangeEnd!)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Reason field
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for leave...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 14),

            // Submit button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _submitting
                  ? SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)),
                        label: const Text('Submitting...'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    )
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitLeave,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text('Send Application',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTile(dynamic item) {
    final leaveType = item['leave_type'] ?? '—';
    final reason = item['reason'] ?? '';
    final status = (item['status'] ?? 'pending').toString();
    final id = item['id'] ?? 0;
    final start = item['start_date'];
    final end = item['end_date'];

    String formatDate(String? iso) {
      if (iso == null) return '—';
      try {
        final dt = DateTime.parse(iso).toLocal();
        return _displayDate.format(dt);
      } catch (_) {
        return iso;
      }
    }

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = success;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
            '$leaveType • ${formatDate(start)}${start != end ? ' - ${formatDate(end)}' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(reason, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 6),
            Text('#$id', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchLeaves,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.holiday_village, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Center(
                child: Text('No leave records yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            const Center(child: Text('Tap Apply to create your first leave request')),
            const SizedBox(height: 200),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _leaves.length,
        itemBuilder: (ctx, i) => _buildLeaveTile(_leaves[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Leave History'),
        backgroundColor: accent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchLeaves,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated apply sheet
          _buildApplySheet(context),

          // Header with Apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Your leave requests',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                  onPressed: _toggleSheet,
                  icon: const Icon(Icons.add),
                  label: Text(_sheetOpen ? 'Close' : 'Apply'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: _toggleSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
