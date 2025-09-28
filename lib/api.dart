import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'config.dart';

class Api {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      // Render can cold-start; allow more time on first hit
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 500,
    ),
  );

  Future<Map<String, dynamic>> _mapResponse(Future<Response<dynamic>> future) async {
    try {
      final r = await future;
      if (r.statusCode == null) {
        throw Exception('No response from server. Please try again.');
      }
      if (r.statusCode! >= 200 && r.statusCode! < 300 && r.data is Map) {
        return (r.data as Map).cast<String, dynamic>();
      }
      // Non-2xx with JSON body
      if (r.data is Map) {
        final m = (r.data as Map).cast<String, dynamic>();
        final msg = m['message'] ?? m['error'] ?? 'Server error ${r.statusCode}';
        throw Exception(msg.toString());
      }
      throw Exception('Server error ${r.statusCode}. Please try again later.');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('The server took too long to respond. Please try again.');
      }
      if (e.type == DioExceptionType.badResponse && e.response?.data is Map) {
        final m = (e.response!.data as Map).cast<String, dynamic>();
        final msg = m['message'] ?? m['error'] ?? 'Request failed';
        throw Exception(msg.toString());
      }
      if (e.type == DioExceptionType.unknown && e.error is SocketException) {
        throw Exception('Network error. Check your internet connection.');
      }
      throw Exception('Unexpected error occurred. Please retry.');
    }
  }

  Future<Map<String, dynamic>> chat(String message, String lang) async {
    return _mapResponse(_dio.post('/chat', data: {'message': message, 'lang': lang}));
  }

  Future<Map<String, dynamic>> therapy(String message, String lang) async {
    return _mapResponse(_dio.post('/therapy', data: {'message': message, 'lang': lang}));
  }

  Future<Map<String, dynamic>> schemes(String lang) async {
    return _mapResponse(_dio.get('/schemes', queryParameters: {'lang': lang}));
  }

  Future<Map<String, dynamic>> weather(double lat, double lon, String lang) async {
    return _mapResponse(_dio.get('/weather', queryParameters: {
      'lat': lat,
      'lon': lon,
      'lang': lang,
    }));
  }

  Future<Map<String, dynamic>> analyze(File jpegFile, String lang) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        jpegFile.path,
        filename: 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    return _mapResponse(_dio.post('/analyze', queryParameters: {'lang': lang}, data: formData));
  }

  // Web-friendly: upload bytes without needing a File/temporary directory
  Future<Map<String, dynamic>> analyzeBytes(
    Uint8List bytes,
    String filename,
    String lang,
  ) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename.isNotEmpty ? filename : 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    return _mapResponse(_dio.post('/analyze', queryParameters: {'lang': lang}, data: formData));
  }

  Future<Map<String, dynamic>> translate(List<String> texts, String target) async {
    return _mapResponse(_dio.post('/translate', data: {'texts': texts, 'target': target}));
  }
}
