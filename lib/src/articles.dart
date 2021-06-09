import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'articles.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  static Serializer<Article> get serializer => _$articleSerializer;

  @nullable
  int get id;
  @nullable
  String get by;
  @nullable
  String get type;
  @nullable
  int get time;
  @nullable
  String get text;
  @nullable
  bool get dead;
  @nullable
  int get poll;
  @nullable
  int get parent;
  BuiltList<int> get kids;
  @nullable
  String get url;
  @nullable
  int get score;
  @nullable
  String get title;
  BuiltList<int> get parts;
  @nullable
  int get descendents;

  Article._();
  factory Article([void Function(ArticleBuilder) updates]) = _$Article;
}

// ? parseTopStories stuff
List<int> parseTopStories(String jsonStr) {
  return [];
  // final parsed = jsonDecode(jsonStr);
  // final listOfOds = List<int>.from(parsed);
  // return listOfOds;
}

// ? parse Article stuff
Article parseArticle(String jsonStr) {
  final parsed = jsonDecode(jsonStr);
  Article article =
      standardSerializers.deserializeWith(Article.serializer, parsed);
  return article;
}
