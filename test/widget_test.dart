// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hn_app/src/articles.dart';

void main() {
  test("parsing artcile.dart", () {
    const String jsonStr = """
      {
"by": "tel",
"descendants": 16,
"id": 121003,
"kids": [
121016,
121109,
121168
],
"score": 25,
"text": "<i>or</i> HN: the Next Iteration<p>I get the impression that with Arc being released a lot of people who never had time for HN before are suddenly dropping in more often. (PG: what are the numbers on this? I'm envisioning a spike.)<p>Not to say that isn't great, but I'm wary of Diggification. Between links comparing programming to sex and a flurry of gratuitous, ostentatious  adjectives in the headlines it's a bit concerning.<p>80% of the stuff that makes the front page is still pretty awesome, but what's in place to keep the signal/noise ratio high? Does the HN model still work as the community scales? What's in store for (++ HN)?",
"time": 1203647620,
"title": "Ask HN: The Arc Effect",
"type": "story"
}
      """;
    expect(parseArticle(jsonStr).by, "tel");
  });
}
