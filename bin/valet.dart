import 'dart:convert';

import 'package:http/http.dart' as http;

/// https://www.bankofcanada.ca/valet/docs
class Valet {
  static Future<double?> getUsdToCadRate() async {
    try {
      var uri = Uri.https(
        'www.bankofcanada.ca',
        '/valet/observations/FXUSDCAD',
        <String, String>{
          'recent': '1',
        },
      );
      var response = await http.get(uri);
      if (response.statusCode != 200) {
        throw "Valet.getCadToUsdRate - http failed with status code = ${response.statusCode}";
      }
      var json = jsonDecode(response.body);
      List<dynamic> observations = json['observations'];
      assert(observations.length == 1);
      var observation = observations.first;
      var v = observation['FXUSDCAD']['v'];

      return double.parse(v);
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
  }
} 