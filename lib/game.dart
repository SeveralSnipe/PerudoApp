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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
        create: (context) => GameProvider(widget.lobbyCode, widget.initData),
        child: Scaffold(body:
            Consumer<GameProvider>(builder: (context, gameProvider, child) {
          return Container(
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
                  height: 0.15*height,
                  alignment: Alignment.topCenter,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: gameProvider.data['count'],
                    itemBuilder: (context, index) {
                      for (var player in gameProvider.data['players'].keys) {
                        if (gameProvider.data['players'][player]['order'] ==
                            index + 1) {
                          return Center(
                              child: Text(
                            '$player',
                            style: GoogleFonts.aleo(
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
                Padding(padding: EdgeInsets.symmetric(horizontal: double.infinity, vertical: 0.07*height)),
                Text(
                    gameProvider.message,
                    style: GoogleFonts.aleo(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                Padding(padding: EdgeInsets.symmetric(horizontal: double.infinity, vertical: 0.05*height)),
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
                  width: 0.25*width,
                  height: 0.15*height,
                  duration: 60,
                  controller: gameProvider.timercontroller,
                  fillColor: Colors.green.shade400,
                  ringColor: Colors.green.shade200,
                  isReverse: true,
                  isReverseAnimation: true,
                  backgroundColor: Colors.green.shade400,
                  textStyle:
                      GoogleFonts.aleo(color: Colors.black87, fontSize: 16),
                  strokeWidth: 7,
                  onComplete: widget.playername == widget.leadername
                      ? gameProvider.leaderTimerExpire
                      : gameProvider.dummy,
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: double.infinity, vertical: 0.02*height)),
                gameProvider.message != "5 second break" ? ElevatedButton(
                  onPressed: gameProvider.callCalza,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Call Calza",
                    style: GoogleFonts.aleo(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ): const Padding(padding: EdgeInsets.all(0)),
                Container(alignment: Alignment.bottomCenter, height: 0.1*height, color: Colors.blueGrey,)
              ],
            ),
          );
        })));
  }
}
