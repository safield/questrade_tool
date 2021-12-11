import 'dart:convert';

import 'package:http/http.dart' as http;

class AccessToken {
  final String token;
  final String refreshToken;
  final int expiredTime;
  AccessToken(this.token , this.refreshToken , this.expiredTime);

  static AccessToken fromJson(Map<String,dynamic> json) {
    return AccessToken(json['access_token'] , json['refresh_token'] , json['expired_time']);
  }

  Map<String , dynamic> toJson() {
    return {
      "access_token": token,
      "refresh_token": refreshToken,
      "expired_time": expiredTime.toString(),
    };
  }
}

enum AccountType {
  Cash,	// Cash account.
  Margin,	// Margin account.
  TFSA,	// Tax Free Savings Account.
  RRSP,	// Registered Retirement Savings Plan.
  SRRSP,	// Spousal RRSP.
  LRRSP,	// Locked-In RRSP.
  LIRA,	// Locked-In Retirement Account.
  LIF,	// Life Income Fund.
  RIF,	// Retirement Income Fund.
  SRIF,	// Spousal RIF.
  LRIF,	// Locked-In RIF.
  RRIF,	// Registered RIF.
  PRIF,	// Prescribed RIF.
  RESP,	// Individual Registered Education Savings Plan.
  FRESP, // Family RESP.	
}

class Account {
  final AccountType type;
  Account(this.type);
  factory Account.fromJson(Map<String,dynamic> json) {
    var map = AccountType.values.asNameMap();
    var type = map[json['type']];
    return Account(type!);
  }
}

class Questrade {
    static Future<AccessToken> getAccessToken(String refreshToken) async {
      // var uri = Uri.parse("https://login.questrade.com/oauth2/token?grant_type=refresh_token&refresh_token=$refreshToken");
      var uri = Uri.https(
        'login.questrade.com',
        '/oauth2/token',
        <String, String>{
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );
      var response = await http.get(uri);
      var json = jsonDecode(response.body);
      return AccessToken.fromJson(json);
    }

    static Future<List<Account>> getAccounts(AccessToken accessToken) async {
        var headers = { "Authorization": "Bearer: ${accessToken.token}"};
        var uri = Uri.https("api01.iq.questrade.com", "/v1/accounts");
        var response = await http.get(uri);
        var json = jsonDecode(response.body);
        AccountType
        return [];
    }
}


