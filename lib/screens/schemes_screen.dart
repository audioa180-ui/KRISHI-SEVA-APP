import 'package:flutter/material.dart';
import '../api.dart';
import '../widgets/ui.dart';

class SchemesScreen extends StatefulWidget {
  final Api api;
  final String lang;
  const SchemesScreen({super.key, required this.api, required this.lang});
  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  List<dynamic> schemes = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final r = await widget.api.schemes(widget.lang);
      if (!mounted) return;
      setState(() => schemes = (r['schemes'] as List?) ?? []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void didUpdateWidget(covariant SchemesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedButton(
                  onPressed: loading ? null : _load,
                  child: const Text('Refresh Schemes')),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: PillLabel('Latest Government Schemes'),
          ),
          const SizedBox(height: 8),
          if (loading)
            Column(
              children: const [
                ShimmerBox(height: 60),
                SizedBox(height: 10),
                ShimmerBox(height: 60),
                SizedBox(height: 10),
                ShimmerBox(height: 60),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: schemes.length,
              itemBuilder: (_, i) {
                final s = schemes[i] as Map<String, dynamic>;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 240),
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 8),
                      child: child,
                    ),
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(s['desc'] ?? '', style: const TextStyle(color: Colors.white)),
                          if (s['eligibility'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Eligibility: ${s['eligibility']}', style: const TextStyle(color: Colors.white)),
                            ),
                          if (s['how_to_apply'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text('How to apply: ${s['how_to_apply']}', style: const TextStyle(color: Colors.white)),
                            ),
                          if (s['link'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(s['link'], style: const TextStyle(color: Color(0xFF9CF6D0), fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
