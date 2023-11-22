import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perudo/models.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'utils.dart';

const Map<int, String> dices = {
  1: "assets/images/dice-six-faces-one.png",
  2: "assets/images/dice-six-faces-two.png",
  3: "assets/images/dice-six-faces-three.png",
  4: "assets/images/dice-six-faces-four.png",
  5: "assets/images/dice-six-faces-five.png",
  6: "assets/images/dice-six-faces-six.png",
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
        create: (context) => GameProvider(widget.lobbyCode, widget.initData,
            widget.leadername == widget.playername, widget.playername),
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
                  height: 0.1 * height,
                  alignment: Alignment.topCenter,
                  color: const Color.fromARGB(125, 255, 255, 255),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: gameProvider.data['count'],
                    itemBuilder: (context, index) {
                      for (var player in gameProvider.data['players'].keys) {
                        if (gameProvider.data['players'][player]['order'] ==
                            index + 1) {
                          return Container(
                            decoration: (gameProvider.data['player_turn'] ==
                        gameProvider.data['players'][player]['order']) ? const BoxDecoration(backgroundBlendMode: BlendMode.darken, gradient: RadialGradient(colors: [Colors.green, Colors.white])) : null,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$player',
                                    style: GoogleFonts.aleo(
                                        color: player == widget.playername
                                            ? Colors.blue
                                            : Colors.black,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'Dice: ${gameProvider.data['players'][player]['dice_count']}',
                                    style: GoogleFonts.aleo(
                                        color: player == widget.playername
                                            ? Colors.blue
                                            : Colors.black,
                                        fontSize: 16),
                                  )
                                ]),
                          );
                        }
                      }
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 7,
                        height: 2,
                      );
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: double.infinity, vertical: 0.03 * height)),
                Text(
                  gameProvider.data['message'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aleo(
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: double.infinity, vertical: 0.03 * height)),
                (gameProvider.data['player_turn'] ==
                        gameProvider.data['players'][widget.playername]['order']) && !(gameProvider.compulsoryChallenge) && !(gameProvider.data['break'])
                    ? Expanded(
                        child: Row(children: [
                          Expanded(
                            child: CarouselSlider(
                                  carouselController:
                                      gameProvider.faceController,
                                  options: CarouselOptions(
                                    height: 0.1 * height,
                                    scrollDirection: Axis.vertical,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.5,
                                    viewportFraction: 0.7,
                                    enableInfiniteScroll: false,
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    onPageChanged: (index, reason) {
                                      gameProvider.changedFace(index);
                                    },
                                  ),
                                  items: gameProvider.faces.map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            alignment: Alignment.center,
                                            width: 0.2 * width,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Text(
                                              '$i',
                                              style:
                                                  const TextStyle(fontSize: 23),
                                            ));
                                      },
                                    );
                                  }).toList(),
                                )),
                              
                            
                          Expanded(
                            child: CarouselSlider(
                                  carouselController:
                                      gameProvider.numberController,
                                  options: CarouselOptions(
                                    height: 0.1 * height,
                                    scrollDirection: Axis.vertical,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.5,
                                    viewportFraction: 0.7,
                                    enableInfiniteScroll: false,
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    onPageChanged: (index, reason) {
                                      gameProvider.changedNumber(index);
                                    },
                                  ),
                                  items: gameProvider.numbers.map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            alignment: Alignment.center,
                                            width: 0.2 * width,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Text(
                                              '$i',
                                              style:
                                                  const TextStyle(fontSize: 23),
                                            ));
                                      },
                                    );
                                  }).toList(),
                                )
                            ),
                          
                        ]),
                      )
                    : const Padding(padding: EdgeInsets.all(0)),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: double.infinity, vertical: 0.05 * height)),
                CircularCountDownTimer(
                  width: 0.25 * width,
                  height: 0.15 * height,
                  duration: 60,
                  controller: gameProvider.timercontroller,
                  fillColor: Colors.orange.shade400,
                  ringColor: Colors.orange.shade200,
                  isReverse: true,
                  isReverseAnimation: true,
                  backgroundColor: Colors.orange.shade400,
                  textStyle: GoogleFonts.luckiestGuy(
                      color: Colors.black87, fontSize: 16),
                  strokeWidth: 7,
                  onComplete: widget.playername == widget.leadername
                      ? gameProvider.leaderTimerExpire
                      : gameProvider.dummy,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: double.infinity, vertical: 0.02 * height)),
                !(gameProvider.data['break'])
                    ? Column(
                        children: [
                          (gameProvider.data['player_turn'] == gameProvider.data['players'][widget.playername]['order']) && !(gameProvider.compulsoryChallenge) ? Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.orange, Colors.yellow],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: ElevatedButton(
                              onPressed: gameProvider.placeBet,
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent),
                              child: Text(
                                "Place Bet",
                                style: GoogleFonts.macondo(
                                  color: Colors.black,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          )  : const SizedBox.shrink(),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: double.infinity,
                                  vertical: 0.01 * height)),
                          (gameProvider.data['player_turn'] == gameProvider.data['players'][widget.playername]['order']) && !gameProvider.data['first_turn'] ? Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.orange, Colors.yellow],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: ElevatedButton(
                              onPressed: gameProvider.challenge,
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent),
                              child: Text(
                                "Challenge",
                                style: GoogleFonts.macondo(
                                  color: Colors.black,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ): const SizedBox.shrink(),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: double.infinity,
                                  vertical: 0.01 * height)),
                          (gameProvider.data['player_turn'] != gameProvider.data['players'][widget.playername]['order']) && (gameProvider.data['alive_count']) > 2 ? Container(
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.blueGrey],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent),
                              child: Text(
                                "Calza!",
                                style: GoogleFonts.macondo(
                                  color: Colors.black,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ) : const SizedBox.shrink(),
                        ],
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: double.infinity,
                          vertical: 0.02 * height)),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  height: 0.15 * height,
                  color: const Color.fromARGB(125, 255, 255, 255),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: gameProvider.data['players'][widget.playername]
                        ['dice_count'],
                    itemBuilder: (context, index) {
                      int diceNum = gameProvider.data['players']
                          [widget.playername]['d${index + 1}'];
                      String imgPath = dices[diceNum]!;
                      return Center(
                        child: Image.asset(
                          imgPath,
                          scale: 8,
                          color: Colors.amber,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        })));
  }
}
