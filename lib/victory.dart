import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class Victory extends StatefulWidget {
  const Victory({super.key});

  @override
  State<Victory> createState() => _VictoryState();
}

class _VictoryState extends State<Victory> {
  late ConfettiController _confcontroller;

  @override
  void initState() {
    super.initState();
    _confcontroller = ConfettiController(duration: const Duration(seconds: 10));
    _confcontroller.play();
  }
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
                  child: Stack(
                    children: [Align(
                                alignment: Alignment.bottomLeft,
                                child: ConfettiWidget(
                                  canvas: Size.infinite,
                                  confettiController: _confcontroller,
                                  blastDirection: -pi/4,
                                  maxBlastForce: 30, // set a lower max blast force
                                  minBlastForce: 10, // set a lower min blast force
                                  emissionFrequency: 0.02,
                                  numberOfParticles: 15, // a lot of particles at once
                                  gravity: 0.1,
                                  shouldLoop: true,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ConfettiWidget(
                                  canvas: Size.infinite,
                                  confettiController: _confcontroller,
                                  blastDirection: -(3*pi)/4,
                                  maxBlastForce: 30, // set a lower max blast force
                                  minBlastForce: 10, // set a lower min blast force
                                  emissionFrequency: 0.02,
                                  numberOfParticles: 15, // a lot of particles at once
                                  gravity: 0.1,
                                  shouldLoop: true,
                                ),
                              ),
                              // Align(
                              //   alignment: Alignment.topLeft,
                              //   child: ConfettiWidget(
                              //     canvas: Size.infinite,
                              //     confettiController: _confcontroller,
                              //     blastDirection: pi/4,
                              //     maxBlastForce: 30, // set a lower max blast force
                              //     minBlastForce: 10, // set a lower min blast force
                              //     emissionFrequency: 0.02,
                              //     numberOfParticles: 15, // a lot of particles at once
                              //     gravity: 0.1,
                              //     shouldLoop: true,
                              //   ),
                              // ),
                              // Align(
                              //   alignment: Alignment.topRight,
                              //   child: ConfettiWidget(
                              //     canvas: Size.infinite,
                              //     confettiController: _confcontroller,
                              //     blastDirection: (3*pi)/4,
                              //     maxBlastForce: 30, // set a lower max blast force
                              //     minBlastForce: 10, // set a lower min blast force
                              //     emissionFrequency: 0.02,
                              //     numberOfParticles: 15, // a lot of particles at once
                              //     gravity: 0.1,
                              //     shouldLoop: true,
                              //   ),
                              // ),
                              ]
                  ),
    ));
  }
}