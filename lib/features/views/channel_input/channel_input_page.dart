import 'package:connectify/features/views/voice_call/voice_call_view.dart';
import 'package:flutter/material.dart';

class ChannelInput extends StatefulWidget {
  const ChannelInput({Key? key}) : super(key: key);

  @override
  _ChannelInputState createState() => _ChannelInputState();
}

class _ChannelInputState extends State<ChannelInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter Channel Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final channelName = _controller.text;
                  if (channelName.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CallPage(channelName: channelName),
                      ),
                    );
                  }
                },
                child: const Text('Join Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
