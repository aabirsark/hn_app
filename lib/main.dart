import 'dart:collection';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hn_app/src/articles.dart';
import 'package:hn_app/src/hn_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
          )),
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
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Hacker News",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: LoadingInfo(
            isLoading: widget.bloc.isLoading,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: MySearchApp(widget.bloc.articles));
                })
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
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
              children: snapshot.data.map((e) => myTile(e, context)).toList(),
            );
          },
        ));
  }

  Widget myTile(Article article, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          article.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('${article.descendents.toString()} comments'),
                IconButton(
                    icon: Icon(CupertinoIcons.share),
                    onPressed: () async {
                      // if (await canLaunch(article.url)) {
                      //   launch(article.url);
                      // } else {
                      //   print("Something went Wrong");
                      // }
                      Navigator.of(context).push(_createPage(article.url));
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

class MySearchApp extends SearchDelegate<UnmodifiableListView<Article>> {
  final Stream<UnmodifiableListView<Article>> article;

  MySearchApp(this.article);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: article,
      builder: (BuildContext context,
          AsyncSnapshot<UnmodifiableListView<Article>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text("No Data"),
          );
        }

        var results = snapshot.data
            .where((element) => element.title.toLowerCase().contains(query));

        return ListView(
          children: results.map<Widget>((e) {
            return ListTile(
              title: Text(
                e.title,
              ),
              leading: Icon(CupertinoIcons.arrow_right),
              onTap: () async {
                if (await canLaunch(e.url)) {
                  launch(e.url);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: article,
      builder: (BuildContext context,
          AsyncSnapshot<UnmodifiableListView<Article>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text("No Data"),
          );
        }

        var results = snapshot.data
            .where((element) => element.title.toLowerCase().contains(query));

        return ListView(
          children: results.map<Widget>((e) {
            return ListTile(
              title: Text(
                e.title,
              ),
              leading: Icon(CupertinoIcons.arrow_right),
              onTap: () {
                query = e.title;
              },
            );
          }).toList(),
        );
      },
    );
  }
}

Route _createPage(String url) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondryAnimation) =>
          WebViewPage(url: url),
      transitionsBuilder: (context, animation, secondryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      });
}

class WebViewPage extends StatelessWidget {
  const WebViewPage({Key key, this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hacker Reader",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: WebView(
        initialUrl: url,
      ),
    );
  }
}
