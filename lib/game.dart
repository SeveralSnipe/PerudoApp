import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perudo/models.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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
  final Map<dynamic, dynamic> initData;
  const Game(
      {super.key,
      required this.lobbyCode,
      required this.leadername,
      required this.playername,
      required this.initData});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => GameProvider(widget.lobbyCode, widget.initData),
        child: Scaffold(body: Consumer<GameProvider>(
            builder: (context, myDatabaseProvider, child) {
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.yellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 200,
                  alignment: Alignment.topCenter,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: myDatabaseProvider.data['count'],
                    itemBuilder: (context, index) {
                      for (var player
                          in myDatabaseProvider.data['players'].keys) {
                        if (myDatabaseProvider.data['players'][player]
                                ['order'] ==
                            index + 1) {
                          return Center(
                              child: Text(
                            '$player',
                            style: TextStyle(
                                color: player == widget.playername
                                    ? Colors.blue
                                    : Colors.black,
                                fontSize: 16),
                          ));
                        }
                      }
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 7,
                        height: 1,
                      );
                    },
                  ),
                ),
                // ListView.builder(
                //   scrollDirection: Axis.horizontal,
                //   shrinkWrap: true,
                //   itemCount: 6,
                //   itemBuilder: (context, index) {
                //     String imgPath = dices[index]!;
                //     return Center(
                //       child: Image.asset(
                //         imgPath,
                //         scale: 8,
                //         color: Colors.red,
                //       ),
                //     );
                //   },
                // ),
                CircularCountDownTimer(
                  width: 100,
                  height: 200,
                  duration: 60,
                  fillColor: Colors.green.shade400,
                  ringColor: Colors.green.shade200,
                  isReverse: true,
                  isReverseAnimation: true,
                  backgroundColor: Colors.green.shade400,
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  strokeWidth: 7,
                  onComplete: widget.playername == widget.leadername ? myDatabaseProvider.leaderTimerExpire : myDatabaseProvider.dummy,
                )
              ],
            ),
          );
        })));
  }
}
