class Thread {
  final String id;
  final String userId;
  final String? sessionId; 
  final DateTime createdAt;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;

  Thread({
    required this.id,
    required this.userId,
    this.sessionId,  
    required this.createdAt,
    required this.status,
    this.lastMessage,  
    this.lastMessageTimestamp,  
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String?, 
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'waiting',  
      lastMessage: json['last_message'] as String?, 
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'] as String)
          : null, 
    );
  }
}

class Message {
  final String id;
  final String threadId;  // Add this - you'll need it
  final String senderId;
  final String senderType;  // Add this
  final String message;
  final DateTime createdAt;  // Use created_at, not timestamp

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderId: json['sender_id'] as String,
      senderType: json['sender_type'] as String? ?? 'user',
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),  // Not 'timestamp'
    );
  }
}