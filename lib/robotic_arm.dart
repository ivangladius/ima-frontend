import 'package:flutter/material.dart';

class RoboticArmTab extends StatelessWidget {
  const RoboticArmTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: const Text('Button 1'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: const Text('Button 2'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: const Text('Button 3'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: const Text('Button 4'),
          ),
        ],
      ),
    );
  }
}