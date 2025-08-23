import 'package:flutter/material.dart';

class Logo extends StatelessWidget {

  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(196, 196, 196, 0.25),
            offset: Offset(0, 2),
            blurRadius: 12.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Image.asset("assets/images/logo.png" , height: 80,),
    );
  }
}
