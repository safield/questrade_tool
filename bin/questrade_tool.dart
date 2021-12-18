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

  var accounts =  await Questrade.getAccounts(accessToken);
  print(accounts.toString());

  List<Position> positions = [];
  for (var account in accounts) {
    var accountsPositions =  await Questrade.getPositions(accessToken , account.number);
    positions.addAll(accountsPositions);
  }

  for (var position in positions) {
    print(position);
  }
}


