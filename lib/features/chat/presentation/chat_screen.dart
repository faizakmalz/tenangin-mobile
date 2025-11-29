import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tenangin_mobile/features/chat/data/consultation_service.dart';
import 'package:tenangin_mobile/features/chat/presentation/after_chat.dart';
import '../data/chat_service.dart';
import '../widget/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String threadId;
  final bool isHistoryMode; 

  const ChatScreen({
    super.key, 
    required this.threadId,
    this.isHistoryMode = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  bool _hasText = false;

  late Timer _timer;
  int _remainingSeconds = 1200;
  double _progress = 1.0;
  bool _isEndingSession = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadMessagesAndSubscribe();

    if (!widget.isHistoryMode) {
      _startSessionTimer();

      final chatService = ChatService(debug: true);

      final debugChannel = chatService.createDebugChannel(
        table: 'chat_messages',
        event: PostgresChangeEvent.insert,
      );
    }
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  Future<void> _loadMessagesAndSubscribe() async {
    try {
      final initial = await _chatService.getMessages(widget.threadId);
      setState(() => messages = initial);
      _scrollToBottom(delay: const Duration(milliseconds: 100));
    } catch (e) {
    }

    _sub = _chatService.messagesStream(widget.threadId).listen((list) {
      setState(() => messages = list);
      _scrollToBottom();
    }, onError: (err) {
    });
  }

  void _scrollToBottom({Duration delay = const Duration(milliseconds: 150)}) {
    Future.delayed(delay, () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _endSessionAndPop() async {
    if (_isEndingSession) return;
    
    setState(() => _isEndingSession = true);
    
    try {
      await ConsultationService().endSession(widget.threadId);
    } catch (e) {
      debugPrint('Error ending session: $e');
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _manualEndSession() async {
    if (_isEndingSession) return;
    
    setState(() => _isEndingSession = true);
    
    try {
      await ConsultationService().endSession(widget.threadId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi konsultasi berakhir')),
        );
        
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => ThankYouScreen())
        );
      }
    } catch (e) {
      debugPrint('Error ending session: $e');
      setState(() => _isEndingSession = false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _sub?.cancel();
    
    if (!widget.isHistoryMode) {
      _timer.cancel();
    }
    
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatService.sendMessage(widget.threadId, text);
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  void _onMicPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mic action not implemented yet')),
    );
  }

  void _startSessionTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _progress = _remainingSeconds / 1200;
        });
      } else {
        _timer.cancel();
        _manualEndSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return PopScope( 
      canPop: widget.isHistoryMode,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && !widget.isHistoryMode) {
          await _endSessionAndPop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background-package.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    if (widget.isHistoryMode)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios, 
                          color: Color(0xFF9B7EBD),
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      TextButton.icon(
                        onPressed: _isEndingSession ? null : _manualEndSession,
                        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                        label: const Text(
                          'Akhiri Sesi',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    
                    const Spacer(),
                    
                    if (widget.isHistoryMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Riwayat',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B2E6A),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            Center(
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 122, 122, 122)
                          .withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/profile_logo.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person, 
                                      size: 40, 
                                      color: Color(0xFF7A58C2),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Admin Tenangin',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.isHistoryMode ? 'Riwayat Chat' : 'Online',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: widget.isHistoryMode 
                                          ? Colors.grey 
                                          : Colors.green,
                                    ),
                                  ),
                                  
                                  if (!widget.isHistoryMode) ...[
                                    Text(
                                      'Sesi berakhir dalam ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 12, 
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      width: 150,
                                      child: LinearProgressIndicator(
                                        value: _progress,
                                        minHeight: 5,
                                        color: Colors.yellow,
                                        backgroundColor: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: messages.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.isHistoryMode 
                                        ? 'Tidak ada pesan di chat ini' 
                                        : 'No messages yet',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(10),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = messages[index];
                                    final isMe = msg['sender_id'] == userId;
                                    final text = (msg['message'] ?? '').toString();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: isMe 
                                            ? MainAxisAlignment.end 
                                            : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width * 0.75,
                                            ),
                                            child: ChatBubble(
                                              message: text,
                                              isMe: isMe,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        
                        if (widget.isHistoryMode)
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12, 
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.lock_outline, 
                                    size: 16, 
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mode Riwayat (Read-only)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Type message...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(255, 100, 100, 100),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    minLines: 1,
                                    maxLines: 5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _hasText ? Icons.send_rounded : Icons.mic,
                                      color: Colors.white,
                                    ),
                                    onPressed: _hasText 
                                        ? _sendMessage 
                                        : _onMicPressed,
                                    tooltip: _hasText ? 'Send' : 'Record voice',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}