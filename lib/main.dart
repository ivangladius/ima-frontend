import 'package:flutter/material.dart';
import 'powertrain.dart';
import 'robotic_arm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Joystick',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joystickey'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Powertrain'),
            Tab(text: 'Robotic Arm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PowertrainTab(),
          RoboticArmTab(),
        ],
      ),
    );
  }
}
