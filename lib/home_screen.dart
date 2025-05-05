import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aba_payway_bakong_khqr/custom_alert_dialog.dart';
import 'package:aba_payway_bakong_khqr/khqr_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    //aba
    WidgetsBinding.instance.addObserver(this);
  }

  //  --------------------------------------------------------------
  //  TASK: ABA PayWay
  //  Responsible By: Hoeun Pha
  //  --------------------------------------------------------------
  bool launched = false;
  @override
  void dispose() {
    //aba
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //aba
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && launched) {
      // 🎯 You have returned from ABA app
      debugPrint("Returned from ABA App");
      getTransactionDetail();
    }
  }

  //get transaction detail
  var tranId = '';
  Future<void> getTransactionDetail() async {
    final reqTime = DateTime.now().millisecondsSinceEpoch.toString();
    final hashString = '$reqTime$merchantId$tranId';
    final hash = getHash(hashString);

    final response = await http.post(
      Uri.parse(
        'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/transaction-detail',
      ),
      body: {
        "req_time": reqTime,
        "merchant_id": merchantId,
        "tran_id": tranId,
        "hash": hash,
      },
    );

    if (response.statusCode == 200) {
      debugPrint(
        'successfull get tran detail ${jsonDecode(response.body)['data']}',
      );
      customAlertDialog(
        // ignore: use_build_context_synchronously
        context,
        title: 'Payment',
        description:
            'Payment is ${jsonDecode(response.body)['data']['payment_status']}',
        primaryButton: () {
          Navigator.pop(context);
          setState(() {
            launched = false;
          });
        },
        secondaryButton: () {
          Navigator.pop(context);
          setState(() {
            launched = false;
          });
        },
      );
    } else {
      debugPrint('fail to get tran detail');
    }
  }

  //api url, api key, merchant id
  final controller = TextEditingController();
  final String apiUrl =
      'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase';
  final String apiKey = '9a36f6e62619dc372cc87e852f945c19690023f6';
  final String merchantId = 'ec438964';

  //hast data
  String getHash(String str) {
    final key = utf8.encode(apiKey);
    final bytes = utf8.encode(str);
    final hmacSha512 = Hmac(sha512, key);
    final digest = hmacSha512.convert(bytes);
    return base64Encode(digest.bytes);
  }

  //on check out
  Future<void> checkOut() async {
    final transactionId =
        DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    const amount = '15.00';
    var firstName = 'Pha';
    var lastName = 'Hoeun';
    var phone = '0967197975';
    var email = 'phahoeun5@gmail.com';

    //items data
    final itemData = [
      {'name': 'test1', 'quantity': '1', 'price': '10.00'},
      {'name': 'test2', 'quantity': '1', 'price': '10.00'},
    ];

    //convert items data to JSON string
    final jsonString = jsonEncode(itemData);

    //convert JSON String to bytes
    final bytes = utf8.encode(jsonString);

    //encode bytes to Base64
    final items = base64Encode(bytes);

    const shipping = '0.60';
    const returnParams = 'Hello World';
    const type = 'purchase';
    const currency = 'USD';
    const paymentOption = 'abapay_deeplink';

    final reqTime = formatDateTimeToYYYYMMDDHHmmss(DateTime.now().toUtc());
    final hashString =
        '$reqTime$merchantId$transactionId$amount$items$shipping$firstName$lastName$email$phone$type$paymentOption$currency$returnParams';
    final hash = getHash(hashString);

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'hash': hash,
        'tran_id': transactionId,
        'amount': amount,
        'firstname': firstName,
        'lastname': lastName,
        'phone': phone,
        'email': email,
        'items': items,
        'return_params': returnParams,
        'shipping': shipping,
        'currency': currency,
        'type': type,
        'merchant_id': merchantId,
        'req_time': reqTime,
        'payment_option': paymentOption,
      },
    );

    if (response.statusCode == 200) {
      //Handle successful response
      debugPrint('Payment request sent successully');
      tranId = jsonDecode(response.body)['status']['tran_id'];

      //you can call the deep link function here if neede
      openDeepLink(jsonDecode(response.body)['abapay_deeplink']);
    } else {
      debugPrint('Failed to send payment request');
    }
  }

  //route to aba app
  Future<void> openDeepLink(String deeplink) async {
    try {
      if (!await canLaunchUrl(Uri.parse(deeplink))) {
        await launchUrl(Uri.parse(deeplink));
        setState(() {
          launched = true;
        });
      } else {
        const playStoreUrl =
            'https://play.google.come/store/apps/details?id=com.paygo24.ibank';
        const appStore =
            'https://itunes.apple.com/al/app/aba-mobile-bank/id968860649?mt=8';
        if (Platform.isAndroid) {
          await launchUrl(Uri.parse(playStoreUrl));
        } else if (Platform.isIOS) {
          await launchUrl(Uri.parse(appStore));
        }
      }
    } catch (e) {
      debugPrint('Error ==========================>>>: $e');
    }
  }

  //format request time
  String formatDateTimeToYYYYMMDDHHmmss(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  //  --------------------------------------------------------------
  //  TASK: End ABA PayWay
  //  Responsible By: Hoeun Pha
  //  --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                checkOut();
              },
              child: Text('ABA Pay'),
            ),
            Gap(15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KhqrScreen()),
                );
              },
              child: Text('Bakong KHQR'),
            ),
          ],
        ),
      ),
    );
  }
}
