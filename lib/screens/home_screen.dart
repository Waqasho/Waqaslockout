import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/device_admin_provider.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceAdminProvider>().checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Lock App'),
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
                  // Status Card
                  Container(
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
                      children: [
                        Icon(
                          timerProvider.isRunning ? Icons.timer : Icons.timer_off,
                          size: 48,
                          color: timerProvider.isRunning ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          timerProvider.isRunning ? 'Timer Running' : 'Timer Stopped',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timerProvider.formattedTime,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatusChip(
                              'Locked',
                              timerProvider.isLocked,
                              Colors.red,
                            ),
                            _buildStatusChip(
                              'Admin Access',
                              deviceAdminProvider.hasAdminPermission,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick Actions
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildActionCard(
                            'Start Timer',
                            Icons.play_arrow,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TimerScreen()),
                            ),
                          ),
                          _buildActionCard(
                            'Quick Start (30 min)',
                            Icons.timer,
                            Colors.orange,
                            () {
                              timerProvider.startTimer(30 * 60);
                              deviceAdminProvider.lockScreen();
                            },
                          ),
                          _buildActionCard(
                            'Stop Timer',
                            Icons.stop,
                            Colors.red,
                            () {
                              timerProvider.stopTimer();
                              deviceAdminProvider.unlockScreen();
                            },
                          ),
                          _buildActionCard(
                            timerProvider.isRunning ? 'Pause' : 'Resume',
                            timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
                            Colors.purple,
                            () {
                              if (timerProvider.isRunning) {
                                timerProvider.pauseTimer();
                              } else {
                                timerProvider.resumeTimer();
                              }
                            },
                          ),
                        ],
                      ),
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

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 