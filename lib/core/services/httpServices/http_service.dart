import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class HttpService {

  Future<http.Response> get({
    required String url, 
    Map<String, dynamic> body,
    VoidCallback? onSuccess, 
    VoidCallback? onError});

  Future<http.Response> post({
    required String url,
    Map<String, dynamic> body, 
    VoidCallback? onSuccess, 
    VoidCallback? onError});

}



class HttpServiceImpl implements HttpService {
  final String? baseUrl;

  HttpServiceImpl({this.baseUrl});

  @override
  Future<http.Response> get({
    required String url, 
    Map<String, dynamic>? body,
    VoidCallback? onSuccess, 
    VoidCallback? onError}) 
    async {
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
    );

    // You can also handle status codes here
    if (response.statusCode == 200) {
      onSuccess?.call();
    } else {
      onError?.call();
    }

    return response;
  }

  @override
  Future<http.Response> post({
    required String url, 
    Map<String, dynamic>? body,
    VoidCallback? onSuccess, 
    VoidCallback? onError}) 
    async {
    final uri = Uri.parse('$baseUrl$url');

    final response = await http.post(
      uri,
      body: body
    );

    // You can also handle status codes here
    if (response.statusCode == 200) {
      onSuccess?.call();
    } else {
      onError?.call();
    }

    return response;
  }
}
