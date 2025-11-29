import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tenangin_mobile/core/models.dart';
import 'chat_screen.dart';
import '../data/chat_service.dart';
import 'package:intl/intl.dart'; 

class ChatHistoryScreen extends StatefulWidget {
  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Thread> _threads = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      final threads = await ChatService.getThreadsByUserId(userId);
      setState(() {
        _threads = threads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading threads: $e";
        _isLoading = false;
      });
      print("Error loading threads: $e");
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThreads,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadThreads,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _threads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chat history yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new conversation to see it here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadThreads,
                      child: ListView.separated(
                        itemCount: _threads.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final thread = _threads[index];
                          final isActive = thread.status == 'active';
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
                              child: Icon(
                                Icons.support_agent,
                                color: isActive ? Colors.green[700] : Colors.grey[600],
                              ),
                            ),
                            title: Row(
                              children: [
                                const Text('Admin Tenangin'),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              thread.lastMessage ?? 'No messages yet',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: thread.lastMessage != null ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTimestamp(thread.lastMessageTimestamp ?? thread.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (isActive)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(threadId: thread.id, isHistoryMode: true),
                                ),
                              );
                              _loadThreads();
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final chatService = ChatService();
            final thread = await chatService.getOrCreateThread();
            final threadId = thread['id'] as String;
            
            if (!mounted) return;
            
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(threadId: threadId),
              ),
            );
            _loadThreads();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error starting chat: $e')),
            );
          }
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('New Chat'),
      ),
    );
  }
}