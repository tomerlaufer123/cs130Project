import 'package:flutter/material.dart';
import 'dart:io';

/** 
 *This Page Route displays recently generated tags/images, as well as some stats 
 */
class HistoryPage extends StatefulWidget {
  static const routeName = '/history';

  @override
  HistoryPage({this.entries});
  final List<ScreenArguments> entries;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String mostCommon;
  String mostUnique;

  @override
  void initState() {
    super.initState();
    _getStats();
  }

  Future _getStats() async {
    if (widget.entries.isEmpty) {
      mostCommon = "N/A";
      mostUnique = 'N/A';
    } else {
      List<String> allTags = List<String>();
      for (int i = 0; i < widget.entries.length; i++) {
        allTags = allTags + widget.entries[i].tags;
      }
      // Count occurrences of each tag
      final folded = allTags.fold({}, (acc, curr) {
        acc[curr] = (acc[curr] ?? 0) + 1;
        return acc;
      }) as Map<dynamic, dynamic>;

      // Sort the keys (values) by occurrences
      final sortedKeys = folded.keys.toList()
        ..sort((a, b) => folded[b].compareTo(folded[a]));

      // Get three most frequent, and 3 least common tags
      mostCommon = [
        '${sortedKeys.first}',
        '${sortedKeys[1]}',
        '${sortedKeys[2]}'
      ].join(" ");
      mostUnique = [
        '${sortedKeys.last}',
        '${sortedKeys[sortedKeys.length - 2]}',
        '${sortedKeys[sortedKeys.length - 3]}'
      ].join(" ");
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    //final _height = MediaQuery.of(context).size.height;

    // Displays Recently loaded searches (image w/ hashtags) in horizontal side scroll
    // Only includes images/tags from current session, not all time
    final headerList = widget.entries.isEmpty
        ? Center(child: Text("Try generating some tags first!!"))
        : ListView.builder(
            itemCount: widget.entries.length,
            itemBuilder: (context, index) {
              EdgeInsets padding = index == 0
                  ? const EdgeInsets.only(
                      left: 20.0, right: 10.0, top: 4.0, bottom: 30.0)
                  : const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 4.0, bottom: 30.0);

              return Padding(
                  padding: padding,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(70),
                            offset: const Offset(3.0, 10.0),
                            blurRadius: 10.0)
                      ],
                      image: DecorationImage(
                        image: FileImage(widget.entries[index].image),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    //height: 400.0,
                    width: 200.0,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.pink, //const Color(0xffff217e),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0))),
                              height: 80.0,
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 3, left: 7, bottom: 3, right: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                            '${widget.entries[index].tags.join(" ")}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              //fontWeight: FontWeight.bold
                                            )),
                                      )
                                    ],
                                  ))),
                        )
                      ],
                    ),
                  ));
            },
            scrollDirection: Axis.horizontal,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body:
          /*Center(
        child: Text(entries.isNotEmpty ? entries[0].tags[0] : "Nothing"),
      ),*/
          Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Text(
                          '  Recently Generated',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  // Top half of page = images & tags
                  Container(height: 350.0, width: _width, child: headerList),
                  // Bottom half of page:
                  // 1) Most common tags from session 2) most unique tags
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.only(left: 15, top: 5),
                          child: Text(
                            'Recent Stats',
                            style: TextStyle(color: Colors.white),
                          ))),
                  Expanded(
                      child: ListView(
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.only(
                            top: 5.0, bottom: 4.0, left: 14.0, right: 14.0),
                        color: const Color(0xffe0e0e0),
                        child: ListTile(
                          leading: Icon(Icons.insights,
                              color: Colors.black, size: 40),
                          title: Text(
                            'Commonly Generated Tags',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('$mostCommon'),
                          //dense: true,
                          //isThreeLine: true,
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(
                            top: 5.0, bottom: 4.0, left: 14.0, right: 14.0),
                        color: const Color(0xffe0e0e0),
                        child: ListTile(
                          leading: Icon(Icons.grade_rounded,
                              color: Colors.black, size: 40),
                          title: Text(
                            'Most Unique Tags',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('$mostUnique'),
                          //dense: true,
                          //isThreeLine: true,
                        ),
                      )
                    ],
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/**
* Defines data for display of image and its tags.
*/
class ScreenArguments {
  final List<String> tags;
  final File image;

  ScreenArguments(this.tags, this.image);
}
