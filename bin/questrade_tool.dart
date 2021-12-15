import 'questrade.dart';

void main(List<String> arguments) async {

  if (arguments.length != 1) {
    print("ERROR: expecting a single argument that contains the refresh token");
  }
  var refreshToken = arguments[0];
  var accessToken = await Questrade.getAccessToken(refreshToken);
  var newRefreshToken = accessToken.refreshToken;

  print("New Refresh Token:");
  print(newRefreshToken);
  print("complete!");
}


