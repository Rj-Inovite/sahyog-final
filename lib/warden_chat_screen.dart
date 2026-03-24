// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:my_app/data/models/network/api_service.dart';

// Internal imports
 // Ensure correct path
import 'package:my_app/data/models/network/auth_local_storage.dart';
import 'package:my_app/data/models/network/chat_response.dart';

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

  // ================== CORE LOGIC: TOKEN & SYNC ==================

  Future<void> _initializeChatSession() async {
    try {
      // 1. Get Profile via Token to identify 'Me'
      final profile = await apiService.getProfile();
      if (profile != null) {
        // Handle both Map and typed Profile if you've updated it
        _myIdFromToken = (profile is Map) 
            ? profile['data']['id'].toString() 
            : profile.id.toString();
      }

      // 2. Setup Conversation Room
      // Passing the student/user ID from the provided userData
      final response = await apiService.setupChat();
      
      if (response != null && response['success'] == true) {
        setState(() {
          _activeConversationId = response['conversation_id'];
          _isLoading = false;
        });
        _refreshChat();
        _startRealtimePolling(); 
      }
    } catch (e) {
      debugPrint("Init Error: $e");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _startRealtimePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeConversationId != null && !_isSending) {
        _refreshChat(isPolling: true);
      }
    });
  }

  Future<void> _refreshChat({bool isPolling = false}) async {
    if (_activeConversationId == null) return;
    try {
      final response = await apiService.getChatMessages(_activeConversationId!);
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
      debugPrint("Sync error: $e");
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Use recipient ID from the userData map passed to this screen
    final recipientId = widget.userData['id'];
    if (recipientId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      // ✅ Using the updated typed API call
      final ChatResponse? response = await apiService.sendMessage(recipientId, text);
      
      if (response != null && response.success == true) {
        await _refreshChat();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint("Send Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ================== ADVANCED ACTIONS (Delete/Edit) ==================

  void _showOptions(Map<String, dynamic> msg) {
    if (!msg['isMe']) return; 
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit Message"),
            onTap: () {
              Navigator.pop(context);
              _messageController.text = msg['text'];
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete for everyone"),
            onTap: () async {
              Navigator.pop(context);
              await apiService.deleteMessage(msg['id']);
              _refreshChat();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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

  // ================== UI COMPONENTS ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLavender,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
            opacity: 0.06, 
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: primaryLavender))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
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
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userData['name'] ?? "Student Chat", 
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
              ),
              const Text("Online", style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return GestureDetector(
      onLongPress: () => _showOptions(msg),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? bubbleMe : bubbleThem,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 12),
            ),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg['text'], 
                style: const TextStyle(fontSize: 15, color: Colors.black87)
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg['time'], style: const TextStyle(fontSize: 10, color: Colors.black45)),
                  const SizedBox(width: 4),
                  if (isMe) 
                    Icon(
                      msg['status'] == 'seen' ? Icons.done_all : Icons.check,
                      size: 14, 
                      color: msg['status'] == 'seen' ? Colors.blue : Colors.black45,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: primaryLavender), 
              onPressed: () {
                // Future: Implement Image/File Picker here
              }
            ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSending 
              ? SizedBox(width: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryLavender)))
              : GestureDetector(
                  onTap: _handleSend,
                  child: CircleAvatar(
                    backgroundColor: primaryLavender,
                    radius: 22,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}