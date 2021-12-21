import 'questrade.dart';

class AccountPosition {
  final Account account;
  final Position position;
  AccountPosition(this.account, this.position);
}

class PositionSummary {
  final String symbol;
  final num currentPrice;
  final int openQuantity;
  final num openPnl;
  final int accounts;
  final double totalPortfolioValue;

  num get totalValue => openQuantity * currentPrice;
  num get portfolioPercentage => totalValue / totalPortfolioValue * 100;

  PositionSummary({
    required this.symbol,
    required this.currentPrice,
    required this.openQuantity,
    required this.openPnl,
    required this.accounts,
    required this.totalPortfolioValue,
  });
}

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

  var accounts = await Questrade.getAccounts(accessToken);
  print(accounts.toString());
  double portfolioValue = 0.0;

  Map<String, List<AccountPosition>> positionsSummary = {};
  for (var account in accounts) {
    var positions = await Questrade.getPositions(accessToken, account.number);
    for (var position in positions) {
      portfolioValue += position.currentPrice * position.openQuantity;
      var positionSummary = positionsSummary.putIfAbsent(position.symbol, () => []);
      positionSummary.add(AccountPosition(account, position));
    }
  }

  List<PositionSummary> summaries = [];

  for (var accountPositionsList in positionsSummary.values) {
    String symbol = accountPositionsList.first.position.symbol;
    num currentPrice = accountPositionsList.first.position.currentPrice;
    int openQuantity = 0;
    num closedPnl = 0;
    num openPnl = 0;
    int accounts = 0;
    for (var accountPosition in accountPositionsList) {
      var position = accountPosition.position;
      accounts++;
      assert(position.symbol == symbol);
      assert(position.currentPrice == currentPrice);
      openQuantity += position.openQuantity;
      closedPnl += position.closedPnl;
      openPnl += position.openPnl;
    }

    summaries.add(PositionSummary(
      symbol: symbol,
      currentPrice: currentPrice,
      openQuantity: openQuantity,
      openPnl: openPnl,
      accounts: accounts,
      totalPortfolioValue: portfolioValue,
    ));
  }

  summaries.sort((a , b) =>  b.portfolioPercentage.compareTo(a.portfolioPercentage));

  for (var summary in summaries) {
    print("${summary.symbol} currentPrice=${summary.currentPrice} quantity=${summary.openQuantity} openPnl=${summary.openPnl} totalValue=${summary.totalValue} portfolioPecentage=${summary.portfolioPercentage.toStringAsFixed(2)} accounts=${summary.accounts}");
  }
}
