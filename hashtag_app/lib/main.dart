import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'hashtag_list.dart';
import 'history.dart';
import 'similar_images.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hashtag Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF4a4a4a),
      ),
      home: MyHomePage(title: 'Hashtag Generator'),
      onGenerateRoute: (settings) {
        // extract arguments and pass to new screen constructor
        switch (settings.name) {
          case HashtagPage.routeName:
            final ScreenArguments args = settings.arguments;
            return MaterialPageRoute(
                builder: (context) =>
                    HashtagPage(tags: args.tags, image: args.image));
          case SimilarImages.routeName:
            final tag = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => SimilarImages(tag: tag));
          case HistoryPage.routeName:
            final List<ScreenArguments> args = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => HistoryPage(entries: args));
          default:
            return null;
        }
      },
    );
  }
}
