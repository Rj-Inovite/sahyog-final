import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_app/data/models/network/api_service.dart';

// ✅ Prefixing with 'model' prevents clash with AttendanceResponse inside api_service.dart
import 'package:my_app/data/models/network/attendance_response.dart' as model;

// --- DESIGN SYSTEM ---
const Color primaryIndigo = Color(0xFF3F51B5);
const Color accentIndigo = Color(0xFF5C6BC0);
const Color successGreen = Color(0xFF00B894);
const Color errorRed = Color(0xFFFF7675);
const Color backgroundWhite = Color(0xFFF8F9FD);

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isLoading = true;
  
  // ✅ Explicitly using the prefixed model type
  model.AttendanceResponse? _attendanceData;
  List<model.AttendanceData> _filteredList = [];
  
  String _searchQuery = "";
  String _selectedFilter = "All"; 
  DateTime _selectedDate = DateTime.now();
  
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
    
    // Auto-refresh every 10 seconds only if search is empty
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _searchQuery.isEmpty) {
        _fetchAttendance(isAutoRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendance({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) setState(() => _isLoading = true);
    try {
      // ✅ Passing the selected date to your fixed ApiService method
      final response = await apiService.getAttendance(date: _selectedDate); 
      
      if (mounted) {
        setState(() {
          _attendanceData = response;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Attendance Sync Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (_attendanceData == null) return;
    
    List<model.AttendanceData> temp = _attendanceData!.data;

    // 1. Filter by Status (Present/Absent)
    if (_selectedFilter != "All") {
      temp = temp.where((s) => s.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    // 2. Filter by Search (Name or Student Code)
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((s) => 
        s.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.studentCode.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    setState(() => _filteredList = temp);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryIndigo),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAttendance(); // Re-fetch data for the newly selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: RefreshIndicator(
        onRefresh: _fetchAttendance,
        color: primaryIndigo,
        edgeOffset: 110,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildSummaryCard()),
            SliverToBoxAdapter(child: _buildSearchAndFilterSection()),
            _isLoading && _attendanceData == null
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: primaryIndigo)),
                  )
                : _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 110.0,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryIndigo,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
          onPressed: () => _selectDate(context),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "Attendance: ${DateFormat('dd MMM yyyy').format(_selectedDate)}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final s = _attendanceData?.summary;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryIndigo.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn("Total", "${s?.totalRecords ?? 0}", Colors.black87),
          _statDivider(),
          _statColumn("Present", "${s?.present ?? 0}", successGreen),
          _statDivider(),
          _statColumn("Absent", "${s?.absent ?? 0}", errorRed),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String val, Color col) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 22)),
    ]);
  }

  Widget _statDivider() => Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              _searchQuery = val;
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: "Search name or student code...",
              prefixIcon: const Icon(Icons.search_rounded, color: primaryIndigo),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                        _applyFilters();
                      });
                    },
                  ) 
                : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Present", "Absent"].map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedFilter = filter);
                      _applyFilters();
                    },
                    selectedColor: primaryIndigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_filteredList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No matching records found", style: TextStyle(color: Colors.grey))),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      sliver: AnimationLimiter(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 450),
              child: SlideAnimation(
                verticalOffset: 40.0,
                child: FadeInAnimation(child: _studentTile(_filteredList[index])),
              ),
            ),
            childCount: _filteredList.length,
          ),
        ),
      ),
    );
  }

  Widget _studentTile(model.AttendanceData student) {
    bool isPresent = student.status.toLowerCase() == 'present';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: (isPresent ? successGreen : errorRed).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: isPresent ? successGreen : errorRed),
        ),
        title: Text(
          "${student.firstName} ${student.lastName}", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(student.studentCode, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPresent ? successGreen.withOpacity(0.12) : errorRed.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            student.status.toUpperCase(),
            style: TextStyle(
              color: isPresent ? successGreen : errorRed,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}