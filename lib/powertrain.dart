import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert';

class PowertrainTab extends StatefulWidget {
  const PowertrainTab({Key? key}) : super(key: key);

  @override
  _PowertrainTabState createState() => _PowertrainTabState();
}

class _PowertrainTabState extends State<PowertrainTab> {
  UserAccelerometerEvent? _userAccelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.2.24:8765'));
  double joystickX = 0;
  double joystickY = 0;
  double speedScale = 50;
  double maxTranslationalSpeed = 1.0;
  bool motorsOn = false;

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEvents.listen((UserAccelerometerEvent event) {
        setState(() {
          _userAccelerometerEvent = event;
        });
      }),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          _gyroscopeEvent = event;
        });
      }),
    );
    Timer.periodic(const Duration(milliseconds: 100), (timer) => sendData());
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _channel.sink.close();
    super.dispose();
  }

  void sendData() {
    final scale = speedScale / 100;
    final translationalSpeed = maxTranslationalSpeed * scale * joystickY;
    final rotationalSpeed = (maxTranslationalSpeed * scale * -joystickX) / 180.0 * 3.14159;

    final data = {
      'translationalSpeed': translationalSpeed.toStringAsFixed(2),
      'rotationalSpeed': rotationalSpeed.toStringAsFixed(2),
      'motorsOn': motorsOn,
    };

    _channel.sink.add(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          if (_userAccelerometerEvent != null)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(
                    _userAccelerometerEvent!.x * 10,
                    -_userAccelerometerEvent!.y * 10,
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 48, 51, 227),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'X: ${_userAccelerometerEvent?.x.toStringAsFixed(1) ?? "0.0"}',
            style: const TextStyle(fontSize: 24, color: Colors.black),
          ),
          Text(
            'Y: ${_userAccelerometerEvent?.y.toStringAsFixed(1) ?? "0.0"}',
            style: const TextStyle(fontSize: 24, color: Colors.black),
          ),
          Text(
            'Z: ${_userAccelerometerEvent?.z.toStringAsFixed(1) ?? "0.0"}',
            style: const TextStyle(fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 20),
          if (_gyroscopeEvent != null)
            Column(
              children: [
                Text(
                  'Gyro X: ${_gyroscopeEvent!.x.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 24, color: Colors.black),
                ),
                Text(
                  'Gyro Y: ${_gyroscopeEvent!.y.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 24, color: Colors.black),
                ),
                Text(
                  'Gyro Z: ${_gyroscopeEvent!.z.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 24, color: Colors.black),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Slider(
            value: speedScale,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${speedScale.round()}%',
            onChanged: (value) {
              setState(() {
                speedScale = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                motorsOn = !motorsOn;
              });
            },
            child: Text(motorsOn ? 'Motors: ON' : 'Motors: OFF'),
          ),
        ],
      ),
    );
  }
}