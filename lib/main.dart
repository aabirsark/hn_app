import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hn_app/src/articles.dart';
import 'package:hn_app/src/hn_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  var hnBloc = HackerNewsBloc();
  runApp(MyApp(
    bloc: hnBloc,
  ));
}

class MyApp extends StatelessWidget {
  final HackerNewsBloc bloc;

  const MyApp({Key key, @required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(
        bloc: bloc,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final HackerNewsBloc bloc;

  const HomePage({Key key, @required this.bloc}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ? var is for navigation bottom bar
  int _indexVal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Hacker News"),
          centerTitle: true,
          leading: LoadingInfo(
            isLoading: widget.bloc.isLoading,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indexVal,
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bell), label: "Top Stories"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.news), label: "New Stories")
          ],
          onTap: (index) {
            if (index == 0) {
              widget.bloc.storiesType.add(StoriesType.topStories);
            } else
              widget.bloc.storiesType.add(StoriesType.newStories);
            setState(() {
              _indexVal = index;
            });
          },
        ),
        body: StreamBuilder<UnmodifiableListView<Article>>(
          stream: widget.bloc.articles,
          initialData: UnmodifiableListView<Article>([]),
          builder: (context, snapshot) {
            return ListView(
              children: snapshot.data.map(myTile).toList(),
            );
          },
        ));
  }

  Widget myTile(Article article) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(article.title),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(article.type),
                IconButton(
                    icon: Icon(CupertinoIcons.share),
                    onPressed: () async {
                      if (await canLaunch(article.url)) {
                        launch(article.url);
                      } else {
                        print("Something went Wrong");
                      }
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LoadingInfo extends StatelessWidget {
  final Stream<bool> isLoading;

  const LoadingInfo({Key key, @required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: isLoading,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return CircularProgressIndicator();
        }
        return Container();
      },
    );
  }
}
