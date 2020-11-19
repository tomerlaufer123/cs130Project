///@library
///
///@author Takashi Joubert, Karl Danielsen, Sam Pando
///@version 0.1
///@since 0.1



//import statements
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';

import 'hashtag_list.dart';
import 'history.dart';
import 'similar_images.dart';
import 'homepage.dart';
import 'api_call.dart';

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
  List _recognitions;
  //double _imageHeight;
  //double _imageWidth;
  List<String> _listOfTags; // File containing list of tags (just for testing)
  bool _busy = false; // true while tags being generated
  bool _refreshed = true; // toggle "view hashtag" button
  final picker =
      ImagePicker(); //Plugin: https://pub.dev/packages/image_picker/example
  final GlobalKey<ScaffoldState> _scaffoldKeyH = new GlobalKey<ScaffoldState>();

  Future<Album> futureAlbum;

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
      _image = null;
      _refreshed = true; // set image to captured photo
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
    setState(() {
      _busy = true;
      _refreshed = false;
    });
    predictImage(_image);
  }

  Future predictImage(File image) async {
    if (image == null) return;

    await recognizeImage(image);

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        //_imageHeight = info.image.height.toDouble();
        //_imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      //_image2 = image;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
    _busy = true;
    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        // TODO: Try w/ Rio's model
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
        // useGpuDelegate: true,
      );

      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future recognizeImage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 10,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print(recognitions);
    setState(() {
      _recognitions = recognitions;
      if (_recognitions != null) {
        _listOfTags = List<String>();
        _recognitions.forEach((res) {
          _listOfTags.add("#${res["label"]}");
        }); //add confidence later
      } else {
        _listOfTags = List<String>.generate(100, (i) => "#Hashtag$i");
      }
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      key: _scaffoldKeyH,
      appBar: AppBar(
          title: Text(widget.title),
          leading: GestureDetector(
            onTap: () => _scaffoldKeyH.currentState.openDrawer(),
            child: Icon(
              Icons.menu, // add custom icons also
            ),
          )),
      // Side Menu Opened by pressing "Menu" Button in top left
      drawer: Drawer(
          child: Container(
        color: Color(0xFF4a4a4a),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('Close',
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
            ),
            ListTile(
              title: Text('View Favorites?',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onTap: () => {
                // TODO: Maybe view favs idk
              },
              trailing: Icon(Icons.favorite, color: Color(0xFFF48Fb1)),
            ),
            ListTile(
              title: Text('See History?',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onTap: () => {
                // TODO: Maybe open page w/ previously generated tags w/ images
              },
              trailing: Icon(Icons.query_builder, color: Colors.white),
            ),
          ],
        ),
      )),
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
                          child: Opacity(
                              opacity: (_listOfTags != null &&
                                      _image != null &&
                                      !_refreshed)
                                  ? 0.4
                                  : 1.0,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xffff217e)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text('Generate',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                  onPressed: _generateTags))),
                      // Once List of Hashtags generated:
                      // -  Button to view hashtags appears
                      // -  opens new page with displayed tags
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 16),
                        child: Opacity(
                            opacity: (_listOfTags != null &&
                                    _image != null &&
                                    !_refreshed)
                                ? 1.0
                                : 0.4,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xffff217e)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text('View Hashtags',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                // When 'View Hashtags' Pressed, navigate to new page
                                onPressed: () {
                                  (_listOfTags != null && _image != null)
                                      ? Navigator.pushNamed(
                                          context, HashtagPage.routeName,
                                          arguments: ScreenArguments(
                                              _listOfTags, _image))
                                      : null;
                                })),
                      ),
                    ],
                  ),
                  Center(
                      // TODO: make opacity overlay/stack over entire screen?
                      child: _busy ? CircularProgressIndicator() : null)
                ])
          : ListView(
              // If photo not yet selected, options hidden
              // - Greyed out Crop/Refresh Buttons
              // - Tapping "Gallery"/"Camera icon opens gallery/camera
              children: <Widget>[
                  Container(
                    //width: 50.0,
                    height: 300.0,
                    color: const Color(0xff1a1a1a),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 15.0, right: 15.0),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: const Color(0xff303030),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () => _getImage(
                                          ImageSource.gallery,
                                          context: context),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(height: 30),
                                            Icon(
                                              Icons.photo_library,
                                              size: 70.0,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 20),
                                            Text('Tap to Choose\nfrom Gallery',
                                                textAlign: TextAlign
                                                    .center, //\n\nPress the camera button to pick an image!',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white)),
                                          ])),
                                  DottedLine(
                                    direction: Axis.vertical,
                                    lineLength: 260.0, //double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 7.0,
                                    dashColor: Colors.white,
                                    dashGapLength: 4.0,
                                  ),
                                  GestureDetector(
                                      onTap: () =>
                                          _getImage(ImageSource.camera),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(height: 30),
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 70.0,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 20),
                                            Text('Tap to Take a\nNew Photo',
                                                textAlign: TextAlign
                                                    .center, //\n\nPress the camera button to pick an image!',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white)),
                                          ])),
                                ]))),
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
                                    color: Color(0xff454545), size: 30),
                                onPressed: null),
                            TextButton(
                              child: Icon(Icons.refresh,
                                  color: Color(0xff454545), size: 30),
                              onPressed: null,
                            )
                          ])),
                ]),

      // NOTE: FloatingActionButton speed dial was glitchy for gallery button, removed
      // Select image from camera or gallery by pressing button
      /*floatingActionButton: SpeedDial(
        child: Icon(Icons.menu, size: 30.0),
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        children: [
          SpeedDialChild(
            label: 'See Favorites?',
            backgroundColor: Color(0xFF545454),
            child: Icon(Icons.favorite, color: Color(0xFFF48Fb1)),
            onTap: null, //TODO: maybe add favorited,
          ),
          SpeedDialChild(
            label: 'History?',
            backgroundColor: Colors.grey,
            child: Icon(Icons.query_builder),
            onTap: null,
          ),
        ],
      ),*/
    );
  }
}

// class ScreenArguments {
//   final List<String> tags;
//   final File image;

//   ScreenArguments(this.tags, this.image);
// }

