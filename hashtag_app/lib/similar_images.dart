import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/** 
* This Page Route displays images related to the hashtag argument passed to it 
*/

// TODO: see if you could use or incorperate instagram/Twitter API
class SimilarImages extends StatelessWidget {
  static const routeName = '/similarImages';

  @override
  SimilarImages({this.tag});
  final String tag; // the hashtag in question, passed as argument

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Related to $tag")),
        body: Scrollbar(
            child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(50, (index) {
            return Container(
              child: Card(
                  color: const Color(0xff1a1a1a),
                  child: Icon(Icons.image_outlined,
                      color: Color(0xff737373), size: 60)),
            );
          }),
        )));
  }
}
