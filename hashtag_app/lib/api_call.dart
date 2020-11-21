import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  ///The trending phrase itself
  final String name;
  final String url;
  final String content;
  final String query;

  ///Frequency of the trend's use
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
 * TrendAlbum is a wrapper class for the list of trends, and helps parse Json.
 * <p>
 * In the style of an Adaptor interface, Album and Trend work in tandem to
 * turn the messy Json into an easily readable format, used later in Future
 * objects.
 * <p>
 * Because of the implementation, different API calls or non-json return types
 * could be parsed into the correct format w/ different implementations of these
 * two's factory methods.
 *
 */
class TrendAlbum {
  ///A list of [Trend] objects, whose initialization is handled [Trend.fromJson()].
  final List<Trend> trends;

  /**
   * A basic constructor for Album
   *
   * @return initialized Album object 
  */
  TrendAlbum({this.trends});

  /**
   * A factory to convert Json objects to a list of trends.
   * <p>
   * Recursively calls the Trend constructor and constructs a List of all the
   * trends returned by the API call.
   *
   * @params 'json' is a List that contains the entire json object in its first
   * field.
   * @return Initialized Album object 
  */
  factory TrendAlbum.fromJson(List<dynamic> json){
      List<Trend> trendList = new List<Trend>();
      for(var js in json[0]['trends']){
        trendList.add(Trend.fromJson(js));
      }
      return TrendAlbum(
        trends: trendList,
    );
  }
}


/**
 * This function makes the GET request to receive information from the thesaurus API.
 *
 * @return Future object that can be used to access the reformatted data.
 */
Future<SynAlbum> fetchSynAlbum() async {
  final response =
      await http.get('https://www.dictionaryapi.com/api/v3/references/thesaurus/json/umpire?key=26ac1a83-30e4-4a1f-9631-9a216ec03a33');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return SynAlbum.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}


/**
 * SynAlbum is a wrapper class for the list of synonyms, and helps parse Json.
 * <p>
 * In the style of an Adaptor interface, Album and Trend work in tandem to
 * turn the messy Json into an easily readable format, used later in Future
 * objects.
 * <p>
 * Because of the implementation, different API calls or non-json return types
 * could be parsed into the correct format w/ different implementations of these
 * two's factory methods.
 *
 */
class SynAlbum {
  List<String> synonyms;

  SynAlbum({this.synonyms});

  factory SynAlbum.fromJson(List<dynamic> json) {
    List<String> syns = new List<String>();
    for(var syn in json[0]['meta']['syns'][0]){
      syns.add(syn);
    }
    return SynAlbum(
      synonyms : syns,
    );
  }
}


/**
 * This function makes the GET request to receive information from the twitter API.
 *
 * @return Future object that can be used to access the reformatted data.
 */
Future<TrendAlbum> fetchTrendAlbum() async {
  //TODO: Code in here is entirely placeholder. For now, manually set Album
  print("attempting response fetch...");
  var jobj = '[{"trends":[{"name":"#TheBachelorette","url":"http:\/\/twitter.com\/search?q=%23TheBachelorette","promoted_content":null,"query":"%23TheBachelorette","tweet_volume":57785},{"name":"MySpace","url":"http:\/\/twitter.com\/search?q=MySpace","promoted_content":null,"query":"MySpace","tweet_volume":72808},{"name":"App Store","url":"http:\/\/twitter.com\/search?q=%22App+Store%22","promoted_content":null,"query":"%22App+Store%22","tweet_volume":64703},{"name":"Gavin Newsom","url":"http:\/\/twitter.com\/search?q=%22Gavin+Newsom%22","promoted_content":null,"query":"%22Gavin+Newsom%22","tweet_volume":30475},{"name":"French Laundry","url":"http:\/\/twitter.com\/search?q=%22French+Laundry%22","promoted_content":null,"query":"%22French+Laundry%22","tweet_volume":null},{"name":"Emily Murphy","url":"http:\/\/twitter.com\/search?q=%22Emily+Murphy%22","promoted_content":null,"query":"%22Emily+Murphy%22","tweet_volume":34675},{"name":"Chris Krebs","url":"http:\/\/twitter.com\/search?q=%22Chris+Krebs%22","promoted_content":null,"query":"%22Chris+Krebs%22","tweet_volume":291326},{"name":"#wednesdaythought","url":"http:\/\/twitter.com\/search?q=%23wednesdaythought","promoted_content":null,"query":"%23wednesdaythought","tweet_volume":46982},{"name":"#NBADraft","url":"http:\/\/twitter.com\/search?q=%23NBADraft","promoted_content":null,"query":"%23NBADraft","tweet_volume":20102},{"name":"Wiseman","url":"http:\/\/twitter.com\/search?q=Wiseman","promoted_content":null,"query":"Wiseman","tweet_volume":10314},{"name":"Lamelo","url":"http:\/\/twitter.com\/search?q=Lamelo","promoted_content":null,"query":"Lamelo","tweet_volume":18117},{"name":"#WednesdayWisdom","url":"http:\/\/twitter.com\/search?q=%23WednesdayWisdom","promoted_content":null,"query":"%23WednesdayWisdom","tweet_volume":12204},{"name":"Logan Paul","url":"http:\/\/twitter.com\/search?q=%22Logan+Paul%22","promoted_content":null,"query":"%22Logan+Paul%22","tweet_volume":12591},{"name":"#ThxBirthControl","url":"http:\/\/twitter.com\/search?q=%23ThxBirthControl","promoted_content":null,"query":"%23ThxBirthControl","tweet_volume":null},{"name":"Orwellian","url":"http:\/\/twitter.com\/search?q=Orwellian","promoted_content":null,"query":"Orwellian","tweet_volume":null},{"name":"Anthony Edwards","url":"http:\/\/twitter.com\/search?q=%22Anthony+Edwards%22","promoted_content":null,"query":"%22Anthony+Edwards%22","tweet_volume":null},{"name":"Half of Republicans","url":"http:\/\/twitter.com\/search?q=%22Half+of+Republicans%22","promoted_content":null,"query":"%22Half+of+Republicans%22","tweet_volume":15092},{"name":"Wendell","url":"http:\/\/twitter.com\/search?q=Wendell","promoted_content":null,"query":"Wendell","tweet_volume":null},{"name":"GOWON","url":"http:\/\/twitter.com\/search?q=GOWON","promoted_content":null,"query":"GOWON","tweet_volume":38981},{"name":"Gibbs","url":"http:\/\/twitter.com\/search?q=Gibbs","promoted_content":null,"query":"Gibbs","tweet_volume":null},{"name":"Bulls","url":"http:\/\/twitter.com\/search?q=Bulls","promoted_content":null,"query":"Bulls","tweet_volume":18651},{"name":"Vanilla ISIS","url":"http:\/\/twitter.com\/search?q=%22Vanilla+ISIS%22","promoted_content":null,"query":"%22Vanilla+ISIS%22","tweet_volume":null},{"name":"Obi Toppin","url":"http:\/\/twitter.com\/search?q=%22Obi+Toppin%22","promoted_content":null,"query":"%22Obi+Toppin%22","tweet_volume":null},{"name":"Jeezy","url":"http:\/\/twitter.com\/search?q=Jeezy","promoted_content":null,"query":"Jeezy","tweet_volume":34188},{"name":"Boeing 737 Max","url":"http:\/\/twitter.com\/search?q=%22Boeing+737+Max%22","promoted_content":null,"query":"%22Boeing+737+Max%22","tweet_volume":11042},{"name":"Deni","url":"http:\/\/twitter.com\/search?q=Deni","promoted_content":null,"query":"Deni","tweet_volume":null},{"name":"Milwaukee and Dane","url":"http:\/\/twitter.com\/search?q=%22Milwaukee+and+Dane%22","promoted_content":null,"query":"%22Milwaukee+and+Dane%22","tweet_volume":null},{"name":"Cole Anthony","url":"http:\/\/twitter.com\/search?q=%22Cole+Anthony%22","promoted_content":null,"query":"%22Cole+Anthony%22","tweet_volume":null},{"name":"Ante Tomic","url":"http:\/\/twitter.com\/search?q=%22Ante+Tomic%22","promoted_content":null,"query":"%22Ante+Tomic%22","tweet_volume":null},{"name":"YES THEY DID","url":"http:\/\/twitter.com\/search?q=%22YES+THEY+DID%22","promoted_content":null,"query":"%22YES+THEY+DID%22","tweet_volume":null},{"name":"Twitter OG","url":"http:\/\/twitter.com\/search?q=%22Twitter+OG%22","promoted_content":null,"query":"%22Twitter+OG%22","tweet_volume":70135},{"name":"Oh Santa","url":"http:\/\/twitter.com\/search?q=%22Oh+Santa%22","promoted_content":null,"query":"%22Oh+Santa%22","tweet_volume":null},{"name":"Pfizer and BioNTech","url":"http:\/\/twitter.com\/search?q=%22Pfizer+and+BioNTech%22","promoted_content":null,"query":"%22Pfizer+and+BioNTech%22","tweet_volume":11534},{"name":"Hump Day","url":"http:\/\/twitter.com\/search?q=%22Hump+Day%22","promoted_content":null,"query":"%22Hump+Day%22","tweet_volume":13436},{"name":"Michael B Jordan","url":"http:\/\/twitter.com\/search?q=%22Michael+B+Jordan%22","promoted_content":null,"query":"%22Michael+B+Jordan%22","tweet_volume":20050},{"name":"Lavar","url":"http:\/\/twitter.com\/search?q=Lavar","promoted_content":null,"query":"Lavar","tweet_volume":29763},{"name":"NYXL","url":"http:\/\/twitter.com\/search?q=NYXL","promoted_content":null,"query":"NYXL","tweet_volume":null},{"name":"Warriors","url":"http:\/\/twitter.com\/search?q=Warriors","promoted_content":null,"query":"Warriors","tweet_volume":50678},{"name":"Sexiest Man Alive","url":"http:\/\/twitter.com\/search?q=%22Sexiest+Man+Alive%22","promoted_content":null,"query":"%22Sexiest+Man+Alive%22","tweet_volume":15787},{"name":"George Clooney","url":"http:\/\/twitter.com\/search?q=%22George+Clooney%22","promoted_content":null,"query":"%22George+Clooney%22","tweet_volume":null},{"name":"Donyale Luna","url":"http:\/\/twitter.com\/search?q=%22Donyale+Luna%22","promoted_content":null,"query":"%22Donyale+Luna%22","tweet_volume":null},{"name":"Wagon Wednesday","url":"http:\/\/twitter.com\/search?q=%22Wagon+Wednesday%22","promoted_content":null,"query":"%22Wagon+Wednesday%22","tweet_volume":null},{"name":"Challenge Cup","url":"http:\/\/twitter.com\/search?q=%22Challenge+Cup%22","promoted_content":null,"query":"%22Challenge+Cup%22","tweet_volume":null},{"name":"Steamboat Willie","url":"http:\/\/twitter.com\/search?q=%22Steamboat+Willie%22","promoted_content":null,"query":"%22Steamboat+Willie%22","tweet_volume":null},{"name":"Nvidia","url":"http:\/\/twitter.com\/search?q=Nvidia","promoted_content":null,"query":"Nvidia","tweet_volume":null},{"name":"Okoro","url":"http:\/\/twitter.com\/search?q=Okoro","promoted_content":null,"query":"Okoro","tweet_volume":null},{"name":"Patrick Williams","url":"http:\/\/twitter.com\/search?q=%22Patrick+Williams%22","promoted_content":null,"query":"%22Patrick+Williams%22","tweet_volume":null},{"name":"minnie mouse","url":"http:\/\/twitter.com\/search?q=%22minnie+mouse%22","promoted_content":null,"query":"%22minnie+mouse%22","tweet_volume":null},{"name":"Lavine","url":"http:\/\/twitter.com\/search?q=Lavine","promoted_content":null,"query":"Lavine","tweet_volume":null},{"name":"Danish","url":"http:\/\/twitter.com\/search?q=Danish","promoted_content":null,"query":"Danish","tweet_volume":29402}],"as_of":"2020-11-18T16:25:14Z","created_at":"2020-11-17T14:04:14Z","locations":[{"name":"Los Angeles","woeid":2442047}]}]';  
  return TrendAlbum.fromJson(jsonDecode(jobj));


  var response = await http.get('https://api.twitter.com/1.1/trends/place.json?id=2442047', headers: {"Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAADu%2BJgEAAAAAgqy73WFp%2Bnd9pXPCHBym9afDra0%3DnT67LdN67UcbaJtCpOzGbtfjRlMCTgL49E56VdG9gAQ045Rm5F"});
  print("end attempt.");

  if (response.statusCode == 200) {
    print('nope');
    return TrendAlbum.fromJson(jsonDecode(response.body));
  } else if(response.statusCode == 401){
    print('insufficient authorization');
  }
  else {
    print('yep');
    throw Exception('Twitter server failed to respond.');
  }
}
