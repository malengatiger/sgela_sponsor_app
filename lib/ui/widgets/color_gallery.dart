import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_services/sgela_util/dark_light_control.dart';

import '../../util/functions.dart';
import '../../util/prefs.dart';

class ColorGallery extends StatefulWidget {
  const ColorGallery(
      {super.key, required this.prefs, required this.colorWatcher});

  final SponsorPrefs prefs;
  final ColorWatcher colorWatcher;

  @override
  ColorGalleryState createState() => ColorGalleryState();
}

class ColorGalleryState extends State<ColorGallery> {
  Color? selectedColor;
  List<Color> colors = [];
  DarkLightControl darkLightControl = GetIt.instance<DarkLightControl>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();

  @override
  void initState() {
    super.initState();
    colors = getColors();
    ppx('colors available: ${colors.length}');
    _getMode();
  }

  _getMode() {
    mode = prefs.getMode();
    colorIndex = prefs.getColorIndex();
  }
  void _setColorIndex(int index) {
    widget.prefs.saveColorIndex(index);
    widget.colorWatcher.setColor(index);
    prefs.saveColorIndex(index);

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pop(index);
    });
  }

  int mode = 0;
  int colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Primary Colour',
              style: mode == LIGHT? myTextStyle(
                  context, Theme.of(context).primaryColor, 18, FontWeight.bold): myTextStyleMedium(context),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      gapH16,
                      Text(
                        'Tap to select your app\'s colour',
                        style: mode == LIGHT? myTextStyle(
                            context,
                            Theme.of(context).primaryColor,
                            16,
                            FontWeight.bold) : myTextStyleMedium(context),
                      ),
                      gapH16,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemCount: colors.length,
                              itemBuilder: (_, index) {
                                var color = colors.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = color;
                                      _setColorIndex(index);
                                    });
                                  },
                                  child: Container(
                                    color: color,
                                    margin: const EdgeInsets.all(8),
                                    child: selectedColor == color
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                );
                              }),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RadioMenuButton(
                                value: 0,
                                groupValue: groupValue,
                                onChanged: (c) {
                                  ppx('on DARK radio changed c:$c');
                                  _setMode(c!);
                                },
                                child: const Text('Dark Mode')),
                            RadioMenuButton(
                                value: 1,
                                groupValue: groupValue,
                                onChanged: (c) {
                                  ppx('on LIGHT radio changed c:$c');
                                  _setMode(c!);
                                },
                                child: const Text('Light Mode')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  int groupValue = -1;

  void _setMode(int c) {
    ppx('...mode is $c');
    if (c == 0) {
      darkLightControl.setDarkMode();
    } else {
      darkLightControl.setLightMode();
    }
    prefs.saveMode(c);
    setState(() {
      groupValue = c;
      mode = c;
    });
  }
}
