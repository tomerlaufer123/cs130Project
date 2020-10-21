import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

import 'similar_images.dart';

/* 
This Page Route displays the list of generated hashtags passed to it 
*/

class HashtagPage extends StatelessWidget {
  // make stateful? https://www.youtube.com/watch?v=PqeeMy1fQys&t=0s
  @override
  HashtagPage({this.tags});
  final List<String> tags;

  Widget build(BuildContext context) {
    var total = tags.length;
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Hashtags: $total"),
        ),
        // Show entry every hashtag in generated list
        body: Scrollbar(
          child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              return Card(
                  margin: EdgeInsets.only(
                      top: 4.0, bottom: 4.0, left: 9.0, right: 9.0),
                  child: ListTile(
                    // Every Entry has:
                    // - hashtag
                    // - Ctrl+C button
                    // - button to view photos from inst with hashtag
                    title: Text('${tags[index]}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                        )),
                    trailing: Wrap(
                      spacing: 0, // space between two icons
                      children: <Widget>[
                        TextButton(
                            child: Icon(Icons.content_copy),
                            onPressed: () {
                              ClipboardManager.copyToClipBoard('${tags[index]}')
                                  .then((result) {
                                final snackBar = SnackBar(
                                  content: Text('Copied to Clipboard'),
                                );
                                Scaffold.of(context).showSnackBar(snackBar);
                              });
                            }),
                        /* TextButton( child: Icon(Icons.favorite), onPressed: null) */
                        // maybe save liked hashtags
                        TextButton(
                            child: Icon(Icons.image_search),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SimilarImages(
                                          tag: '${tags[index]}')));
                            }),
                      ],
                    ),
                  ));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xffff217e),
          foregroundColor: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          label: Text('Try Another Image!'),
          //DISCLAIMER: photo button only works once atm, crashes when pressed again idk why
        ));
  }
}
