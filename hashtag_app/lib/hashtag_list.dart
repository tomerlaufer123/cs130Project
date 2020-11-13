import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'dart:io';

import 'list_item.dart';

/* 
This Page Route displays the list of generated hashtags passed to it 
*/
class HashtagPage extends StatefulWidget {
  static const routeName = '/hashtaglist';
  final List<String> tags; // create Item class for each? (hold tag, rank, etc)
  final File image; ////unused for now, but can display

  HashtagPage({this.tags, this.image}); // add keys?
  @override
  _HashtagPageState createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  List<Item> allTags = List();
  List<Item> selectedTags = List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    var total = widget.tags.length;
    allTags = List<Item>.generate(
        total, (index) => Item('${widget.tags[index]}', index));
    return Scaffold(
      key: _scaffoldKey,
      // When tags selected, tapping "Copy" button copies all selected to clipboard
      appBar: AppBar(
        title: Text(selectedTags.length < 1
            ? "Your Hashtags: $total"
            : "${selectedTags.length} tags selected"),
        actions: <Widget>[
          selectedTags.length < 1
              ? Container()
              : InkWell(
                  onTap: () {
                    setState(() {
                      // Combine into one string to copy
                      String mergedTags = '';
                      for (int i = 0; i < selectedTags.length; i++) {
                        mergedTags = mergedTags + ' ' + selectedTags[i].tag;
                      }
                      ClipboardManager.copyToClipBoard(mergedTags)
                          .then((result) {
                        showSnackBar('Copied to Clipboard');
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.content_copy),
                  ))
        ],
      ),
      // Show entry every hashtag in generated list. Tap to select/deselect
      body: Scrollbar(
          child: ListView.builder(
              itemCount: widget.tags.length,
              itemBuilder: (context, index) {
                return ListItem(
                    item: allTags[index],
                    // Update Selection when tag selected/unselected
                    isSelected: (bool value) {
                      setState(() {
                        if (value) {
                          selectedTags.add(allTags[index]);
                        } else {
                          selectedTags.removeWhere(
                              (item) => item.tag == allTags[index].tag);
                        }
                      });
                      //print("$index : $value");
                    },
                    key: Key(allTags[index].rank.toString()));
              })),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xffff217e),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios),
        label: Text('Try Another Image'),
      ), // Backbutton w/ same function already included in scaffold
    );
  }
}
