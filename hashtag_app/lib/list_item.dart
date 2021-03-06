import 'package:flutter/material.dart';
import 'similar_images.dart';


/**
 * A class for the graphical display of individual tags. Only contains the tag
 * item and changes its state depending on if it is selected.
 * <p>
 * Extensions of this class specify the details of display, a la the first
 * design philosophy we learned
 */
class ListItem extends StatefulWidget {
  final Key key;
  final Item item;
  final ValueChanged<bool> isSelected; //callback

  ListItem({this.item, this.isSelected, this.key});

  @override
  _ListItemState createState() => _ListItemState();
}

/**
 * An extension of the superclass ListItem, which specifies exactly how to
 * display a ListItem object. This created a basic display of the tag and its
 * rating.
 */
class _ListItemState extends State<ListItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Card(
              color: Colors.white.withOpacity(isSelected ? 0.5 : 0.8),
              margin:
                  EdgeInsets.only(top: 4.0, bottom: 4.0, left: 9.0, right: 9.0),
              child: ListTile(
                // Every Entry has:
                // - hashtag
                // - Ctrl+C button
                // - button to view photos from inst with hashtag
                title: Text('${widget.item.tag}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    )),
                trailing: Wrap(
                  spacing: 0, // space between two icons
                  children: <Widget>[
                    TextButton(
                        child:
                            Icon(Icons.image_search, color: Color(0xFF404040)),
                        onPressed: () {
                          Navigator.pushNamed(context, SimilarImages.routeName,
                              arguments: '${widget.item.tag}');
                        }),
                    //TODOMaybe: save liked hashtags. Use callback like before
                    /*TextButton(
                        child: Icon(Icons.favorite_border,
                            color: Color(0xFF404040)),
                        onPressed: null), */
                  ],
                ),
              )),
          isSelected
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0, right: 5),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.pink,
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0, right: 5),
                    child: Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.pink,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

/**
 * Items are the tags to be displayed.
 */
class Item {
  ///The hashtag to be displayed
  String tag;
  ///The quality of the hashtag
  int rank;
  /**
   * A basic constructor for an Item object.
   */
  Item(this.tag, this.rank);
}
