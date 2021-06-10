import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      theme: ThemeData(primarySwatch: Colors.deepOrange),
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
                Text('${article.descendents} comments'),
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

class LoadingInfo extends StatefulWidget {
  final Stream<bool> isLoading;

  const LoadingInfo({Key key, @required this.isLoading}) : super(key: key);

  @override
  _LoadingInfoState createState() => _LoadingInfoState();
}

class _LoadingInfoState extends State<LoadingInfo>
    with SingleTickerProviderStateMixin {
  // ? anim var
  AnimationController _controller;
  Animation animation;

  //? init state to initialize animation and all

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.isLoading,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // if (snapshot.hasData && snapshot.data) {
        _controller.forward().then((value) => _controller.reverse());
        return FadeTransition(
            opacity: Tween(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeIn)),
            child: Icon(FontAwesomeIcons.hackerNewsSquare));
        // }
        // return Container();
      },
    );
  }
}
