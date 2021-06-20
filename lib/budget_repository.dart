import 'dart:convert';
import 'dart:io';

import 'package:flutter_notion_budget_tracker/item_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'failure_model.dart';

class BudgetRepository {
  // POST: https://api.notion.com/v1/databases/e4f5519f1eaf4243bef275c242fd9cf4/query
  static const String _baseUrl = 'https://api.notion.com/v1/';

  final http.Client _client;

  BudgetRepository({
    http.Client? client,
  }) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Item>> getItems() async {
    try {
      final url = '${_baseUrl}databases/${dotenv.env['NOTION_DATA_ID']}/query';
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${dotenv.env['NOTION_API_KEY']}',
          'Notion-Version': '2021-05-13',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List).map((e) => Item.fromMap(e)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw Failure(message: 'Something went wrong1!');
      }
    } catch (e) {
      throw Failure(message: 'Something went wrong2!');
    }
  }
}
