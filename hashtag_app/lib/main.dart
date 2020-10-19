import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

void main() {
  runApp(MyApp());
}

// Widget displays hashtags generated, passed w/ tags constructor argument
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
        // Generate new widget for every tag in list
        body: Scrollbar(
          child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text('${tags[index]}'),
                  //https://pub.dev/packages/clipboard_manager/example
                  trailing: TextButton(
                      child: Icon(Icons.content_copy),
                      onPressed: () {
                        ClipboardManager.copyToClipBoard("your text to copy")
                            .then((result) {
                          final snackBar = SnackBar(
                            content: Text('Copied to Clipboard'),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        });
                      }));
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
} // Documentation for lots: https://flutter.dev/docs/cookbook/

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hashtag Generator',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hashtag Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //state Object
  File _image; // Image file (saved in memory)
  List<String> _listOfTags; // File containing list of tags (just for testing)
  final picker = ImagePicker(); //Plugin: https://pub.dev/packages/image_picker

  // Get Image from Gallery
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(
        source: source, maxWidth: 300.0, maxHeight: 500.0); //ImageSource.camera

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values.
      if (pickedFile != null) {
        _image = File(pickedFile.path); // set image to captured photo
      } else {
        print('No image selected.');
      }
    });
  }

  // Cropper plugin https://pub.dev/packages/image_cropper
  // Tutorial: https://fireship.io/lessons/flutter-file-uploads-cloud-storage/
  Future<void> _cropImage() async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
        ],
        /*androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop your photo',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),*/
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 0.1,
        ));

    setState(() {
      _image = (croppedImage != null) ? croppedImage : _image;
    });
  }

  // Generate Hashtags --> store file as L
  Future _generateTags() async {
    // TODO: do something with "_image" file (pass to tflite?)
    // I just show numbered list here
    setState(() {
      _listOfTags = List<String>.generate(100, (i) => "#Hashtag$i");
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: ListView(
        children: <Widget>[
          if (_image != null) ...[
            // Once photo selected:
            // -  Display photo in center of screen
            // -  Buttons to crop & redisplay
            // -  Button to generate hashtags
            Container(child: Image.file(_image)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                    //child: Icon(Icons.crop, color: Colors.white, size: 30),
                    child: Text('Crop Image',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: _cropImage),
                // TODO: Generate Hashtags Functionality to generate list_of_tags
                ElevatedButton(
                    child: Text('Generate Hashtags',
                        style: TextStyle(fontSize: 18)),
                    onPressed: _generateTags),
                // change so list of tags is  file object after
              ],
            ),
            // Once List of Hashtags generated:
            // -  Button to view hashtags appears
            // -  opens new page with displayed tags
            Visibility(
                visible: _listOfTags != null,
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('View Hashtags',
                            style: TextStyle(fontSize: 25)),
                      ),
                      // When 'View Hashtags' Pressed, navigate to new page
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HashtagPage(tags: _listOfTags)),
                        );
                      }),
                )))
          ] else
            // If photo not yet selected, options hidden
            Container(
              width: 50.0,
              height: 300.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 17)),
              child: const DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: Center(
                      child: Text(
                          'No image selected', //\n\nPress the camera button to pick an image!',
                          style:
                              TextStyle(fontSize: 17, color: Colors.white)))),
            ),
        ],
      ),

      // Select image from camera or gallery by pressing button
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add_a_photo, size: 30.0),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            label: 'Choose from Gallery',
            backgroundColor: Colors.blue,
            child: Icon(Icons.photo_library),
            onTap: () => _getImage(ImageSource.gallery),
          ),
          SpeedDialChild(
            label: 'Take photo',
            backgroundColor: Colors.blue,
            child: Icon(Icons.photo_camera),
            onTap: () => _getImage(ImageSource.camera),
            //Debug: why pressing button after selecitng photo time crashes
          ),
        ],
      ),
    );
  }
}
