import 'dart:convert';
import 'dart:io';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/models/requests/charge_card/validate_charge_request.dart';
import 'package:flutterwave/models/requests/verify_charge_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/models/responses/get_bank/get_bank_response.dart';
import 'package:flutterwave/models/responses/resolve_account/resolve_account_response.dart';
import 'package:flutterwave/utils/flutterwave_utils.dart';
import 'package:http/http.dart' as http;

class FlutterwaveAPIUtils {
  static Future<List<GetBanksResponse>> getBanks(
      final http.Client client) async {
    try {
      final response = await client.get(
        FlutterwaveUtils.GET_BANKS_URL,
      );
      if (response.statusCode == 200) {
        print("banks is ${jsonDecode(response.body).runtimeType}");
        final List<dynamic> jsonDecoded = jsonDecode(response.body);
        final banks =
            jsonDecoded.map((json) => GetBanksResponse.fromJson(json)).toList();

        return banks;
      } else {
        throw (FlutterWaveError("Unable to fetch banks. Please contact support"));
      }
    } catch (error) {
      throw (FlutterWaveError(error.toString()));
    } finally {
      client.close();
    }
  }

  static Future<ResolveAccountResponse> resolveAccount(
      final http.Client client) async {
    try {
      final response = await client.get(FlutterwaveUtils.GET_BANKS_URL);
      final ResolveAccountResponse resolveAccountResponse =
          jsonDecode(response.body);
      return resolveAccountResponse;
    } catch (error) {
      throw (FlutterWaveError(error.toString()));
    } finally {
      client.close();
    }
  }

  static Future<ChargeResponse> validatePayment(
      String otp, String flwRef, http.Client client, final bool isDebugMode, final String publicKey, final isBankAccount) async {
    final url = FlutterwaveUtils.getBaseUrl(isDebugMode) + FlutterwaveUtils.VALIDATE_CHARGE;
    final ValidateChargeRequest chargeRequest =
    ValidateChargeRequest(otp, flwRef, isBankAccount);
    final payload = chargeRequest.toJson();
    print("validate payload is ${payload}");
    try {
      final http.Response response = await client.post(url,
          headers: {HttpHeaders.authorizationHeader: publicKey},
          body: payload);

      final ChargeResponse cardResponse =
      ChargeResponse.fromJson(jsonDecode(response.body));
      return cardResponse;
    } catch (error) {
      throw (FlutterWaveError(error.toString()));
    }
  }

  static Future<ChargeResponse> verifyPayment(
      final String flwRef,
      final http.Client client,
      final String publicKey,
      final bool isDebugMode) async {
    final url = FlutterwaveUtils.getBaseUrl(isDebugMode) +
        FlutterwaveUtils.VERIFY_TRANSACTION;
    final VerifyChargeRequest verifyRequest = VerifyChargeRequest(flwRef);
    final payload = verifyRequest.toJson();
    try {
      final http.Response response = await client.post(url,
          headers: {HttpHeaders.authorizationHeader: publicKey}, body: payload);

      final ChargeResponse cardResponse =
          ChargeResponse.fromJson(jsonDecode(response.body));
      return cardResponse;
    } catch (error, stacktrace) {
      print(stacktrace);
      throw (FlutterWaveError(error.toString()));
    } 
  }
}
