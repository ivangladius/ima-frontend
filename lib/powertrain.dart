import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class PowertrainTab extends StatefulWidget {
  const PowertrainTab({Key? key}) : super(key: key);

  @override
  _PowertrainTabState createState() => _PowertrainTabState();
}

class _PowertrainTabState extends State<PowertrainTab> {
  UserAccelerometerEvent? _userAccelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  WebSocketChannel? _channel;
  double joystickX = 0;
  double joystickY = 0;
  double speedScale = 50;
  double maxTranslationalSpeed = 1.0;
  bool motorsOn = false;
  String connectionStatus = 'Disconnected';
  String mode = 'robot'; // Default mode
  String wsUrl = 'ws://localhost:8765'; // WebSocket URL using localhost

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
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

  void _connectWebSocket() {
    setState(() {
      connectionStatus = 'Connecting...';
    });
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        (message) {
          // Handle incoming messages if needed
        },
        onDone: () {
          setState(() {
            connectionStatus = 'Disconnected';
          });
          // Attempt to reconnect after a delay
          Future.delayed(Duration(seconds: 5), _connectWebSocket);
        },
        onError: (error) {
          setState(() {
            connectionStatus = 'Error: $error';
          });
          // Attempt to reconnect after a delay
          Future.delayed(Duration(seconds: 5), _connectWebSocket);
        },
      );
      setState(() {
        connectionStatus = 'Connected';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Connection failed: $e';
      });
      // Attempt to reconnect after a delay
      Future.delayed(Duration(seconds: 5), _connectWebSocket);
    }
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _channel?.sink.close();
    super.dispose();
  }

  void sendData() {
    if (_channel != null && connectionStatus == 'Connected') {
      final scale = speedScale / 100;
      final translationalSpeed = maxTranslationalSpeed * scale * joystickY;
      final rotationalSpeed =
          (maxTranslationalSpeed * scale * -joystickX) / 180.0 * 3.14159;

      final data = {
        'mode': mode,
        'motorsOn': motorsOn,
        'translationalSpeed': translationalSpeed.toStringAsFixed(2),
        'rotationalSpeed': rotationalSpeed.toStringAsFixed(2),
      };

      _channel!.sink.add(jsonEncode(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('WebSocket Status: $connectionStatus'),
          Container(
            height: 200,
            width: 200,
            child: CustomJoystick(
              onJoystickUpdate: (x, y) {
                setState(() {
                  joystickX = x;
                  joystickY = -y; // Invert Y-axis
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Joystick X: ${joystickX.toStringAsFixed(2)}, Y: ${joystickY.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (_userAccelerometerEvent != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Accelerometer',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'X: ${_userAccelerometerEvent?.x.toStringAsFixed(1) ?? "0.0"}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                        Text(
                          'Y: ${_userAccelerometerEvent?.y.toStringAsFixed(1) ?? "0.0"}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                        Text(
                          'Z: ${_userAccelerometerEvent?.z.toStringAsFixed(1) ?? "0.0"}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (_gyroscopeEvent != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Gyroscope',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'X: ${_gyroscopeEvent!.x.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                        Text(
                          'Y: ${_gyroscopeEvent!.y.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                        Text(
                          'Z: ${_gyroscopeEvent!.z.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

class CustomJoystick extends StatefulWidget {
  final Function(double, double) onJoystickUpdate;

  const CustomJoystick({Key? key, required this.onJoystickUpdate})
      : super(key: key);

  @override
  _CustomJoystickState createState() => _CustomJoystickState();
}

class _CustomJoystickState extends State<CustomJoystick> {
  Offset _position = Offset.zero;
  double _radius = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: JoystickPainter(_position, _radius),
        child: Container(),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _radius = renderBox.size.width / 2;
    _updatePosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _position = Offset.zero;
    });
    widget.onJoystickUpdate(0, 0);
  }

  void _updatePosition(Offset newPosition) {
    Offset center = Offset(_radius, _radius);
    Offset relativePosition = newPosition - center;
    double distance = relativePosition.distance;

    if (distance > _radius) {
      relativePosition = relativePosition * (_radius / distance);
    }

    setState(() {
      _position = relativePosition;
    });

    widget.onJoystickUpdate(
      relativePosition.dx / _radius,
      relativePosition.dy / _radius,
    );
  }
}

class JoystickPainter extends CustomPainter {
  final Offset position;
  final double radius;

  JoystickPainter(this.position, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()..color = Colors.grey.withOpacity(0.5);
    Paint joystickPaint = Paint()..color = Colors.blue;

    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);
    canvas.drawCircle(Offset(radius, radius) + position, 20, joystickPaint);
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
