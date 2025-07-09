import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/timer_provider.dart';
import 'providers/device_admin_provider.dart';

void main() {
  runApp(const TimerLockApp());
}

class TimerLockApp extends StatelessWidget {
  const TimerLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => DeviceAdminProvider()),
      ],
      child: MaterialApp(
        title: 'Timer Lock App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
