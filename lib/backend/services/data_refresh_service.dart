import 'package:flutter/foundation.dart';

class DataRefreshService extends ChangeNotifier {
  static final DataRefreshService _instance = DataRefreshService._internal();
  static DataRefreshService get instance => _instance;

  DataRefreshService._internal();

  /// Triggers a refresh event that listeners (pages) should respond to
  /// by reloading their data.
  void triggerRefresh() {
    debugPrint('DataRefreshService: Triggering global data refresh');
    notifyListeners();
  }
}
