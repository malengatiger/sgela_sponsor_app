import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/city_list.dart';
import 'package:sgela_sponsor_app/ui/country_list.dart';
import 'package:sgela_sponsor_app/ui/widgets/row_content_view.dart';
import 'package:sgela_sponsor_app/util/dark_light_control.dart';

import '../data/city.dart';
import '../data/country.dart';
import '../util/functions.dart';

class CountryCitySelector extends StatefulWidget {
  const CountryCitySelector({super.key});

  @override
  CountryCitySelectorState createState() => CountryCitySelectorState();
}

class CountryCitySelectorState extends State<CountryCitySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  bool busy = false;
  List<Country> _countries = [];
  List<Country> _filteredCountries = [];
  List<City> _cities = [];
  List<City> _filteredCities = [];

  DarkLightControl dlc = GetIt.instance<DarkLightControl>();
  static const String mm = '🥦🥦🥦 CountryCitySelector:  🥦';

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }


  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCountries();
  }

  _getCountries() async {
    pp('$mm ... getting countries ....');
    setState(() {
      busy = true;
    });
    try {
      _countries = await firestoreService.getCountries();
      _filteredCountries.addAll(_countries);
      pp('$mm ... gotten countries : ${_countries.length}');
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    setState(() {
      busy = false;
    });
  }

  _filterCountries(String name) {
    pp('$mm ... filter countries with: $name for ${_countries.length} countries');
    if (name.isEmpty) {
      pp('$mm ... filter name is empty');
      _filteredCountries.clear();
      _filteredCountries.addAll(_countries);
    } else {
      var m = name.toLowerCase();
      _filteredCountries.clear();
      for (var country in _countries) {
        // pp('$mm ... country to filter: ${country.name} - using: $name');
        if (country.name!.toLowerCase().contains(m)) {
          _filteredCountries.add(country);
        }
      }
    }
    setState(() {});
    _dismissKeyboard(context);
  }

  _filterCities(String name) {
    pp('$mm ... filter cities with: $name for ${_cities.length} cities');
    if (name.isEmpty) {
      pp('$mm ... filter name is empty');
      _filteredCities.clear();
      _filteredCities.addAll(_cities);
    } else {
      var m = name.toLowerCase();
      _filteredCities.clear();
      for (var city in _cities) {
        // pp('$mm ... city to filter: ${city.name} - using: $name');
        if (city.name!.toLowerCase().contains(m)) {
          _filteredCities.add(city);
        }
      }
    }
    setState(() {});
    _dismissKeyboard(context);
  }

  bool _showCityList = false;
  City? _selectedCity;

  _getCities(int countryId) async {
    setState(() {
      busy = true;
    });
    try {
      _cities = await firestoreService.getCities(countryId);
      _filteredCities.addAll(_cities);
      pp('$mm ... cities found for country id: $countryId : ${_cities.length}');
      if (_cities.isNotEmpty) {
        _showCityList = true;
      } else {
        _showCityList = false;
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissKeyboard(context);
    super.dispose();
  }

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var b = MediaQuery.of(context).platformBrightness;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Country City Selector',
              style: myTextStyleMediumLarge(context, 20),
            ),
            gapW16,
            busy
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.pink,
                    ),
                  )
                : gapW16,
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                pp('$mm ... dark/light pressed, Brightness: ${b.name}');
                if (b == Brightness.light) {
                  dlc.setDarkMode();
                } else {
                  dlc.setLightMode();
                }
                setState(() {});
              },
              icon: b == Brightness.light
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode))
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Column(
            children: [],
          ),
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  gapH16,
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28),
                    child: SearchBar(
                      controller: _textEditingController,
                      hintText: _showCityList?'Search Cities/Towns' : 'Search countries',
                      onChanged: (c) {
                        pp('$mm onChanged, will filter: ${_textEditingController.text}');
                        if (_textEditingController.text.length > 2) {
                          if (_showCityList) {
                            _filterCities(_textEditingController.text);
                          } else {
                            _filterCountries(_textEditingController.text);
                          }
                        }
                      },
                      onSubmitted: (s) {
                        pp('$mm ... onSub: $s');
                      },
                      elevation: const MaterialStatePropertyAll(8.0),
                      leading: const Icon(Icons.search),
                    ),
                  ),
                  gapH32,
                  _showCityList
                      ? Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 28.0, right: 28),
                            child: bd.Badge(
                              badgeContent: Text('${_filteredCities.length}'),
                              child: CityList(
                                cities: _filteredCities,
                                onCityTapped: (c) {
                                  pp('$mm .... city tapped: ${c.name}');
                                  setState(() {
                                    _selectedCity = c;
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 28.0, right: 28),
                            child: bd.Badge(
                              badgeContent:
                                  Text('${_filteredCountries.length}'),
                              child: CountryList(
                                countries: _filteredCountries,
                                onCountryTapped: (c) {
                                  pp('$mm .... country tapped: ${c.name}');
                                  _getCities(c.id!);
                                },
                                showAsGrid: true,
                              ),
                            ),
                          ),
                        ),
                  _selectedCity == null
                      ? gapW16
                      : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(width: 420,
                          child: Card(
                              elevation: 16,
                              child: Column(
                                children: [
                                  gapH8,
                                  const Text('City/Town Selected'),
                                  gapH8,
                                  Padding(
                                    padding: const EdgeInsets.only(left:16.0,right: 16.0, top: 8, bottom: 8),
                                    child: Text(
                                      '${_selectedCity!.name}',
                                      style: myTextStyle(
                                          context,
                                          Theme.of(context).primaryColor,
                                          16,
                                          FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      )
                ],
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return Stack(
            children: [
              RowContentView(
                  leftWidget: CountryList(
                    showAsGrid: true,
                    countries: _countries,
                    onCountryTapped: (country) {
                      pp('$mm country tapped: ${country.name}');
                      _getCities(country.id!);
                    },
                  ),
                  rightWidget: CityList(
                      cities: _cities,
                      onCityTapped: (city) {
                        pp('$mm( city tapped: ${city.name})');
                      }))
            ],
          );
        },
      ),
    ));
  }
}
