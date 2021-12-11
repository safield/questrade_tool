import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'questrade.dart';

void main(List<String> arguments) async {

  var accessToken = await Questrade.getAccessToken("");

  var headers = { "Authorization": "Bearer: ${accessToken.token}"};
  var uri = Uri.https("api01.iq.questrade.com", "/v1/accounts");

  var response = await http.get(uri , headers: headers);
  print(response);
}


