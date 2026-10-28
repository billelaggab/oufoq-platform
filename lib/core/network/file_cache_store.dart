import 'dart:convert';
import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// مخزن كاش HTTP دائم على القرص.
///
/// يحفظ استجابات ووردبريس بين جلسات التطبيق حتى تعمل الأخبار المحفوظة
/// مؤقتاً دون اتصال بعد إعادة التشغيل (وليس فقط داخل الذاكرة).
class FileCacheStore extends CacheStore {
  FileCacheStore({this.folderName = 'oufoq_http_cache'});

  final String folderName;
  Future<Directory>? _directoryFuture;

  /// حد أعلى لعدد ملفات الكاش حتى لا ينمو القرص بلا سقف.
  static const int _maxFiles = 500;
  static const int _pruneEveryWrites = 40;
  int _writesSincePrune = 0;

  Future<Directory> _directory() {
    return _directoryFuture ??= _createDirectory();
  }

  Future<Directory> _createDirectory() async {
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory(p.join(base.path, folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// اسم ملف قصير وحتمي (FNV-1a 64-bit) لتفادي تجاوز حد طول أسماء الملفات.
  String _fileName(String key) {
    const int offset = 0xcbf29ce484222325;
    const int prime = 0x100000001b3;
    int hash = offset;
    for (final int unit in utf8.encode(key)) {
      hash ^= unit;
      hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
    }
    return '${hash.toRadixString(16)}_${key.length}.cache';
  }

  Future<File> _fileFor(String key) async {
    final Directory dir = await _directory();
    return File(p.join(dir.path, _fileName(key)));
  }

  @override
  Future<bool> exists(String key) async {
    return _fileFor(key).then((File file) => file.exists());
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final File file = await _fileFor(key);
    if (!await file.exists()) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        return null;
      }
      return _decode(Map<String, dynamic>.from(decoded));
    } on Object {
      // ملف تالف أو غير قابل للقراءة => تجاهله بهدوء.
      await delete(key);
      return null;
    }
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final List<CacheResponse> result = <CacheResponse>[];
    for (final CacheResponse response in await _all()) {
      if (pathExists(response.url, pathPattern, queryParams: queryParams)) {
        result.add(response);
      }
    }
    return result;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final File file = await _fileFor(response.key);
    await file.writeAsString(jsonEncode(_encode(response)), flush: true);
    if (++_writesSincePrune >= _pruneEveryWrites) {
      _writesSincePrune = 0;
      await _prune();
    }
  }

  /// يحذف أقدم الملفات عند تجاوز الحد الأعلى.
  Future<void> _prune() async {
    final Directory dir = await _directory();
    final List<(File, DateTime)> entries = <(File, DateTime)>[];
    try {
      await for (final FileSystemEntity entity in dir.list()) {
        if (entity is! File || !entity.path.endsWith('.cache')) {
          continue;
        }
        try {
          entries.add((entity, await entity.lastModified()));
        } on Object {
          // ملف حُذف أو تعذّر قراءته أثناء الفحص.
        }
      }
    } on Object {
      return;
    }
    if (entries.length <= _maxFiles) {
      return;
    }
    entries.sort((a, b) => a.$2.compareTo(b.$2));
    final int excess = entries.length - _maxFiles;
    for (int i = 0; i < excess; i++) {
      try {
        await entries[i].$1.delete();
      } on Object {
        // تجاهل فشل حذف ملف واحد.
      }
    }
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    if (staleOnly) {
      final CacheResponse? response = await get(key);
      if (response == null || !response.isStaled()) {
        return;
      }
    }
    final File file = await _fileFor(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    for (final CacheResponse response in await getFromPath(
      pathPattern,
      queryParams: queryParams,
    )) {
      await delete(response.key);
    }
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    for (final CacheResponse response in await _all()) {
      final bool matchesPriority =
          response.priority.index <= priorityOrBelow.index;
      final bool matchesStale = !staleOnly || response.isStaled();
      if (matchesPriority && matchesStale) {
        await delete(response.key);
      }
    }
  }

  @override
  Future<void> close() async {
    // لا موارد مفتوحة تُغلق في هذا المخزن.
  }

  Future<List<CacheResponse>> _all() async {
    final Directory dir = await _directory();
    if (!await dir.exists()) {
      return const <CacheResponse>[];
    }
    final List<CacheResponse> responses = <CacheResponse>[];
    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.cache')) {
        continue;
      }
      try {
        final dynamic decoded = jsonDecode(await entity.readAsString());
        if (decoded is Map) {
          responses.add(_decode(Map<String, dynamic>.from(decoded)));
        }
      } on Object {
        // تجاهل الملفات التالفة.
      }
    }
    return responses;
  }

  Map<String, dynamic> _encode(CacheResponse response) {
    return <String, dynamic>{
      'key': response.key,
      'url': response.url,
      'statusCode': response.statusCode,
      'content': response.content == null
          ? null
          : base64Encode(response.content!),
      'headers': response.headers == null
          ? null
          : base64Encode(response.headers!),
      'date': response.date?.millisecondsSinceEpoch,
      'eTag': response.eTag,
      'expires': response.expires?.millisecondsSinceEpoch,
      'lastModified': response.lastModified,
      'maxStale': response.maxStale?.millisecondsSinceEpoch,
      'priority': response.priority.index,
      'requestDate': response.requestDate.millisecondsSinceEpoch,
      'responseDate': response.responseDate.millisecondsSinceEpoch,
      'cacheControl': <String, dynamic>{
        'maxAge': response.cacheControl.maxAge,
        'privacy': response.cacheControl.privacy,
        'maxStale': response.cacheControl.maxStale,
        'minFresh': response.cacheControl.minFresh,
        'mustRevalidate': response.cacheControl.mustRevalidate,
        'noCache': response.cacheControl.noCache,
        'noStore': response.cacheControl.noStore,
        'other': response.cacheControl.other,
      },
    };
  }

  CacheResponse _decode(Map<String, dynamic> json) {
    final Map<String, dynamic> control =
        json['cacheControl'] is Map
            ? Map<String, dynamic>.from(json['cacheControl'] as Map)
            : <String, dynamic>{};
    final dynamic rawPriority = json['priority'];
    final int priorityIndex = rawPriority is int
        ? rawPriority.clamp(0, CachePriority.values.length - 1).toInt()
        : CachePriority.normal.index;

    return CacheResponse(
      key: json['key'] as String? ?? '',
      url: json['url'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 200,
      content: _decodeBytes(json['content']),
      headers: _decodeBytes(json['headers']),
      date: _decodeDate(json['date']),
      eTag: json['eTag'] as String?,
      expires: _decodeDate(json['expires']),
      lastModified: json['lastModified'] as String?,
      maxStale: _decodeDate(json['maxStale']),
      priority: CachePriority.values[priorityIndex],
      requestDate:
          _decodeDate(json['requestDate']) ?? DateTime.now(),
      responseDate:
          _decodeDate(json['responseDate']) ?? DateTime.now(),
      cacheControl: CacheControl(
        maxAge: control['maxAge'] as int? ?? -1,
        privacy: control['privacy'] as String?,
        maxStale: control['maxStale'] as int? ?? -1,
        minFresh: control['minFresh'] as int? ?? -1,
        mustRevalidate: control['mustRevalidate'] as bool? ?? false,
        noCache: control['noCache'] as bool? ?? false,
        noStore: control['noStore'] as bool? ?? false,
        other: (control['other'] as List<dynamic>?)
                ?.whereType<String>()
                .toList(growable: false) ??
            const <String>[],
      ),
    );
  }

  List<int>? _decodeBytes(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }

  DateTime? _decodeDate(dynamic value) {
    if (value is! int) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
}
