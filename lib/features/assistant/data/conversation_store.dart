import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/chat_thread.dart';

/// File-backed JSON store for conversation history.
///
/// Threads live in `<app documents>/askug/conversations.json` as a single
/// JSON array. Writes are debounced and atomic (write-to-temp then rename)
/// so a crash mid-write leaves the previous good copy in place.
///
/// Why a file rather than Hive/Isar: the dataset is small and append-
/// mostly, the models already have `toJson`/`fromJson`, and the file
/// can be inspected with `cat` on a developer's machine. If the store
/// grows by an order of magnitude or starts needing per-thread queries,
/// swap to Isar — the public API of this class stays the same.
class ConversationStore {
  ConversationStore({Duration debounce = const Duration(milliseconds: 350)})
      : _debounce = debounce;

  static const _fileName = 'conversations.json';
  static const _schemaVersion = 1;

  final Duration _debounce;
  Timer? _pendingWrite;
  List<ChatThread>? _pendingThreads;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/askug');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File('${folder.path}/$_fileName');
  }

  Future<List<ChatThread>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const [];
      final threads = (decoded['threads'] as List?) ?? const [];
      return threads
          .map((t) => ChatThread.fromJson(t as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      // A corrupt store should never crash the app. Returning empty
      // means the user sees a fresh slate; the bad file is still on
      // disk for forensics. Production would log this.
      return const [];
    }
  }

  /// Queue a save. Coalesces bursts of state changes into a single
  /// disk write so a chatty controller doesn't grind I/O.
  void enqueueSave(List<ChatThread> threads) {
    _pendingThreads = threads;
    _pendingWrite?.cancel();
    _pendingWrite = Timer(_debounce, () => unawaited(flush()));
  }

  /// Force an immediate write of the most-recently-enqueued snapshot.
  Future<void> flush() async {
    final threads = _pendingThreads;
    _pendingThreads = null;
    _pendingWrite?.cancel();
    _pendingWrite = null;
    if (threads == null) return;

    final file = await _file();
    final tmp = File('${file.path}.tmp');
    final payload = jsonEncode({
      'schema_version': _schemaVersion,
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'threads': threads.map((t) => t.toJson()).toList(),
    });
    await tmp.writeAsString(payload, flush: true);
    await tmp.rename(file.path);
  }

  Future<void> clear() async {
    _pendingWrite?.cancel();
    _pendingWrite = null;
    _pendingThreads = null;
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }
}

final conversationStoreProvider = Provider<ConversationStore>((ref) {
  final store = ConversationStore();
  ref.onDispose(() => unawaited(store.flush()));
  return store;
});
