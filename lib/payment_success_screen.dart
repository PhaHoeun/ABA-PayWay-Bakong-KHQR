import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'assets/images/pay_success.json',
              ),
            ),
            Gap(60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
