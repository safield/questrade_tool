import 'questrade.dart';
import 'valet.dart';

class AccountPosition {
  final Account account;
  final Position position;
  final bool isUSD;
  AccountPosition(this.account, this.position , this.isUSD);
}

class PositionSummary {
  final String symbol;
  final num currentPriceInCAD;
  final int openQuantity;
  final num openPnl;
  final int accounts;
  final double totalPortfolioValue;

  num get totalValue => openQuantity * currentPriceInCAD;
  num get portfolioPercentage => totalValue / totalPortfolioValue * 100;

  PositionSummary({
    required this.symbol,
    required this.currentPriceInCAD,
    required this.openQuantity,
    required this.openPnl,
    required this.accounts,
    required this.totalPortfolioValue,
  });
}

String fmtMny(num value) {
  return "\$${value.toStringAsFixed(2)}";
}

void main(List<String> arguments) async {
  var usdToCadRate = await Valet.getUsdToCadRate();
  print("USD to CAD = $usdToCadRate");
  if (arguments.length != 1) {
    print("ERROR: expecting a single argument that contains the refresh token");
  }
  var refreshToken = arguments[0];
  var accessToken = await Questrade.getAccessToken(refreshToken);
  var newRefreshToken = accessToken.refreshToken;

  print("New Refresh Token:");
  print(newRefreshToken+'\n');

  var accounts = await Questrade.getAccounts(accessToken);
  double portfolioValue = 0.0;
  num totalValue = 0;
  num totalEquity = 0;
  num totalCash = 0;


  Map<String, List<AccountPosition>> positionsSummary = {};
  for (var account in accounts) {
    var balances = await Questrade.getCombinedBalances(accessToken , account.number);
    var cadBalance = balances.firstWhere((element) => element.currency == Currency.CAD);
    var totalAccountValue = cadBalance.cash + cadBalance.marketValue;
    print("${account.type} Cash:${fmtMny(cadBalance.cash)} Equity:${fmtMny(cadBalance.marketValue)} Total:${fmtMny(totalAccountValue)}");
    totalValue += totalAccountValue;
    totalEquity += cadBalance.marketValue;
    totalCash += cadBalance.cash;

    var positions = await Questrade.getPositions(accessToken, account.number);
    for (var position in positions) {
      var positionSummary = positionsSummary.putIfAbsent(position.symbol, () => []);
      var symbol = await Questrade.getSymbol(accessToken, position.symbolId);
      var isUSD = symbol.currency == "USD";
      var fxRate = isUSD ? usdToCadRate : 1.0;
      portfolioValue += position.currentPrice * fxRate * position.openQuantity;
      positionSummary.add(AccountPosition(account, position , isUSD));
    }
  }

  print("Total cash: ${fmtMny(totalCash)}");
  print("Total equity: ${fmtMny(totalEquity)}");
  print("Total value: ${fmtMny(totalValue)}\n");

  List<PositionSummary> summaries = [];

  for (var accountPositionsList in positionsSummary.values) {
    String symbol = accountPositionsList.first.position.symbol;
    num currentPrice = accountPositionsList.first.position.currentPrice;
    int openQuantity = 0;
    num openPnl = 0;
    int accounts = 0;
    for (var accountPosition in accountPositionsList) {
      var position = accountPosition.position;
      accounts++;
      assert(position.symbol == symbol);
      assert(position.currentPrice == currentPrice);
      openQuantity += position.openQuantity;
      openPnl += position.openPnl;
    }

    var fxRate = accountPositionsList.first.isUSD ? usdToCadRate : 1.0;

    summaries.add(PositionSummary(
      symbol: symbol,
      currentPriceInCAD: currentPrice * fxRate,
      openQuantity: openQuantity,
      openPnl: openPnl,
      accounts: accounts,
      totalPortfolioValue: portfolioValue,
    ));
  }

  summaries.sort((a , b) =>  b.portfolioPercentage.compareTo(a.portfolioPercentage));

  print("Calculated total equity via real time exchange rate: ${fmtMny(portfolioValue)}");

  for (var summary in summaries) {
    print("${summary.symbol} ${summary.portfolioPercentage.toStringAsFixed(2)}%");
  }
  print("");
  for (var summary in summaries) {
    print("${summary.symbol} currentPrice=${summary.currentPriceInCAD} quantity=${summary.openQuantity} openPnl=${summary.openPnl.toStringAsFixed(2)} totalValue=${summary.totalValue.toStringAsFixed(2)} portfolioPecentage=${summary.portfolioPercentage.toStringAsFixed(2)} accounts=${summary.accounts}");
  }
}
