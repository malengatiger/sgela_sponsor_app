import 'package:flutter/material.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

import '../data/city.dart';
import '../data/country.dart';

class CityList extends StatelessWidget {
  const CityList({super.key, required this.cities, required this.onCityTapped});

  final List<City> cities;
  final Function(City) onCityTapped;

  @override
  Widget build(BuildContext context) {
    cities.sort((a,b) => a.name!.compareTo(b.name!));
    return ListView.builder(
        itemCount: cities.length,
        itemBuilder: (_, index) {
          var city = cities.elementAt(index);
      return GestureDetector(
        onTap: (){
          onCityTapped(city);
        },
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: ListTile(
              title: Text('${city.name}', style: myTextStyleSmall(context),),
              leading: Text('${index+1}', style: myTextStyle(context, Theme.of(context).primaryColor,
                  14, FontWeight.w900),),
            ),
          ),
        ),
      );
    });
  }
}
