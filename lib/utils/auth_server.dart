import 'dart:io';
import 'dart:isolate';
import 'package:http/http.dart' as http;

class AuthServer {
  final int port = 8080;
  late final HttpServer server;
  late final String redirectUri;
  late final String clientID;
  late final String clientSecret;
  Future<void> start(Map<String, dynamic> serverParams) async {
    final SendPort sendPort = serverParams['sendPort'];
    redirectUri = serverParams['env']['REDIRECT_URI'];
    clientID = serverParams['env']['CLIENT_ID'];
    clientSecret = serverParams['env']['CLIENT_SECRET'];
    server = await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
    sendPort.send("Listening on http://${server.address.host}:${server.port}");
    await for (HttpRequest request in server) {
      if (request.uri.hasQuery) {
        _handleRedirect(request);
      } else {
        _handleLogin(request);
      }
    }
  }

  Future<dynamic> _handleLogin(HttpRequest request) {
    final url = Uri(
        scheme: 'https',
        host: 'auth.aiesec.org',
        path: 'oauth/authorize',
        queryParameters: {
          'response_type': 'code',
          'client_id': clientID,
          'redirect_uri': redirectUri,
          'state': '',
        });
    return request.response.redirect(url);
  }

  Future<dynamic> _handleRedirect(HttpRequest request) async {
    final code = request.uri.queryParameters['code'];
    if (code == null) {
      return request.response.write("Authorization code missing");
    }
    try {
      final tokenData = await _getAccessToken(code);
      request.response.write(tokenData);
      await request.response.close();
    } catch (error) {
      request.response.statusCode = 500;
      request.response.write("Failed to authenticate : \n ${error.toString()}");
      await request.response.close();
    }
  }

  Future<String> _getAccessToken(String code) async {
    final url =
        Uri(scheme: 'https', host: 'auth.aiesec.org', path: 'oauth/token');
    final response = await http.post(url, body: {
      'grant_type': 'authorization_code',
      'code': code,
      'client_id': clientID,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
    });
    if (response.statusCode != 200) throw Exception(response.body);
    return response.body;
  }

  Future<void> close() async {
    await server.close(force: true);
  }
}
