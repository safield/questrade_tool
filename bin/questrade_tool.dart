import 'package:shared_preferences/shared_preferences.dart';

import 'questrade.dart';

void main(List<String> arguments) async {

  if (arguments.length != 1) {
    print("ERROR: expecting a single argument that contains the refresh token");
  }
  var accessToken = await Questrade.getAccessToken(arguments[0]);
  var newRefreshToken = accessToken.refreshToken;

  print("New Refresh Token:");
  print(newRefreshToken);
  print("complete!");
}


