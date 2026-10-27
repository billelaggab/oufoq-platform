import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/ad_config.dart';

/// جلب إعدادات الإعلانات عن بُعد بصمت، مع الرجوع للقيم الافتراضية الآمنة.
class AdConfigNotifier extends AsyncNotifier<AdConfig> {
  @override
  Future<AdConfig> build() async {
    try {
      final Dio dio = ref.read(dioProvider);
      final Response<dynamic> response =
          await dio.get<dynamic>(ApiEndpoints.oufoqConfig);
      if (response.data is Map) {
        return AdConfig.fromRemoteJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return AdConfig.safeDefaults;
    } on Object {
      // الإضافة غير مركبة بعد (404) أو لا يوجد اتصال => قيم افتراضية بهدوء.
      return AdConfig.safeDefaults;
    }
  }
}

final AsyncNotifierProvider<AdConfigNotifier, AdConfig> adConfigAsyncProvider =
    AsyncNotifierProvider<AdConfigNotifier, AdConfig>(AdConfigNotifier.new);

/// وصول متزامن ومريح لإعدادات الإعلانات عبر كل الطبقات.
final Provider<AdConfig> adConfigProvider = Provider<AdConfig>((Ref ref) {
  return ref.watch(adConfigAsyncProvider).value ?? AdConfig.safeDefaults;
});
