import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perudo/models.dart';
import 'package:provider/provider.dart';

import 'utils.dart';

const Map<int, String> dices = {
  0: "assets/images/dice-six-faces-one.png",
  1: "assets/images/dice-six-faces-two.png",
  2: "assets/images/dice-six-faces-three.png",
  3: "assets/images/dice-six-faces-four.png",
  4: "assets/images/dice-six-faces-five.png",
  5: "assets/images/dice-six-faces-six.png",
};

class Game extends StatefulWidget {
  final String lobbyCode;
  final String leadername;
  final String playername;
  const Game(
      {super.key,
      required this.lobbyCode,
      required this.leadername,
      required this.playername});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
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
            child: Center(
              child: Column(
                children: [
                  FutureBuilder(
                      future: player(widget.lobbyCode),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: snapshot.data!['count'],
                              itemBuilder: (context, index) {
                                
                              });
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      String imgPath = dices[index]!;
                      return Center(
                        child: Image.asset(
                          imgPath,
                          scale: 8,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
