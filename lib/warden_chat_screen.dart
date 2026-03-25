// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';

// --- API & STORAGE ---
import 'package:my_app/data/models/network/api_service.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';
import 'package:my_app/data/models/network/student_chat_send_response.dart';

class WardenChatScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Expected: {'id': 123, 'name': 'Warden Name'}
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
  String? _myIdFromToken; 
  int? _activeConversationId;

  // --- SAHYOG PREMIUM THEME ---
  final Color primaryLavender = const Color.fromRGBO(207, 16, 134, 1);
  final Color bgLavender = const Color(0xFFF3F2F7);
  final Color bubbleMe = const Color(0xFFDCF8C6); 
  final Color bubbleThem = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================== CORE LOGIC ==================

  Future<void> _initializeChatSession() async {
    try {
      _myIdFromToken = await AuthLocalStorage.getUserId();

      // 1. Setup Conversation Room with API
      final response = await apiService.setupChat();
      
      if (response != null && response['success'] == true) {
        if (mounted) {
          setState(() {
            _activeConversationId = response['conversation_id'];
            _isLoading = false;
          });
          // Only start syncing if we actually got a valid ID (Fixes 404 error)
          if (_activeConversationId != null) {
            _refreshChat();
            _startRealtimePolling(); 
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Init Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startRealtimePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Logic safety: don't poll if ID is missing or currently sending
      if (_activeConversationId != null && _activeConversationId != 0 && !_isSending && mounted) {
        _refreshChat(isPolling: true);
      }
    });
  }

  Future<void> _refreshChat({bool isPolling = false}) async {
    if (_activeConversationId == null) return;
    try {
      final response = await apiService.getChatMessages(_activeConversationId!);
      
      // Check if response is successful before mapping
      if (response != null && response['success'] == true) {
        final List<dynamic> history = response['messages'] ?? [];
        
        if (mounted) {
          setState(() {
            _messages.clear();
            for (var msg in history) {
              _messages.add({
                "id": msg['id'],
                "text": msg['message'] ?? "",
                "isMe": msg['sender_id'].toString() == _myIdFromToken,
                "status": msg['status'] ?? "sent", 
                "time": msg['created_at'] != null 
                    ? DateFormat('hh:mm a').format(DateTime.parse(msg['created_at'])) 
                    : "--:--"
              });
            }
          });
          if (!isPolling) _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final rawId = widget.userData['id'];
    if (rawId == null) return;
    
    // Check if trying to message self (Fixes 400 Bad Request)
    if (rawId.toString() == _myIdFromToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot send a message to yourself.")),
      );
      return;
    }

    final int recipientId = int.parse(rawId.toString());

    setState(() => _isSending = true);
    String originalText = text; // Keep for fallback if needed
    _messageController.clear();

    try {
      final StudentChatSendResponse? response = await apiService.sendChatMessage(
        recipientId: recipientId,
        content: originalText,
      );
      
      if (response != null && response.success == true) {
        // ✅ Accessing nested conversationId correctly from your specific model
        if (_activeConversationId == null && response.chatDetails != null) {
          _activeConversationId = response.chatDetails!.conversationId;
          _startRealtimePolling();
        }
        
        await _refreshChat();
        HapticFeedback.lightImpact();
      } else {
        // Show actual server message if available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?.message ?? "Failed to send message")),
        );
      }
    } catch (e) {
      debugPrint("Send Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ================== UI HELPERS ==================

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLavender,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
            opacity: 0.04, 
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: primaryLavender))
                : _messages.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => FadeInUp(
                        from: 10,
                        duration: const Duration(milliseconds: 300),
                        child: _buildChatBubble(_messages[index]),
                      ),
                    ),
            ),
            _buildInputPanel(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryLavender,
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.security, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userData['name'] ?? "Warden Support", 
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text("Typically replies in minutes", style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: primaryLavender.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No messages here yet", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Start a conversation with your Warden regarding leaves or hostel issues.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? bubbleMe : bubbleThem,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['text'], 
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.3)
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg['time'], style: const TextStyle(fontSize: 10, color: Colors.black45)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg['status'] == 'seen' ? Icons.done_all : Icons.check,
                    size: 14, 
                    color: msg['status'] == 'seen' ? Colors.blue : Colors.black45,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  filled: true,
                  fillColor: bgLavender,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _isSending 
              ? SizedBox(width: 48, height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryLavender)))
              : ZoomIn(
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _handleSend,
                    child: CircleAvatar(
                      backgroundColor: primaryLavender,
                      radius: 24,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}