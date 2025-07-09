import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isLocked = false;
  List<TimerSchedule> _schedules = [];
  
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isLocked => _isLocked;
  List<TimerSchedule> get schedules => _schedules;
  
  String get formattedTime {
    final int hours = _remainingSeconds ~/ 3600;
    final int minutes = (_remainingSeconds % 3600) ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TimerProvider() {
    _loadSchedules();
  }

  void startTimer(int seconds) {
    _remainingSeconds = seconds;
    _isRunning = true;
    _isLocked = true;
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        stopTimer();
        unlockDevice();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_remainingSeconds > 0) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          stopTimer();
          unlockDevice();
        }
      });
      notifyListeners();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isLocked = false;
    _remainingSeconds = 0;
    notifyListeners();
  }

  void unlockDevice() {
    _isLocked = false;
    notifyListeners();
  }

  void addSchedule(TimerSchedule schedule) {
    _schedules.add(schedule);
    _saveSchedules();
    notifyListeners();
  }

  void removeSchedule(int index) {
    if (index >= 0 && index < _schedules.length) {
      _schedules.removeAt(index);
      _saveSchedules();
      notifyListeners();
    }
  }

  Future<void> _loadSchedules() async {
    // Simplified - no persistence for now
    _schedules = [];
    notifyListeners();
  }

  Future<void> _saveSchedules() async {
    // Simplified - no persistence for now
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TimerSchedule {
  final String title;
  final int durationSeconds;
  final TimeOfDay time;
  final List<bool> days; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]

  TimerSchedule({
    required this.title,
    required this.durationSeconds,
    required this.time,
    required this.days,
  });

  String toJson() {
    return '{"title":"$title","durationSeconds":$durationSeconds,"time":"${time.hour}:${time.minute}","days":"${days.join(",")}"}';
  }

  factory TimerSchedule.fromJson(String json) {
    // Simple JSON parsing for demo
    final parts = json.split('"');
    final title = parts[3];
    final durationSeconds = int.parse(parts[5].replaceAll(',', ''));
    final timeParts = parts[7].split(':');
    final time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    final days = parts[9].split(',').map((d) => d == 'true').toList();
    
    return TimerSchedule(
      title: title,
      durationSeconds: durationSeconds,
      time: time,
      days: days,
    );
  }
} 