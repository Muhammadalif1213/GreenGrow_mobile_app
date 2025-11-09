import 'package:flutter/material.dart';
import 'package:greengrow_app/presentation/pages/map/greenhouse_map_screen.dart';

class Routes {
  static const String greenhouseMap = '/greenhouse-map';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      greenhouseMap: (context) => const GreenhouseMapScreen(),
    };
  }
}
