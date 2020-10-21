import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'hashtag_list.dart';

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
        scaffoldBackgroundColor: const Color(0xFF575757),
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
  final picker =
      ImagePicker(); //Plugin: https://pub.dev/packages/image_picker/example

  // Get Image from Gallery
  Future<void> _getImage(ImageSource source, {BuildContext context}) async {
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

  // Reset Image
  Future<void> _resetImage() async {
    setState(() {
      _image = null; // set image to captured photo
    });
  }

  // Crop Image
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

      body: _image != null
          ? ListView(
              // If photo has been selected:
              // -  Display photo in center of screen
              // -  Buttons to crop & redisplay
              // -  Button to generate hashtags
              children: <Widget>[
                  Container(
                      width: 50.0,
                      height: 290.0,
                      color: const Color(0xff1a1a1a),
                      child: Image.file(_image)),
                  Container(
                      width: 50.0,
                      height: 60.0,
                      color: const Color(0xff1a1a1a),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                                child: Icon(Icons.crop,
                                    color: Colors.white, size: 30),
                                onPressed: _cropImage),
                            TextButton(
                              child: Icon(Icons.refresh,
                                  color: Colors.white, size: 30),
                              onPressed: _resetImage,
                            )
                          ])),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 16),
                          child: ElevatedButton(
                              // TODO: Implement Functionality to generate list_of_tags on backend
                              child: Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text('Generate',
                                    style: TextStyle(fontSize: 20)),
                              ),
                              onPressed: _generateTags)),
                      // Once List of Hashtags generated:
                      // -  Button to view hashtags appears
                      // -  opens new page with displayed tags
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 16),
                        child: Opacity(
                            opacity: (_listOfTags != null) ? 1.0 : 0.4,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xfff76fb6)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text('View Hashtags',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                // When 'View Hashtags' Pressed, navigate to new page
                                onPressed: () {
                                  (_listOfTags != null)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HashtagPage(
                                                  tags: _listOfTags)))
                                      : null;
                                })),
                      ),
                    ],
                  )
                ])
          : ListView(
              // If photo not yet selected, options hidden
              // - Show 'No Image Selected'
              // - Greyed out Buttons
              // - Tapping "No Image Selected" opens gallery selection
              children: <Widget>[
                  GestureDetector(
                    onTap: () =>
                        _getImage(ImageSource.gallery, context: context),
                    child: Container(
                      width: 50.0,
                      height: 300.0,
                      color: const Color(0xff1a1a1a),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, left: 16.0, right: 16.0),
                        child: const DecoratedBox(
                            decoration: const BoxDecoration(
                              color: const Color(0xff303030),
                            ),
                            child: Center(
                                child: Text(
                                    'No image selected', //\n\nPress the camera button to pick an image!',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)))),
                      ),
                    ),
                  ),
                  Container(
                      width: 50.0,
                      height: 60.0,
                      color: const Color(0xff1a1a1a),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                                child: Icon(Icons.crop,
                                    color: Color(0xff828282), size: 30),
                                onPressed: null),
                            TextButton(
                              child: Icon(Icons.refresh,
                                  color: Color(0xff828282), size: 30),
                              onPressed: null,
                            )
                          ])),
                ]),

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
            onTap: () => _getImage(ImageSource.gallery, context: context),
          ),
          // DISCLAIMER pressing "choose from gallery" more than once made app crash)
          // No such issue when tapping screen w/ gesture detector
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
