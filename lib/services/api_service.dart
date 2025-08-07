import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/progress.dart';

class ApiService {
  static const String baseUrl = 'http://10.44.157.191:8000/api/v1';

  Future<List<Progress>> fetchProgressList() async {
    final response = await http.get(Uri.parse('$baseUrl/progress/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Progress.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load progress');
    }
  }

  Future<Progress> createProgress(Progress prog) async {
    final response = await http.post(
      Uri.parse('$baseUrl/progress/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(prog.toJson()),
    );
    if (response.statusCode == 201) {
      return Progress.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create progress');
    }
  }
}
