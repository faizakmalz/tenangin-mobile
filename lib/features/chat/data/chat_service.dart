import 'dart:async';

import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tenangin_mobile/core/models.dart';
import 'package:tenangin_mobile/features/chat/data/consultation_service.dart';

/// ChatService with optional logging for debugging realtime behavior.
///
/// Usage:
///   final svc = ChatService(debug: true);
///   svc.getMessages(...);
class ChatService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// If true, logs will be printed via [logger].
  final bool debug;

  /// Logger function used for output. Defaults to [debugPrint].
  final void Function(String message) logger;

  ChatService({this.debug = false, void Function(String)? logger})
      : logger = logger ?? debugPrint;

  void _log(String msg) {
    if (debug) logger('[ChatService] $msg');
  }

  // Fetch messages in a specific thread (one-time query)
  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      _log('getMessages: threadId=$threadId - running query');
      final rows = await supabase
          .from('chat_messages')
          .select()
          .eq('thread_id', threadId)
          .order('created_at', ascending: true);

      _log('getMessages: raw rows=$rows');

      final list = (rows as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      _log('getMessages: mapped count=${list.length}');
      return list;
    } catch (e, st) {
      _log('getMessages: error: $e\n$st');
      throw 'Failed to fetch messages: $e';
    }
  }

  // Send a new message in a specific thread, returns the inserted row
  Future<Map<String, dynamic>> sendMessage(String threadId, String message) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _log('sendMessage: user is not logged in');
      throw "User is not logged in";
    }

    try {
      _log('sendMessage: inserting message for threadId=$threadId user=${user.id}');
      final inserted = await supabase
          .from('chat_messages')
          .insert({
            'thread_id': threadId,
            'sender_id': user.id,
            'sender_type': 'user',
            'message': message,
          })
          .select()
          .single();

      _log('sendMessage: inserted -> $inserted');
      return Map<String, dynamic>.from(inserted as Map);
    } catch (e, st) {
      _log('sendMessage: error: $e\n$st');
      throw 'Failed to send message: $e';
    }
  }

  // Get or create a thread for the current user
  Future<Map<String, dynamic>> getOrCreateThread() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _log('getOrCreateThread: user not logged in');
      throw "User is not logged in";
    }

    try {
      _log('getOrCreateThread: checking existing thread for user=${user.id}');
      final existing = await supabase
          .from('chat_threads')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      _log('getOrCreateThread: existing -> $existing');

      if (existing != null) {
        return Map<String, dynamic>.from(existing as Map);
      }

      _log('getOrCreateThread: creating new thread for user=${user.id}');
      final created = await supabase
          .from('chat_threads')
          .insert({'user_id': user.id, 'status': 'waiting'})
          .select()
          .single();
      if (created != null) {
          await ConsultationService().initSessionStart(created["id"]);
      }
      _log('getOrCreateThread: created -> $created');

      return Map<String, dynamic>.from(created as Map);
    } catch (e, st) {
      _log('getOrCreateThread: error: $e\n$st');
      throw 'Failed to get or create thread: $e';
    }
  }

  // Add this NEW method - always creates fresh thread
  Future<Map<String, dynamic>> createNewThread() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _log('createNewThread: user not logged in');
      throw "User is not logged in";
    }

    try {
      _log('createNewThread: creating new thread for user=${user.id}');
      
      final created = await supabase
          .from('chat_threads')
          .insert({'user_id': user.id, 'status': 'waiting'})
          .select()
          .single();
      
      if (created != null) {
        // Create consultation session
        await ConsultationService().initSessionStart(created["id"]);
      }
      
      _log('createNewThread: created -> $created');
      return Map<String, dynamic>.from(created as Map);
    } catch (e, st) {
      _log('createNewThread: error: $e\n$st');
      throw 'Failed to create thread: $e';
    }
  }

  // Real-time: stream messages for a thread using the .stream(...) API
  Stream<List<Map<String, dynamic>>> messagesStream(String threadId) {
    _log('messagesStream: subscribe for threadId=$threadId (stream primaryKey: [id])');

    final stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .map((list) {
      _log('messagesStream: raw event -> $list');

      final raw = (list ?? []) as List;
      final mapped = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // Sort by created_at defensively
      mapped.sort((a, b) {
        DateTime parse(dynamic v) {
          if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
          if (v is DateTime) return v;
          if (v is String) {
            try {
              return DateTime.parse(v);
            } catch (_) {
              return DateTime.fromMillisecondsSinceEpoch(0);
            }
          }
          return DateTime.fromMillisecondsSinceEpoch(0);
        }

        return parse(a['created_at']).compareTo(parse(b['created_at']));
      });

        // Fire-and-forget: update session to active
        ConsultationService().setSessionActive(threadId);
      _log('messagesStream: mapped count=${mapped.length}');
      return mapped;
    });

    return stream;
  }

  // Subscribe helper using the stream: returns a subscription that you can cancel
  // onMessage is called for newly-seen messages (deduplicated by id)
  StreamSubscription<List<Map<String, dynamic>>> subscribeToMessages(
    String threadId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    _log('subscribeToMessages: threadId=$threadId (dedup mode)');

    final seenIds = <dynamic>{};

    final sub = messagesStream(threadId).listen((messages) {
      _log('subscribeToMessages.listen: received list len=${messages.length}');
      for (final msg in messages) {
        final id = msg['id'];
        if (id == null) {
          _log('subscribeToMessages: message without id -> $msg');
          onMessage(msg);
          continue;
        }
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          _log('subscribeToMessages: new msg id=$id -> $msg');
          onMessage(msg);
        } else {
          _log('subscribeToMessages: duplicate msg id=$id ignored');
        }
      }
    }, onError: (err, st) {
      _log('subscribeToMessages: stream error: $err\n$st');
    }, onDone: () {
      _log('subscribeToMessages: stream done');
    });

    return sub;
  }

  // Unsubscribe (cancel the subscription)
  Future<void> unsubscribe(StreamSubscription subscription) async {
    _log('unsubscribe: cancelling subscription');
    await subscription.cancel();
  }

  RealtimeChannel createDebugChannel({
    required String table,
    String schema = 'public',
    PostgresChangeEvent event = PostgresChangeEvent.insert,
  }) {
    final channelName = 'debug_${table}_${DateTime.now().millisecondsSinceEpoch}';
    _log('createDebugChannel: channel=$channelName table=$table event=$event');

    final channel = supabase.channel(channelName);

    channel
        .onPostgresChanges(
          event: event,
          schema: schema,
          table: table,
          callback: (payload) {
            _log('createDebugChannel payload: $payload');
          },
        )
        .subscribe();

    _log('createDebugChannel: subscribed to channel $channelName');
    return channel;
  }

  Future<void> removeChannel(RealtimeChannel channel) async {
    _log('removeChannel: removing channel ${channel.topic}');
    await supabase.removeChannel(channel);
  }

   static Future<List<Thread>> getThreadsByUserId(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('chat_threads')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final threadsJson = response as List<dynamic>;
      return threadsJson
          .map((json) => Thread.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching threads: $e');
      return [];
    }
  }

  // Get messages for a specific thread
  static Future<List<Message>> getMessagesForThread(String threadId) async {
    try {
      final response = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .eq('thread_id', threadId)
          .order('created_at', ascending: true);

      final messagesJson = response as List<dynamic>;
      return messagesJson
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
}
