import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:dio/dio.dart';
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
      // 1. Get current Student ID from local storage
      _storedUserId = await AuthLocalStorage.getUserId();

      if (_storedUserId != null) {
        debugPrint("Auth Success: Student ID $_storedUserId");
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

  /// Step 1: Hit /api/chat/setup to get the Conversation ID
  Future<void> _initializeChat() async {
    try {
      setState(() => _isLoading = true);
      
      final response = await apiService.client.setupConversation({
        "name": "Warden Chat",
        "type": "group", 
        "user_id": _storedUserId 
      });

      if (response.success && response.conversationId != null) {
        setState(() {
          _activeConversationId = response.conversationId;
          _isLoading = false;
        });
        _fetchMessageHistory(); 
        _startPolling(); 
      } else {
        throw Exception("Failed to get conversation ID");
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

  Future<void> _fetchMessageHistory() async {
    if (_activeConversationId == null) return;

    try {
      final history = await apiService.client.getChatHistory(_activeConversationId!);
      
      if (history != null) {
        setState(() {
          _messages.clear();
          for (var msg in history) {
            _messages.add({
              // Support both 'message' or 'content' keys from backend
              "text": msg.message ?? msg.content ?? "", 
              "isMe": msg.senderId.toString() == _storedUserId,
              "time": msg.createdAt != null 
                  ? DateFormat('hh:mm a').format(DateTime.parse(msg.createdAt)) 
                  : "--:--"
            });
          }
        });
        _scrollToBottom();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("No history found for this ID yet.");
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// Step 2: Hit /api/chat/send with the correct keys
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    
    // Safety check: initialize if ID is missing
    if (_activeConversationId == null) {
      await _initializeChat();
      if (_activeConversationId == null) return;
    }

    setState(() => _isSending = true);
    final String currentTime = DateFormat('hh:mm a').format(DateTime.now());

    try {
      // POST Body matches: { "conversation_id": X, "type": "text", "content": "..." }
      final response = await apiService.client.sendWardenMessage({
        "conversation_id": _activeConversationId,
        "type": "text",
        "content": text,
      });

      // Based on your JSON: { "success": true, ... }
      if (response['success'] == true) {
        setState(() {
          _messages.add({
            "text": text, 
            "isMe": true, 
            "time": currentTime 
          });
          _messageController.clear();
        });
        
        Timer(const Duration(milliseconds: 100), () => _scrollToBottom());
      }
    } catch (e) {
      debugPrint("Send Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not reach Warden. Try again."))
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: const Text("Support Chat", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF9575CD), // Lavender
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
              : _messages.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
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
          Icon(Icons.forum_outlined, size: 64, color: Colors.purple.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("No messages yet.\nSay hello to the Warden!", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFD1C4E9) : const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isMe ? 15 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 15),
              ),
            ),
            child: Text(message, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.black38)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Write a message...",
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSending 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : CircleAvatar(
                backgroundColor: const Color(0xFF9575CD),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              )
        ],
      ),
    );
  }
}