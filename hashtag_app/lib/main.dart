//import statements
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';

import 'hashtag_list.dart';
import 'history.dart';
import 'similar_images.dart';
import 'homepage.dart';

/**
 * @author Takashi Joubert, Karl Danielsen, Sam Pando
 * @version 0.1
 * @since 0.1
 */
void main() {
  runApp(MyApp());
}

/**
 * Trend objects hold the data for each individual trend.
 * <p>
 * These are used within a List in the album class to store the trends data in
 * a readable and easily accessible format.
 *
 * @fields are named the same way they are named in the json object, only
 * "name" and "volume" are used for now.
 */
class Trend {
  final String name;
  final String url;
  final String content;
  final String query;
  final int    volume;

  /**
   * A basic constructor for Trends
   *
   * @return initialized Trend object 
  */
  Trend({this.name,this.url,this.content,this.query,this.volume});

  /**
   * A factory method to build Trend objects using input json 
   *
   * @params 'json' is one parsed layer of json, mapping var names to values 
   * @return initialized Trend object 
  */
  factory Trend.fromJson(Map<String,dynamic> json){
    return Trend(
      name: json['name'],
      url:  json['url'],
      content: json['promoted_content'],
      query: json['query'],
      volume: json['volume'],
    );
  }
}

/**
 * Album is a wrapper class for the list of trends, and helps parse Json.
 * <p>
 * In the style of an Adaptor interface, Album and Trend work in tandem to
 * turn the messy Json into an easily readable format, used later in Future
 * objects.
 * <p>
 * Because of the implementation, different API calls or non-json return types
 * could be parsed into the correct format w/ different implementations of these
 * two's factory methods.
 *
 * @fields consists of a list of Trends objects, whose initialization is handled
 * by calls to the Trends factory.
 */
class Album {
  final List<Trend> trends;

  /**
   * A basic constructor for Album
   *
   * @return initialized Album object 
  */
  Album({this.trends});

  /**
   * A factory to convert Json objects to a list of trends.
   * <p>
   * Recursively calls the Trend constructor and constructs a List of all the
   * trends returned by the API call.
   *
   * @params 'json' is a List that contains the entire json object in its first
   * field.
   * @return initialized Album object 
  */
  factory Album.fromJson(List<dynamic> json){
      List<Trend> trendList = new List<Trend>();
      for(var js in json[0]['trends']){
        trendList.add(Trend.fromJson(js));
      }
      return Album(
        trends: trendList,
    );
  }
  
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

Future<Album> fetchAlbum() async {
  //TODO: Code in here is entirely placeholder. For now, manually set Album
  print("attempting response fetch...");
  var jobj = '[{"trends":[{"name":"#TheBachelorette","url":"http:\/\/twitter.com\/search?q=%23TheBachelorette","promoted_content":null,"query":"%23TheBachelorette","tweet_volume":57785},{"name":"MySpace","url":"http:\/\/twitter.com\/search?q=MySpace","promoted_content":null,"query":"MySpace","tweet_volume":72808},{"name":"App Store","url":"http:\/\/twitter.com\/search?q=%22App+Store%22","promoted_content":null,"query":"%22App+Store%22","tweet_volume":64703},{"name":"Gavin Newsom","url":"http:\/\/twitter.com\/search?q=%22Gavin+Newsom%22","promoted_content":null,"query":"%22Gavin+Newsom%22","tweet_volume":30475},{"name":"French Laundry","url":"http:\/\/twitter.com\/search?q=%22French+Laundry%22","promoted_content":null,"query":"%22French+Laundry%22","tweet_volume":null},{"name":"Emily Murphy","url":"http:\/\/twitter.com\/search?q=%22Emily+Murphy%22","promoted_content":null,"query":"%22Emily+Murphy%22","tweet_volume":34675},{"name":"Chris Krebs","url":"http:\/\/twitter.com\/search?q=%22Chris+Krebs%22","promoted_content":null,"query":"%22Chris+Krebs%22","tweet_volume":291326},{"name":"#wednesdaythought","url":"http:\/\/twitter.com\/search?q=%23wednesdaythought","promoted_content":null,"query":"%23wednesdaythought","tweet_volume":46982},{"name":"#NBADraft","url":"http:\/\/twitter.com\/search?q=%23NBADraft","promoted_content":null,"query":"%23NBADraft","tweet_volume":20102},{"name":"Wiseman","url":"http:\/\/twitter.com\/search?q=Wiseman","promoted_content":null,"query":"Wiseman","tweet_volume":10314},{"name":"Lamelo","url":"http:\/\/twitter.com\/search?q=Lamelo","promoted_content":null,"query":"Lamelo","tweet_volume":18117},{"name":"#WednesdayWisdom","url":"http:\/\/twitter.com\/search?q=%23WednesdayWisdom","promoted_content":null,"query":"%23WednesdayWisdom","tweet_volume":12204},{"name":"Logan Paul","url":"http:\/\/twitter.com\/search?q=%22Logan+Paul%22","promoted_content":null,"query":"%22Logan+Paul%22","tweet_volume":12591},{"name":"#ThxBirthControl","url":"http:\/\/twitter.com\/search?q=%23ThxBirthControl","promoted_content":null,"query":"%23ThxBirthControl","tweet_volume":null},{"name":"Orwellian","url":"http:\/\/twitter.com\/search?q=Orwellian","promoted_content":null,"query":"Orwellian","tweet_volume":null},{"name":"Anthony Edwards","url":"http:\/\/twitter.com\/search?q=%22Anthony+Edwards%22","promoted_content":null,"query":"%22Anthony+Edwards%22","tweet_volume":null},{"name":"Half of Republicans","url":"http:\/\/twitter.com\/search?q=%22Half+of+Republicans%22","promoted_content":null,"query":"%22Half+of+Republicans%22","tweet_volume":15092},{"name":"Wendell","url":"http:\/\/twitter.com\/search?q=Wendell","promoted_content":null,"query":"Wendell","tweet_volume":null},{"name":"GOWON","url":"http:\/\/twitter.com\/search?q=GOWON","promoted_content":null,"query":"GOWON","tweet_volume":38981},{"name":"Gibbs","url":"http:\/\/twitter.com\/search?q=Gibbs","promoted_content":null,"query":"Gibbs","tweet_volume":null},{"name":"Bulls","url":"http:\/\/twitter.com\/search?q=Bulls","promoted_content":null,"query":"Bulls","tweet_volume":18651},{"name":"Vanilla ISIS","url":"http:\/\/twitter.com\/search?q=%22Vanilla+ISIS%22","promoted_content":null,"query":"%22Vanilla+ISIS%22","tweet_volume":null},{"name":"Obi Toppin","url":"http:\/\/twitter.com\/search?q=%22Obi+Toppin%22","promoted_content":null,"query":"%22Obi+Toppin%22","tweet_volume":null},{"name":"Jeezy","url":"http:\/\/twitter.com\/search?q=Jeezy","promoted_content":null,"query":"Jeezy","tweet_volume":34188},{"name":"Boeing 737 Max","url":"http:\/\/twitter.com\/search?q=%22Boeing+737+Max%22","promoted_content":null,"query":"%22Boeing+737+Max%22","tweet_volume":11042},{"name":"Deni","url":"http:\/\/twitter.com\/search?q=Deni","promoted_content":null,"query":"Deni","tweet_volume":null},{"name":"Milwaukee and Dane","url":"http:\/\/twitter.com\/search?q=%22Milwaukee+and+Dane%22","promoted_content":null,"query":"%22Milwaukee+and+Dane%22","tweet_volume":null},{"name":"Cole Anthony","url":"http:\/\/twitter.com\/search?q=%22Cole+Anthony%22","promoted_content":null,"query":"%22Cole+Anthony%22","tweet_volume":null},{"name":"Ante Tomic","url":"http:\/\/twitter.com\/search?q=%22Ante+Tomic%22","promoted_content":null,"query":"%22Ante+Tomic%22","tweet_volume":null},{"name":"YES THEY DID","url":"http:\/\/twitter.com\/search?q=%22YES+THEY+DID%22","promoted_content":null,"query":"%22YES+THEY+DID%22","tweet_volume":null},{"name":"Twitter OG","url":"http:\/\/twitter.com\/search?q=%22Twitter+OG%22","promoted_content":null,"query":"%22Twitter+OG%22","tweet_volume":70135},{"name":"Oh Santa","url":"http:\/\/twitter.com\/search?q=%22Oh+Santa%22","promoted_content":null,"query":"%22Oh+Santa%22","tweet_volume":null},{"name":"Pfizer and BioNTech","url":"http:\/\/twitter.com\/search?q=%22Pfizer+and+BioNTech%22","promoted_content":null,"query":"%22Pfizer+and+BioNTech%22","tweet_volume":11534},{"name":"Hump Day","url":"http:\/\/twitter.com\/search?q=%22Hump+Day%22","promoted_content":null,"query":"%22Hump+Day%22","tweet_volume":13436},{"name":"Michael B Jordan","url":"http:\/\/twitter.com\/search?q=%22Michael+B+Jordan%22","promoted_content":null,"query":"%22Michael+B+Jordan%22","tweet_volume":20050},{"name":"Lavar","url":"http:\/\/twitter.com\/search?q=Lavar","promoted_content":null,"query":"Lavar","tweet_volume":29763},{"name":"NYXL","url":"http:\/\/twitter.com\/search?q=NYXL","promoted_content":null,"query":"NYXL","tweet_volume":null},{"name":"Warriors","url":"http:\/\/twitter.com\/search?q=Warriors","promoted_content":null,"query":"Warriors","tweet_volume":50678},{"name":"Sexiest Man Alive","url":"http:\/\/twitter.com\/search?q=%22Sexiest+Man+Alive%22","promoted_content":null,"query":"%22Sexiest+Man+Alive%22","tweet_volume":15787},{"name":"George Clooney","url":"http:\/\/twitter.com\/search?q=%22George+Clooney%22","promoted_content":null,"query":"%22George+Clooney%22","tweet_volume":null},{"name":"Donyale Luna","url":"http:\/\/twitter.com\/search?q=%22Donyale+Luna%22","promoted_content":null,"query":"%22Donyale+Luna%22","tweet_volume":null},{"name":"Wagon Wednesday","url":"http:\/\/twitter.com\/search?q=%22Wagon+Wednesday%22","promoted_content":null,"query":"%22Wagon+Wednesday%22","tweet_volume":null},{"name":"Challenge Cup","url":"http:\/\/twitter.com\/search?q=%22Challenge+Cup%22","promoted_content":null,"query":"%22Challenge+Cup%22","tweet_volume":null},{"name":"Steamboat Willie","url":"http:\/\/twitter.com\/search?q=%22Steamboat+Willie%22","promoted_content":null,"query":"%22Steamboat+Willie%22","tweet_volume":null},{"name":"Nvidia","url":"http:\/\/twitter.com\/search?q=Nvidia","promoted_content":null,"query":"Nvidia","tweet_volume":null},{"name":"Okoro","url":"http:\/\/twitter.com\/search?q=Okoro","promoted_content":null,"query":"Okoro","tweet_volume":null},{"name":"Patrick Williams","url":"http:\/\/twitter.com\/search?q=%22Patrick+Williams%22","promoted_content":null,"query":"%22Patrick+Williams%22","tweet_volume":null},{"name":"minnie mouse","url":"http:\/\/twitter.com\/search?q=%22minnie+mouse%22","promoted_content":null,"query":"%22minnie+mouse%22","tweet_volume":null},{"name":"Lavine","url":"http:\/\/twitter.com\/search?q=Lavine","promoted_content":null,"query":"Lavine","tweet_volume":null},{"name":"Danish","url":"http:\/\/twitter.com\/search?q=Danish","promoted_content":null,"query":"Danish","tweet_volume":29402}],"as_of":"2020-11-18T16:25:14Z","created_at":"2020-11-17T14:04:14Z","locations":[{"name":"Los Angeles","woeid":2442047}]}]';  
  return Album.fromJson(jsonDecode(jobj));


  var response = await http.get('https://api.twitter.com/1.1/trends/place.json?id=2442047', headers: {"Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAADu%2BJgEAAAAAgqy73WFp%2Bnd9pXPCHBym9afDra0%3DnT67LdN67UcbaJtCpOzGbtfjRlMCTgL49E56VdG9gAQ045Rm5F"});
  print("end attempt.");

  if (response.statusCode == 200) {
    print('nope');
    return Album.fromJson(jsonDecode(response.body));
  } else if(response.statusCode == 401){
    print('insufficient authorization');
  }
  else {
    print('yep');
    throw Exception('Twitter server failed to respond.');
  }
}
