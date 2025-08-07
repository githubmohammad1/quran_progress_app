import 'package:http/http.dart' as http;

Future<void> sendMultipartRequest({
  required String url,
  required String method, // 'GET', 'POST', 'PUT', 'DELETE'
  required String token,
  Map<String, String>? body,
}) async {
  final headers = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Authorization': 'Token $token',
  };

  final uri = Uri.parse(url);
  final request = http.MultipartRequest(method.toUpperCase(), uri);

  request.headers.addAll(headers);
  if (body != null) {
    request.fields.addAll(body);
  }

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode >= 200 && response.statusCode < 300) {
    print('✅ Response:\n$responseBody');
  } else {
    print('❌ Error: ${response.reasonPhrase}');
  }
}
