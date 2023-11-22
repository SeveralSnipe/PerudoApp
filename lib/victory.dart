import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perudo/models.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';

class Victory extends StatefulWidget {
  const Victory({super.key});

  @override
  State<Victory> createState() => _VictoryState();
}

class _VictoryState extends State<Victory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              canvas: Size.infinite,
              confettiController: ConfettiController(duration: const Duration(seconds: 10)),
              blastDirection: pi / 2,
              maxBlastForce: 5, // set a lower max blast force
              minBlastForce: 2, // set a lower min blast force
              emissionFrequency: 0.05,
              numberOfParticles: 50, // a lot of particles at once
              gravity: 1,
              shouldLoop: true,
            ),
          ),
    ));
  }
}