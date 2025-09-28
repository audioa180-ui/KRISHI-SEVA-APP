import 'package:flutter/material.dart';
import '../api.dart';
import '../widgets/ui.dart';

class ChatScreen extends StatefulWidget {
  final Api api;
  final String lang;
  const ChatScreen({super.key, required this.api, required this.lang});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final List<Map<String, String>> msgs = [];

  Future<void> _send() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      msgs.add({'role': 'user', 'text': text});
      ctrl.clear();
    });
    try {
      final r = await widget.api.chat(text, widget.lang);
      final reply = (r['reply'] ?? '').toString();
      setState(() {
        msgs.add({'role': 'bot', 'text': reply});
      });
    } catch (_) {
      setState(() {
        msgs.add({'role': 'bot', 'text': 'Chat failed.'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: msgs.length,
          itemBuilder: (_, i) {
            final m = msgs[i];
            final isUser = m['role'] == 'user';
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 220),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(isUser ? (1 - t) * 12 : (t - 1) * 12, 0),
                  child: child,
                ),
              ),
              child: Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF138808)])
                        : null,
                    color: isUser ? null : const Color(0xFF0F2A15),
                    border: isUser ? null : Border.all(color: const Color(0x14FFFFFF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m['text'] ?? '',
                    style: TextStyle(
                      fontWeight: isUser ? FontWeight.w800 : FontWeight.normal,
                      color: isUser ? const Color(0xFF0B1F0F) : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Ask about crops, pests, remedies...',
                hintStyle: TextStyle(color: Color(0xFFD6E9DA)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedButton(onPressed: _send, child: const Text('Send')),
        ]),
      ),
    ]);
  }
}
