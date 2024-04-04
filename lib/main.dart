import 'package:flutter/material.dart';
import 'package:web_api_3c/screens/register.dart';

void main() {
  runApp(const WebApi());
}

class WebApi extends StatelessWidget {
  const WebApi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}
