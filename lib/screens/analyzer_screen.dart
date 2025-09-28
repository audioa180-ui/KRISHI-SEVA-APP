import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../api.dart';
import '../widgets/ui.dart';

class AnalyzerScreen extends StatefulWidget {
  final Api api;
  final String lang;
  const AnalyzerScreen({super.key, required this.api, required this.lang});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  File? _image; // for mobile/desktop
  Uint8List? _webBytes; // for web
  String? _webFilename;
  Map<String, dynamic>? _resp;
  bool _loading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 72,
    );
    if (x == null) return;
    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      setState(() {
        _webBytes = bytes;
        _webFilename = x.name.isNotEmpty ? x.name : 'upload.jpg';
        _image = null;
        _resp = null;
      });
    } else {
      final bytes = await x.readAsBytes();
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/upload.jpg');
      await f.writeAsBytes(Uint8List.fromList(bytes));
      setState(() {
        _image = f;
        _webBytes = null;
        _webFilename = null;
        _resp = null;
      });
    }
  }

  Future<void> _analyze() async {
    if (!kIsWeb && _image == null) return;
    if (kIsWeb && _webBytes == null) return;
    setState(() {
      _loading = true;
      _resp = null;
    });
    try {
      final r = kIsWeb
          ? await widget.api
              .analyzeBytes(_webBytes!, _webFilename ?? 'upload.jpg', widget.lang)
          : await widget.api.analyze(_image!, widget.lang);
      setState(() => _resp = r);
    } catch (e) {
      setState(() => _resp = {'result': 'Error: $e'});
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _resp?['parsed'] as Map<String, dynamic>?;
    final result = _resp?['result'] as String?;
    final resultTr = _resp?['result_translated'] as String?;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          // Hero header similar to website
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x1AFF9933), Color(0x10138808), Colors.transparent],
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF138808)]),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.agriculture, size: 16, color: Color(0xFF0B1F0F)),
                  SizedBox(width: 8),
                  Text('Smart Farming Assistant', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0B1F0F))),
                ]),
              ),
              const SizedBox(height: 10),
              const Text(
                'Detect plant diseases instantly',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFFE9F5EC)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload a photo of your crop. KRISHI SEVA analyzes it using AI and suggests causes and remedies.',
                style: TextStyle(fontSize: 14, color: Color(0xFFD6E9DA)),
              ),
              const SizedBox(height: 12),
              // Farmer quote box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('“', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, color: Color(0x26FFFFFF), height: 0.6)),
                  SizedBox(height: 6),
                  Text(
                    'The soil is our mother and the crop is our hope. With the right knowledge at the right time, we protect our fields and feed our families.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text('— Voice of an Indian Farmer', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD5F0D9))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AnimatedButton(
                onPressed: _pick,
                child: const Row(children: [
                  Icon(Icons.photo, color: Color(0xFF0B1F0F)),
                  SizedBox(width: 8),
                  Text('Select Image', style: TextStyle(color: Color(0xFF0B1F0F))),
                ]),
              ),
              const SizedBox(width: 8),
              AnimatedButton(
                onPressed: _loading ? null : _analyze,
                child: const Text('Analyze', style: TextStyle(color: Color(0xFF0B1F0F))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!kIsWeb && _image != null)
            FloatCard(child: Image.file(_image!, height: 220, fit: BoxFit.cover)),
          if (kIsWeb && _webBytes != null)
            FloatCard(child: Image.memory(_webBytes!, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: 12),
          if (_loading)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  ShimmerBox(height: 18),
                  SizedBox(height: 8),
                  ShimmerBox(height: 18),
                  SizedBox(height: 8),
                  ShimmerBox(height: 18),
                ]),
              ),
            ),
          if (_resp != null) _buildResult(parsed, result, resultTr),
        ],
      ),
    );
  }

  Widget _buildResult(
    Map<String, dynamic>? parsed,
    String? result,
    String? resultTr,
  ) {
    if (parsed != null) {
      final disease = parsed['disease'] ?? 'N/A';
      final cause = parsed['cause'] ?? 'N/A';
      final remedies = (parsed['remedies'] as List?)?.cast<String>() ?? const [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PillLabel('Analysis Result'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Disease: $disease', style: const TextStyle(color: Colors.white)),
                Text('Cause: $cause', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Remedies:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ...remedies.map((e) => Text('• $e', style: const TextStyle(color: Colors.white))),
              ]),
            ),
          ),
        ],
      );
    }
    final summary = (resultTr != null && resultTr.trim().isNotEmpty)
        ? resultTr
        : (result ?? 'No result');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PillLabel('Analysis Result'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(summary, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
