import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزوّد حالة الاتصال بالشبكة.
///
/// يبدأ بفحص فوري للحالة الحالية ثم يتابع التغييرات، حتى يظهر شريط
/// «غير متصل» عند الإقلاع البارد وليس فقط بعد أول تغيّر في الشبكة.
final StreamProvider<List<ConnectivityResult>> connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((Ref ref) async* {
  final Connectivity connectivity = Connectivity();
  try {
    yield await connectivity.checkConnectivity();
  } on Object {
    // لا نُسقط الواجهة إن فشل الفحص الأولي.
  }
  yield* connectivity.onConnectivityChanged;
});

/// فحص متزامن للحالة الحالية.
final Provider<Connectivity> connectivityServiceProvider =
    Provider<Connectivity>((Ref ref) => Connectivity());
