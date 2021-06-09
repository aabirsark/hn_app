import 'dart:collection';
import 'dart:async';

import 'package:hn_app/src/articles.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum StoriesType {
  topStories,
  newStories,
}

class HackerNewsBloc {
  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  HackerNewsBloc() {
    _getArticleAndUpdatethem(_topIds);

    _storiesTypeController.stream.listen((storiesType) {
      /// something we gonna do with [storiesType]
      if (storiesType == StoriesType.newStories) {
        print("new >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        _getArticleAndUpdatethem(_newsids);
      } else if (storiesType == StoriesType.topStories) {
        print("top >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        _getArticleAndUpdatethem(_topIds);
      }
    });
  }

  _getArticleAndUpdatethem(List<int> ids) {
    print(ids);
    _updateArticles(ids).then((value) {
      print("-------------------------------");
      print(value);
      print(_articles);
      _articlesSubject.add(UnmodifiableListView(_articles));
    });
  }

  var _articles = <Article>[];

  static List<int> _newsids = [27404018, 27399581, 27415537, 27387110];

  static List<int> _topIds = [
    27390512,
    27395635,
    27388587,
    27412691,
  ];

  final _storiesTypeController = StreamController<StoriesType>();

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  Future<Null> _updateArticles(List<int> articleIds) async {
    var futureArticles = articleIds.map((e) => _getArticle(e));
    print(futureArticles);
    var articles = await Future.wait(futureArticles);
    print("copiled");
    print(articles);
    _articles = articles;
  }

  Future<Article> _getArticle(int id) async {
    final String storyUrl =
        "https://hacker-news.firebaseio.com/v0/item/$id.json";
    final storyRes = await http.get(Uri.parse(storyUrl));
    if (storyRes.statusCode == 200) {
      return parseArticle(storyRes.body);
    }
  }
}
