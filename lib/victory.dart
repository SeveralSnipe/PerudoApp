import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class Victory extends StatefulWidget {
  final String winnerMessage;
  const Victory({super.key, required this.winnerMessage});

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
      child: Stack(children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: ConfettiWidget(
            canvas: Size.infinite,
            confettiController: _confcontroller,
            blastDirection: -pi / 4,
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
            blastDirection: -(3 * pi) / 4,
            maxBlastForce: 30, // set a lower max blast force
            minBlastForce: 10, // set a lower min blast force
            emissionFrequency: 0.02,
            numberOfParticles: 15, // a lot of particles at once
            gravity: 0.1,
            shouldLoop: true,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.winnerMessage,
                textAlign: TextAlign.center,
                softWrap: true,
                style: GoogleFonts.aleo(
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              ElevatedButton(
                  onPressed: ()  {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Return to home",
                    style: GoogleFonts.aleo(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                )
            ],
          ),
        ),
      ]),
    ));
  }
}
