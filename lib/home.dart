// import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import 'utils.dart';
import 'lobby.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController roomController =TextEditingController();

  TextEditingController userController =TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkCleaned();
  }

  @override
  void dispose() {
    roomController.dispose();
    userController.dispose();
    super.dispose();
  }

  void checkCleaned() async{
    FirebaseDatabase database = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/" );
    DatabaseReference ref = database.ref('last_cleaned');
    var lastCleanedRef = await ref.get();
    if (lastCleanedRef.value!=null){
      DateTime lastCleaned = DateTime.parse(lastCleanedRef.value as String);
      if (DateTime.now().difference(lastCleaned).inDays > 0) {
        ref = database.ref();
        var roomValues = await ref.get();
        if (roomValues.value!=null) {
          Map<dynamic, dynamic> values = roomValues.value as Map<dynamic, dynamic>;
          final Map<String, dynamic> updates = {};
          for (var room in values['Rooms'].keys) {
            if (room!='dummy' && DateTime.now().difference(DateTime.parse(values['Rooms'][room]['last_touched'])).inDays > 0) {
              updates['/Rooms/$room'] = null;
            }
          }
          updates['/last_cleaned'] = DateTime.now().toString();
          await ref.update(updates);
        }
      }
    }
  }
  // This widget is the root of your application.
  void roomCreator(String inpString) async{
    FirebaseDatabase database = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/" );
    final DatabaseReference ref = database.ref("Rooms");
    Map<String, dynamic> data={
      'last_touched': DateTime.now().toString(),
      'players':{
      inpString: {
        'dice_count': 5,
        'd1': '',
        'd2': '',
        'd3': '',
        'd4': '',
        'd5': '',
        'palefico_done': false,
        'status': 'alive'
      },
      },
      'status': 'filling',
      'count' : 1,
      'leader': inpString
    };
    var roomName = generateRandomString(6);
    var roomRef= ref.child(roomName);
    roomRef.set(data);
    if (context.mounted) Navigator.push(context, PageTransition(child: Lobby(lobbyCode: roomName, leadername: inpString, playername: inpString,), type: PageTransitionType.rightToLeft, duration: const Duration(milliseconds: 700),));
  }

  void roomGetter(String room, String name) async{
    FirebaseDatabase database = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/" );
    final DatabaseReference ref = database.ref("Rooms");
    var roomRef=await ref.child(room).get();
    if (roomRef.value!=null){
      Map<dynamic, dynamic> values = roomRef.value as Map<dynamic, dynamic>;
      if (values['count']<6){
        Map<String, dynamic> data={
          'dice_count': 5,
          'd1': '',
          'd2': '',
          'd3': '',
          'd4': '',
          'd5': '',
          'palefico_done': false,
          'status': 'alive'
      };
      final Map<String, dynamic> updates = {};
      updates['/$room/count'] = values['count']+1;
      updates['/$room/last_touched'] = DateTime.now().toString();
      ref.update(updates);
      ref.child('/$room/players/$name').set(data);
      // var leader = await ref.child(room).child('player1').get();
      // Map <dynamic, dynamic> leadermap = leader.value as Map<dynamic, dynamic>;
      // print(leadermap['player1']);
      if (context.mounted) Navigator.push(context, PageTransition(child: Lobby(lobbyCode: room, leadername: values['leader'], playername: name,), type: PageTransitionType.rightToLeft, duration: const Duration(milliseconds: 700)));
      
    }
    else{
      alert(context, 'Lobby is full');
    }
  }
  else{
      alert(context, 'Room does not exist');
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "PERUDO",
            style: GoogleFonts.oswald(color: Colors.black, fontSize: 40),
          ),
          const Padding(padding: EdgeInsets.all(30)),
          Image.asset(
            "assets/images/mainlogo.png",
            height: 200,
            width: 200,
            color: Colors.red.shade600,
          ),
          const Padding(padding: EdgeInsets.all(50)),
          ElevatedButton(
            onPressed: () {
              AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
              popUpCreate(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade300),
            ),
            child: Text(
              "Create Lobby",
              style: GoogleFonts.josefinSans(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          ElevatedButton(
            onPressed: () {
              AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
              popUpJoin(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade300),
            ),
            child: Text(
              "Join Lobby",
              style: GoogleFonts.josefinSans(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          ElevatedButton(
            onPressed: () {
              AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
              popUpInfo(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade300),
            ),
            child: Text(
              "How to Play",
              style: GoogleFonts.josefinSans(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
  }

  Future popUpCreate(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
            AlertDialog(
              title: const Text("Room Creator"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              else if (value.contains(RegExp(r'[/.#$\[\]]'))){
                return 'Name must not contain /, ., #, \$, [, or ]';
              }
              return null;
            },
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          floatingLabelStyle: GoogleFonts.josefinSans(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        controller: roomController,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
                    if (_formKey.currentState!.validate()) {
  Navigator.pop(context);
  var username = roomController.text;
  roomCreator(username);
  setState(() {});
}
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.josefinSans(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ]),
        );
      },
    );
  }

  Future popUpJoin(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
            AlertDialog(
              title: const Text("Room Joiner"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey2,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Room ID',
                          floatingLabelStyle: GoogleFonts.josefinSans(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        controller: roomController,
                      ),
                      const Padding(padding: EdgeInsets.all(20)),
                      TextFormField(
                        validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              else if (value.contains(RegExp(r'[/.#$\[\]]'))){
                return 'Name must not contain /, ., #, \$, [, or ]';
              }
              return null;
            },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          floatingLabelStyle: GoogleFonts.josefinSans(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        controller: userController,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    AudioPlayer().play(AssetSource('audio/shooting-sound-fx-159024.mp3'), mode: PlayerMode.lowLatency);
                    if (_formKey2.currentState!.validate()) {
  Navigator.pop(context);
  var roomName = roomController.text;
  var userName = userController.text;
  roomGetter(roomName, userName);
  setState(() {});
}
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.josefinSans(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ]),
        );
      },
    );
  }
}


Future popUpInfo(BuildContext context){
  return showDialog(
    context: context, 
    builder: (BuildContext context){
      return Center(
        child: ListView(shrinkWrap: true, children: [
          AlertDialog(
            content: Column(
              children:[
                easyText('OBJECTIVE', true),
                easyText('Be the last player with dice.', false),
                easyText('GENERAL', true),
                easyText('Each player begins with 5 dice.', false),
                easyText('On your turn, you must bet on a face value and the number of those dice.', false),
                easyText('You can bet any face value, but the number should always be higher than the previous bet.', false),
                easyText('If you feel like the previous bet is false, you can challenge it. Whoever loses the challenge loses a dice and starts the next round.', false),
                easyText('ONES', true),
                easyText('Ones are considered wilds.', false),
                easyText('To bet on the number of ones, there are a few special rules.', false),
                easyText('If changing face value TO one, then you must halve the numeric value (rounded up).', false),
                easyText('For example, to convert a bet of 7 5s to ones, the minimum ones bet will be 4 1s.', false),
                easyText('To change face value FROM one, the number should be atleast 2 times + 1.', false),
                easyText('For example, to convert 3 1s to any other number, the minimum bet can be 7 5s.', false),
                easyText('PALEFICO', true),
                easyText('When a player reaches their last dice, they start a round of palefico.', false),
                easyText('Each player can start palefico only once per game.', false),
                easyText('During palefico, ones are not wild and the initial face value CANNOT be changed by anyone.', false),
                easyText('CALZA', true),
                easyText('During a round, any player apart from the current and previous player can call calza.', false),
                easyText('When calza is called, the round ends and dice are counted.', false),
                easyText('If the current bet is EXACTLY correct, then the player who called calza gains back a dice.', false),
                easyText('Otherwise, they lose a dice.', false),
                easyText('Either way, they start the next round of betting.', false)
              ]
            ),
          )
        ],)
          );
});
    }

Widget easyText(String message, bool heading){
  return Text(
                    message,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.josefinSans(
                      color: Colors.black87,
                      fontSize: heading ? 26 : 20,
                      textStyle: TextStyle(fontWeight: heading? FontWeight.bold : FontWeight.normal)
                    ),
                  );
}
    