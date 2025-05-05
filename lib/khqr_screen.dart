import 'dart:async';
import 'dart:convert';
import 'dart:developer';


import 'package:aba_payway_bakong_khqr/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:khqr_sdk/khqr_sdk.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lottie/lottie.dart';


class KhqrScreen extends StatefulWidget {
  const KhqrScreen({super.key});

  @override
  State<KhqrScreen> createState() => _KhqrScreenState();
}

class _KhqrScreenState extends State<KhqrScreen> {
  late KhqrSdk _khqrSdk;
  String? khqrContent;
  String? errorMessage;
  var isExpired = false;

  final String _receiverName = 'PHA HOEUN';
  final KhqrCurrency _receiverCurrency = KhqrCurrency.usd;
  final double _amount = 0.01;

  String md5 = '';

  @override
  void initState() {
    _khqrSdk = KhqrSdk();
    super.initState();
    generateIndividual();
  }

  Future<void> generateIndividual() async {
    try {
      final info = IndividualInfo(
        bakongAccountId: 'pha_hoeun@aclb',
        merchantName: _receiverName,
        accountInformation: '0967197975',
        currency: _receiverCurrency,
        amount: _amount,
        expirationTimestamp: getExpirationTimestampMs(),
      );
      final individual = await _khqrSdk.generateIndividual(info);
      setState(() {
        khqrContent = individual?.qr;
        md5 = individual!.md5;
      });
      onCheckTranTime();
    } on PlatformException catch (e) {
      log('Error: ${e.message}');
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  int getExpirationTimestampMs({int minutesAhead = 1}) {
    final expiration = DateTime.now().toUtc().add(
      Duration(minutes: minutesAhead),
    );
    return expiration.millisecondsSinceEpoch;
  }

  Future<void> _checkTransactionStatus() async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImlkIjoiNWRlNmRjNTZmNjU4NGY4YiJ9LCJpYXQiOjE3NDYxNTE1NjIsImV4cCI6MTc1MzkyNzU2Mn0.QPK3x2zP5zCj9Hirf83pIjup7YL_IXMwRaN-wAMWTWI',
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5'),
    );

    request.body = json.encode({"md5": md5});
    request.headers.addAll(headers);
    http.StreamedResponse res = await request.send();

    if (res.statusCode == 200) {
      var status =
          json.decode(await res.stream.bytesToString())['responseMessage'];
      debugPrint("status ----------------->> $status");
      if (status == 'Success') {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessScreen()),
        );
        checkTranTime?.cancel();
      }
    } else {
      debugPrint('error check tran---------------->> ${res.reasonPhrase}');
    }
  }

  Timer? checkTranTime;
  void onCheckTranTime() {
    checkTranTime?.cancel();
    checkTranTime = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkTransactionStatus();
    });
  }

  @override
  void dispose() {
    checkTranTime?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Bakong KHQR'),
      ),
      body:
          errorMessage != null
              ? Center(
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              )
              : khqrContent == null
              ? const Center(child: CircularProgressIndicator())
              : !isExpired
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  KhqrCardWidget(
                    width: 300.0,
                    receiverName: _receiverName,
                    amount: _amount,
                    keepIntegerDecimal: false,
                    currency: _receiverCurrency,
                    qr: khqrContent!,
                    isDark: false,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Expired In', style: TextStyle(color: Colors.red)),
                      Gap(10),
                      TimerCountdown(
                        format: CountDownTimerFormat.minutesSeconds,
                        enableDescriptions: false,
                        timeTextStyle: TextStyle(color: Colors.red),
                        colonsTextStyle: TextStyle(color: Colors.red),
                        spacerWidth: 3,
                        endTime: DateTime.now().add(
                          Duration(minutes: 1, seconds: 0),
                        ),
                        onEnd: () {
                          isExpired = true;
                          checkTranTime?.cancel();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: Text(
                      'Scan with Mobile Banking App Supporting KHQR',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Text(khqrContent!),
                  // ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Lottie.asset(
                        'assets/images/expired_time.json',
                        // repeat: false,
                      ),
                    ),
                    Gap(45),
                    Text(
                      'Session Expired!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Press', style: TextStyle(color: Colors.black)),
                        Gap(5),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Gap(5),
                        Text(
                          'to resume transaction.',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Gap(40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: ElevatedButton(
                        child: Text('Try Again'),
                        onPressed: () {
                          setState(() {
                            generateIndividual();
                            isExpired = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
