
/**
 * Testing File
 */


class Test {

  void main() {

    /*** Testing MyHomePage ***/

    testWidgets('Testing See History Widget', (WidgetTester tester) async {

      expect(find.byIcon(Icons.query_builder, findsOneWidget);
      await tester.tap(find.byIcon(Icons.query_builder));
      await tester.pump(Duration.zero);

    });

    testWidgets('Testing New Photo Widget', (WidgetTester tester) async {

      expect(find.text('Tap to Take a\nNew Photo', findsOneWidget);
      await tester.tap(find.text('Tap to Take a\nNew Photo'));
      await tester.pump(Duration.zero);


    });
    
    testWidgets('Testing Upload Photo Widget', (WidgetTester tester) async {

      expect(find.text('Tap to Choose\nfrom Gallery', findsOneWidget);
      await tester.tap(find.text('Tap to Choose\nfrom Gallery'));
      await tester.pump(Duration.zero);


    });


    testWidgets('Testing Crop Widget', (WidgetTester tester) async {

      expect(find.byIcon(Icons.crop, findsOneWidget);
      await tester.tap(find.byIcon(Icons.crop));
      await tester.pump(Duration.zero);


    });

    testWidgets('Testing Rotate Widget', (WidgetTester tester) async {

      expect(find.byIcon(Icons.refresh, findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump(Duration.zero);


    });

    testWidgets('Testing Generate Widget', (WidgetTester tester) async {

      await tester.pumpWidget(build);
      expect(find.text('Generate'), findsOneWidget);
      await tester.tap(find.text('Generate'));
      

    });

    test('Test Reset Image Function', ()  {
      final home = MyHomePage()

      home._resetImage();
      expect(home._image, null);
      expect(home._refreshed, true);

    });

    testWidgets('Test that View Hashtag widget appears after generating hashtags', (WidgetTester tester) async {
      final home = MyHomePage()

      home._generateTags();
      await tester.pumpWidget(build);
      expect(find.text('View Hashtags'), findsOneWidget);
      await tester.tap(find.text('View Hashtags'));
      
    });

    /*** Testing HashtagPage Class ***/
    
    testWidgets('Testing Hashtag Display Widget', (WidgetTester tester) async {

      expect(find.byKey(_scaffoldKey, findsOneWidget);
      await tester.tap(find.byKey(_scaffoldKey));
      await tester.pump(Duration.zero);

    });

    testWidgets('Testing Try Another Image Widget', (WidgetTester tester) async {

      expect(find.byIcon(Icons.arrow_back_ios, findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump(Duration.zero);
      

    });

    test('Test Tag Lists Function', ()  {
      final page = _HashtagPageState()

      expect(page.allTags.length, isNot(0));
      expect(page.selectedTags.length, 0);

    });


    /*** Testing HistoryPage Class ***/
    
    testWidgets('Testing Recently Generated Section', (WidgetTester tester) async {

      expect(find.text('  Recently Generated', findsOneWidget);
      await tester.pump(Duration.zero);

    });

    testWidgets('Testing Recent Stats Section', (WidgetTester tester) async {

      expect(find.text('Recent Stats', findsOneWidget);
      await tester.pump(Duration.zero);

    });

    testWidgets('Testing Commonly Generated Tags Section', (WidgetTester tester) async {

      expect(find.text('Commonly Generated Tags', findsOneWidget);
      await tester.pump(Duration.zero);

    });

    testWidgets('Testing Most Unique Tags Section', (WidgetTester tester) async {

      expect(find.text('Most Unique Tags', findsOneWidget);
      await tester.pump(Duration.zero);

    });

  
   /*** Testing Album Class ***/
    
    test('Test fetchSynonyms Function', ()  {
      final album = Album()

      album.fetchSynonyms("happy");
      final response =
        await http.get('https://www.dictionaryapi.com/api/v3/references/thesaurus/json/happy?key=26ac1a83-30e4-4a1f-9631-9a216ec03a33');

      expect(response.statusCode, 200);
      expect(home._refreshed, true);

    });


    test('Test split Function', ()  {
      final album = Album()

      final words = album.split("FunDay");
      
      expect(words.length, 2);
      expect(words[0], "Fun");
      expect(words[1]. "Day")

    });

  }
}
