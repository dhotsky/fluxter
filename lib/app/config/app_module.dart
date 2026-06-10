import 'package:fluxter/core/storage/local_storage.dart';

class AppModule {
  static Future<void> initService() async {
    // Boot LocalStorage asynchronously
    await LocalStorage.init();
  }
}
