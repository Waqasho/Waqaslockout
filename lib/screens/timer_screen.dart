import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/device_admin_provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 30;
  int _selectedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Timer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<TimerProvider, DeviceAdminProvider>(
        builder: (context, timerProvider, deviceAdminProvider, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.lightBlue],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Timer Display
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            timerProvider.isRunning ? Icons.timer : Icons.timer_off,
                            size: 64,
                            color: timerProvider.isRunning ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            timerProvider.isRunning ? 'Timer Running' : 'Set Timer',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            timerProvider.isRunning 
                                ? timerProvider.formattedTime
                                : '${_selectedHours.toString().padLeft(2, '0')}:${_selectedMinutes.toString().padLeft(2, '0')}:${_selectedSeconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Timer Controls
                  if (!timerProvider.isRunning) ...[
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Set Timer Duration',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePicker(
                                    'Hours',
                                    _selectedHours,
                                    0,
                                    23,
                                    (value) => setState(() => _selectedHours = value),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePicker(
                                    'Minutes',
                                    _selectedMinutes,
                                    0,
                                    59,
                                    (value) => setState(() => _selectedMinutes = value),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePicker(
                                    'Seconds',
                                    _selectedSeconds,
                                    0,
                                    59,
                                    (value) => setState(() => _selectedSeconds = value),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickButton('15 Min', 15 * 60),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildQuickButton('30 Min', 30 * 60),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildQuickButton('1 Hour', 60 * 60),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Action Buttons
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (timerProvider.isRunning) ...[
                          Expanded(
                            child: _buildActionButton(
                              'Pause',
                              Icons.pause,
                              Colors.orange,
                              () => timerProvider.pauseTimer(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'Resume',
                              Icons.play_arrow,
                              Colors.green,
                              () => timerProvider.resumeTimer(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'Stop',
                              Icons.stop,
                              Colors.red,
                              () {
                                timerProvider.stopTimer();
                                deviceAdminProvider.unlockScreen();
                              },
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: _buildActionButton(
                              'Start Timer',
                              Icons.play_arrow,
                              Colors.green,
                              () {
                                final totalSeconds = _selectedHours * 3600 + _selectedMinutes * 60 + _selectedSeconds;
                                if (totalSeconds > 0) {
                                  timerProvider.startTimer(totalSeconds);
                                  deviceAdminProvider.lockScreen();
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, int seconds) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedHours = seconds ~/ 3600;
          _selectedMinutes = (seconds % 3600) ~/ 60;
          _selectedSeconds = seconds % 60;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 