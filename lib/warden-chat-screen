import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

// Ensure these paths match your project structure
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';

class WardenChatScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const WardenChatScreen({super.key, required this.userData});

  @override
  State<WardenChatScreen> createState() => _WardenChatScreenState();
}

class _WardenChatScreenState extends State<WardenChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  Timer? _pollingTimer;
  bool _isSending = false;
  bool _isLoading = true;

  String? _storedUserId;
  int? _activeConversationId;

  // Lavender Theme Colors
  final Color primaryLavender = const Color(0xFF9575CD);
  final Color lightLavender = const Color(0xFFF3E5F5);
  final Color bubbleMe = const Color(0xFFD1C4E9);

  @override
  void initState() {
    super.initState();
    _loadAuthAndInitialize();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC SECTION ---

  Future<void> _loadAuthAndInitialize() async {
    try {
      _storedUserId = await AuthLocalStorage.getUserId();

      if (_storedUserId != null) {
        debugPrint("Auth Success: Warden ID $_storedUserId");
        _initializeChat();
      } else {
        _handleAuthFailure();
      }
    } catch (e) {
      debugPrint("Storage Error: $e");
      _handleAuthFailure();
    }
  }

  void _handleAuthFailure() {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session expired. Please log in again.")),
    );
  }

  /// Hits /api/chat/setup to get/create the Room ID
  Future<void> _initializeChat() async {
    try {
      setState(() => _isLoading = true);

      // Pass the student ID from the previous screen's userData
      final response = await apiService.setupChat(int.parse(widget.userData['id'].toString()));

      if (response.data['success'] == true) {
        setState(() {
          _activeConversationId = response.data['conversation_id'];
          _isLoading = false;
        });
        _fetchMessageHistory();
        _startPolling();
      } else {
        throw Exception("Failed to initialize conversation");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Chat Setup Error: $e");
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeConversationId != null) {
        _fetchMessageHistory();
      }
    });
  }

  /// Hits /api/chat/messages/{id} - The key for App-Web Sync
  Future<void> _fetchMessageHistory() async {
    if (_activeConversationId == null) return;

    try {
      final response = await apiService.getChatMessages(_activeConversationId!);
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> history = response.data['messages'];
        
        setState(() {
          _messages.clear();
          for (var msg in history) {
            _messages.add({
              "text": msg['message'] ?? "", 
              "isMe": msg['sender_id'].toString() == _storedUserId,
              "time": msg['created_at'] != null 
                  ? DateFormat('hh:mm a').format(DateTime.parse(msg['created_at'])) 
                  : "--:--"
            });
          }
        });
        _scrollToBottom();
      }
    } on DioException catch (e) {
      debugPrint("Polling Error: ${e.message}");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Hits /api/chat/send
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _activeConversationId == null) return;

    setState(() => _isSending = true);

    try {
      // Body matches your Postman: {"conversation_id": X, "message": "..."}
      final response = await apiService.sendMessage(_activeConversationId!, text);

      if (response.data['success'] == true) {
        _messageController.clear();
        _fetchMessageHistory(); // Refresh immediately for better UX
      }
    } catch (e) {
      debugPrint("Send Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message failed to send."))
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 2,
        title: Column(
          children: [
            Text(widget.userData['name'] ?? "Chat", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Online", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: primaryLavender,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: primaryLavender))
              : _messages.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _buildMessageBubble(msg["text"], msg["isMe"], msg["time"]);
                      },
                    ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: primaryLavender.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No messages here yet", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? bubbleMe : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isSending 
            ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: primaryLavender))
            : FloatingActionButton(
                mini: true,
                backgroundColor: primaryLavender,
                onPressed: _sendMessage,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              )
        ],
      ),
    );
  }
}