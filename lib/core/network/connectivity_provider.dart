import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزوّد حالة الاتصال بالشبكة.
final StreamProvider<List<ConnectivityResult>> connectivityProvider =
    StreamProvider<List<ConnectivityResult>>(
  (Ref ref) => Connectivity().onConnectivityChanged,
);

/// فحص متزامن للحالة الحالية.
final Provider<Connectivity> connectivityServiceProvider =
    Provider<Connectivity>((Ref ref) => Connectivity());
