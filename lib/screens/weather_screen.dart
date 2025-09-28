import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api.dart';
import '../widgets/ui.dart';

class WeatherScreen extends StatefulWidget {
  final Api api;
  final String lang;
  const WeatherScreen({super.key, required this.api, required this.lang});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? data;
  bool loading = false;

  Future<void> _useLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    setState(() => loading = true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      final r = await widget.api.weather(
          pos.latitude, pos.longitude, widget.lang);
      setState(() => data = r);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = data?['current'] as Map<String, dynamic>?;
    final rain = data?['rain'] as Map<String, dynamic>?;
    final summary = data?['summary']?.toString();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          AnimatedButton(
            onPressed: loading ? null : _useLocation,
            child: const Row(children: [
              Icon(Icons.my_location),
              SizedBox(width: 8),
              Text('Use My Location'),
            ]),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: PillLabel('Weather Report'),
          ),
          const SizedBox(height: 8),
          if (loading)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 18),
                    SizedBox(height: 8),
                    ShimmerBox(height: 18),
                    SizedBox(height: 8),
                    ShimmerBox(height: 18),
                  ],
                ),
              ),
            ),
          if (current != null)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 240),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Current', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Temperature: ${current['temperature_2m'] ?? '-'} °C', style: const TextStyle(color: Colors.white)),
                    Text('Feels like: ${current['apparent_temperature'] ?? '-'} °C', style: const TextStyle(color: Colors.white)),
                    Text('Humidity: ${current['relative_humidity_2m'] ?? '-'} %', style: const TextStyle(color: Colors.white)),
                    Text('Wind: ${current['wind_speed_10m'] ?? '-'} km/h', style: const TextStyle(color: Colors.white)),
                    Text('Precipitation: ${current['precipitation'] ?? '-'} mm', style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          if (rain != null)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 240),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Rain probabilities', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Rain chance (now): ${rain['now_probability'] ?? '-'} %', style: const TextStyle(color: Colors.white)),
                    Text('Max (3h): ${rain['next_3h_max_probability'] ?? '-'} %', style: const TextStyle(color: Colors.white)),
                    Text('Max (12h): ${rain['next_12h_max_probability'] ?? '-'} %', style: const TextStyle(color: Colors.white)),
                    Text('Max (24h): ${rain['next_24h_max_probability'] ?? '-'} %', style: const TextStyle(color: Colors.white)),
                    Text('Total (24h): ${rain['next_24h_precip_sum_mm'] ?? '-'} mm', style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          if (summary != null && summary.isNotEmpty)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 240),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(summary, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
