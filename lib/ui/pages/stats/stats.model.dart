import 'package:flutter/material.dart';
import 'package:sentimento_app/core/model.dart';

class StatsModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  // Mock data for now - will be connected to real data later
  double _averageMood = 0;
  double get averageMood => _averageMood;

  int _totalEntries = 0;
  int get totalEntries => _totalEntries;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  Map<int, int> _moodDistribution = {};
  Map<int, int> get moodDistribution => _moodDistribution;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadStats() async {
    isLoading = true;
    try {
      // TODO: Load real stats from Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      _averageMood = 3.5;
      _totalEntries = 42;
      _currentStreak = 7;
      _moodDistribution = {1: 5, 2: 8, 3: 15, 4: 10, 5: 4};

      notifyListeners();
    } finally {
      isLoading = false;
    }
  }
}
