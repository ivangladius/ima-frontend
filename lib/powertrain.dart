import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class PowertrainTab extends StatefulWidget {
  const PowertrainTab({super.key});

  @override
  State<PowertrainTab> createState() => _PowertrainTabState();
}

class _PowertrainTabState extends State<PowertrainTab> {
  late WebSocketChannel channel;
  bool isRobotMode = true;
  bool motorsOn = false;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendJoystickData(double x, double y) {
    final data = {
      'mode': isRobotMode ? 'robot' : 'turtle',
      'motorsOn': motorsOn ? 1 : 0,
      'translationalSpeed': y,
      'rotationalSpeed': x,
    };
    channel.sink.add(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ... existing code ...
          Joystick(
            onStickDragEnd: () => _sendJoystickData(0, 0),
            listener: (details) {
              _sendJoystickData(details.x, -details.y);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... existing code ...
              Switch(
                value: isRobotMode,
                onChanged: (value) => setState(() => isRobotMode = value),
              ),
              Text(isRobotMode ? 'Robot Mode' : 'Turtle Mode'),
              const SizedBox(width: 20),
              Switch(
                value: motorsOn,
                onChanged: (value) => setState(() => motorsOn = value),
              ),
              const Text('Motors'),
            ],
          ),
        ],
      ),
    );
  }
}
