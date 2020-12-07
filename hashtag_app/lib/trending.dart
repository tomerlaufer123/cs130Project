import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'api_call.dart';

/**
* This Page Route displays the list of trending hashtags, fetched via Twitter API call
**/
class TrendPage extends StatelessWidget {
  static const routeName = '/trendinglist';
  Album trends; //type error caused by function returning Future<Album> type

  @override
  TrendPage({this.trends});

  Widget build(BuildContext context) {
    List<Trend> trendList = trends.trends;

    return Scaffold(
        appBar: AppBar(title: Text("Currently Trending on Twitter")),
        body: trendList == null
            ? Center(child: Text('nothing fetched'))
            : Scrollbar(
                child: ListView.builder(
                    itemCount: trendList.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: EdgeInsets.only(
                              top: 5.0, bottom: 4.0, left: 9.0, right: 9.0),
                          color: const Color(0xffe0e0e0),
                          child: ListTile(
                            leading: Icon(Icons.local_fire_department_outlined,
                                color: Colors.pink, size: 40),
                            title: Text(
                              '#${trendList[index].name}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text('Frequency: ${trendList[index].volume}'),
                            //dense: true,
                            //isThreeLine: true,
                          ));
                    })));
  }
}
