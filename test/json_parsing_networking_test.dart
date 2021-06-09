import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hn_app/src/articles.dart';
import "package:http/http.dart" as http;

void main() {
  test("Networking json parsing test", () async {
    String url = "https://hacker-news.firebaseio.com/v0/beststories.json";
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final idList = jsonDecode(res.body);
      if (idList.isNotEmpty) {
        final String storyUrl =
            "https://hacker-news.firebaseio.com/v0/item/${idList.first}.json";
        final storyRes = await http.get(Uri.parse(storyUrl));
        if (res.statusCode == 200) {
          expect(parseArticle(storyRes.body), isNotNull);
        }
      }
    }
  });
}
