import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:perudo/models.dart';
import 'package:perudo/victory.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
          return goToVictory(context, gameProvider, widget.lobbyCode, widget.leadername, widget.playername, height, width);
        })));
  }
}

Widget goToVictory(BuildContext context, GameProvider gameProvider, String lobbyCode, String leadername, String playername, double height, double width){
  if(gameProvider.victoryMessage!=''){
    WidgetsBinding.instance.addPostFrameCallback((_) {Navigator.pushReplacement(context, PageTransition(child: Victory(winnerMessage: gameProvider.victoryMessage), type: PageTransitionType.rightToLeft, duration: const Duration(milliseconds: 700)));});
  }
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
                            for (var player
                                in gameProvider.data['players'].keys) {
                              if (gameProvider.data['players'][player]
                                      ['order'] ==
                                  index + 1) {
                                return Container(
                                  decoration:
                                      (gameProvider.data['player_turn'] ==
                                              gameProvider.data['players']
                                                  [player]['order'])
                                          ? const BoxDecoration(
                                              image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/rolling-dice-cup.png'),
                                              scale: 10,
                                              fit: BoxFit.contain,
                                            ))
                                          : null,
                                  // BoxDecoration(backgroundBlendMode: BlendMode.darken, gradient: RadialGradient(colors: [Colors.green, Colors.white]))
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$player',
                                          style: GoogleFonts.josefinSans(
                                              color: player == playername
                                                  ? Colors.blue
                                                  : Colors.black,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          'Dice: ${gameProvider.data['players'][player]['dice_count']}',
                                          style: GoogleFonts.josefinSans(
                                              color: player == playername
                                                  ? Colors.blue
                                                  : Colors.black,
                                              fontSize: 16),
                                        )
                                      ]),
                                );
                              }
                            }
                            return null;
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
                              horizontal: double.infinity,
                              vertical: 0.03 * height)),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          gameProvider.data['message'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.josefinSans(
                            color: Colors.black87,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: double.infinity,
                              vertical: 0.03 * height)),
                      (gameProvider.data['player_turn'] ==
                                  gameProvider.data['players']
                                      [playername]['order']) &&
                              !(gameProvider.compulsoryChallenge) &&
                              !(gameProvider.data['break'])
                          ? Expanded(
                              child: Row(children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    CarouselSlider(
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Text(
                                                  '$i',
                                                  style: const TextStyle(
                                                      fontSize: 23),
                                                ));
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: double.infinity,
                                            vertical: 0.02 * height)),
                                    Text(
                                      "Number",
                                      style: GoogleFonts.josefinSans(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    CarouselSlider(
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Text(
                                                  '$i',
                                                  style: const TextStyle(
                                                      fontSize: 23),
                                                ));
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: double.infinity,
                                            vertical: 0.02 * height)),
                                    Text(
                                      "Face",
                                      style: GoogleFonts.josefinSans(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                              ]),
                            )
                          : const Padding(padding: EdgeInsets.all(0)),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: double.infinity,
                              vertical: 0.05 * height)),
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
                        onComplete: playername == leadername
                            ? gameProvider.leaderTimerExpire
                            : gameProvider.dummy,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: double.infinity,
                              vertical: 0.02 * height)),
                      !(gameProvider.data['break'])
                          ? Column(
                              children: [
                                (gameProvider.data['player_turn'] ==
                                            gameProvider.data['players']
                                                [playername]['order']) &&
                                        !(gameProvider.compulsoryChallenge)
                                    ? Container(
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.orange,
                                                Colors.yellow
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
                                            gameProvider.placeBet();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: const StadiumBorder(),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent),
                                          child: Text(
                                            "Place Bet",
                                            style: GoogleFonts.macondo(
                                              color: Colors.black,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: double.infinity,
                                        vertical: 0.01 * height)),
                                (gameProvider.data['player_turn'] ==
                                            gameProvider.data['players']
                                                [playername]['order']) &&
                                        !gameProvider.data['first_turn']
                                    ? Container(
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.orange,
                                                Colors.yellow
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
                                            gameProvider.challenge();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: const StadiumBorder(),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent),
                                          child: Text(
                                            "Challenge",
                                            style: GoogleFonts.macondo(
                                              color: Colors.black,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: double.infinity,
                                        vertical: 0.01 * height)),
                                (gameProvider.data['player_turn'] !=
                                            gameProvider.data['players']
                                                [playername]['order']) &&
                                        ((gameProvider.data['alive_count']) >
                                            2) &&
                                        (!gameProvider.data['palefico']) &&
                                        (gameProvider.data['players']
                                                        [playername]
                                                    ['dice_count'] !=
                                                5 &&
                                            gameProvider.data['players']
                                                        [playername]
                                                    ['dice_count'] !=
                                                0) &&
                                        ((gameProvider.data['players'][playername]['order'] + 1) %
                                                gameProvider
                                                    .data['alive_count'] !=
                                            gameProvider.data['player_turn'] %
                                                gameProvider.data['alive_count'])
                                    ? Container(
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.blue,
                                                Colors.blueGrey
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
                                            gameProvider.calza();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: const StadiumBorder(),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent),
                                          child: Text(
                                            "Calza!",
                                            style: GoogleFonts.macondo(
                                              color: Colors.black,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
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
                          itemCount: gameProvider.data['players']
                              [playername]['dice_count'],
                          itemBuilder: (context, index) {
                            int diceNum = gameProvider.data['players']
                                [playername]['d${index + 1}'];
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
}
