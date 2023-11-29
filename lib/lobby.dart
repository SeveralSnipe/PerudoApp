import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:perudo/game.dart';
import 'package:perudo/models.dart';
import 'package:provider/provider.dart';


class Lobby extends StatefulWidget {
  final String lobbyCode;
  final String leadername;
  final String playername;
  const Lobby(
      {super.key,
      required this.lobbyCode,
      required this.leadername,
      required this.playername});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  void dispose() async {
    var room = widget.lobbyCode;
    DatabaseReference databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$room');
    var roomRef = await databaseReference.get();
    if (roomRef.value != null) {
      Map<dynamic, dynamic> values = roomRef.value as Map<dynamic, dynamic>;
      if (widget.leadername != widget.playername && values['status']=="filling") {
        final Map<String, dynamic> updates = {};
        updates['/count'] = values['count'] - 1;
        updates['/last_touched'] = DateTime.now().toString();
        await databaseReference.update(updates);
        await databaseReference.child('/players/${widget.playername}').remove();
      } else if(values['status']=="filling"){
        databaseReference.remove();
      }
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LobbyProvider(widget.lobbyCode, widget.leadername),
        child: Scaffold(body: Consumer<LobbyProvider>(
            builder: (context, myDatabaseProvider, child) {
          return showPage(context, widget.lobbyCode, widget.playername, widget.leadername, myDatabaseProvider);
        })));
  }
}

Widget showPage(BuildContext context, String code, String player, String leader, LobbyProvider myDatabaseProvider){
  if(myDatabaseProvider.started){
    WidgetsBinding.instance.addPostFrameCallback((_) {Navigator.pushReplacement(context, PageTransition(child: Game(
                  lobbyCode: code,
                  playername: player,
                  leadername: leader,
                  initData: myDatabaseProvider.gameData), type: PageTransitionType.rightToLeft, duration: const Duration(milliseconds: 700)) );});
  }
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Players',
                          style: GoogleFonts.aleo(
                            color: Colors.black87,
                            fontSize: 20,
                          )),
                      const Padding(padding: EdgeInsets.all(20)),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: myDatabaseProvider.count,
                        itemBuilder: (context, index) {
                          final key =
                              myDatabaseProvider.data.keys.elementAt(index);
                          final value = myDatabaseProvider.data[key];
                          return Center(
                              child: Text(
                            key == 1 ? '♚ $value' : '$value',
                            style: TextStyle(
                                fontWeight: value == player
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16),
                          ));
                        },
                      ),
                      leader == player
                          ? ElevatedButton(
                              onPressed: myDatabaseProvider.count > 1
                                  ? () {
                                      myDatabaseProvider.startGame();
                                    }
                                  : null,
                              style: ButtonStyle(
                                backgroundColor: myDatabaseProvider.count > 1
                                    ? MaterialStatePropertyAll(
                                        Colors.red.shade300)
                                    : const MaterialStatePropertyAll(
                                        Colors.grey),
                              ),
                              child: Text(
                                "Start Game",
                                style: GoogleFonts.aleo(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : const Padding(padding: EdgeInsets.all(0)),
                      const Padding(padding: EdgeInsets.all(20)),
                      Text('Code: $code',
                          style: GoogleFonts.aleo(
                            color: Colors.black87,
                            fontSize: 16,
                          )),
                    ],
                  ));
}
