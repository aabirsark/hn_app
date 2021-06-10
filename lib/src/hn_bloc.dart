import 'dart:collection';
import 'dart:async';
import 'package:http/http.dart';
import 'package:hn_app/src/articles.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum StoriesType {
  topStories,
  newStories,
}

class HackerNewsBloc {
  // ? Constructor---------------------------
  HackerNewsBloc() {
    _initializeArticles();

    _storiesTypeController.stream.listen((storiesType) async {
      _getArticleAndUpdatethem(await _getIds(storiesType));
    });
  }
  // ? ------------------------------------------

  Future<void> _initializeArticles() async {
    _getArticleAndUpdatethem(await _getIds(StoriesType.topStories));
  }

  Future<List<int>> _getIds(StoriesType storiesType) async {
    String interpoletedStr =
        storiesType == StoriesType.newStories ? "newstories" : "topstories";
    String url = "https://hacker-news.firebaseio.com/v0/$interpoletedStr.json";
    var res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw HackerNewsApiException("$url can't be fetched");
    }
    return parseListStories(res.body).take(10).toList();
  }

  _getArticleAndUpdatethem(List<int> ids) {
    _isLoadingSubject.add(true);
    _updateArticles(ids).then((value) {
      _articlesSubject.add(UnmodifiableListView(_articles));
      _isLoadingSubject.add(false);
    });
  }

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
    throw HackerNewsApiException("$storyUrl can't be fecthed..");
  }

  void close() {
    _storiesTypeController.close();
  }

  // ? ??????? !!!!!!!!!!!!!!!!!!!!!! ---------------

  static List<int> _newsids = [27404018, 27399581, 27415537, 27387110];

  static List<int> _topIds = [
    27390512,
    27395635,
    27388587,
    27412691,
  ];

  var _articles = <Article>[];
  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  Stream<bool> get isLoading => _isLoadingSubject.stream;
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  final _storiesTypeController = StreamController<StoriesType>();

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;
}

class HackerNewsApiException extends Error {
  final String msg;
  // Constructor
  HackerNewsApiException(this.msg);
}
