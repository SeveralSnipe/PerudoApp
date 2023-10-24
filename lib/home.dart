import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils.dart';
import 'lobby.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController roomController =TextEditingController();

  TextEditingController userController =TextEditingController();

  // This widget is the root of your application.
  void roomCreator(String inpString) async{
    FirebaseDatabase database = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/" );
    final DatabaseReference ref = database.ref("Rooms");
    Map<String, dynamic> data={
      'players':{
      inpString: {
        'dice_count': 6,
        'd1': '',
        'd2': '',
        'd3': '',
        'd4': '',
        'd5': '',
        'd6': '',
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
    if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => Lobby(lobbyCode: roomName, leadername: inpString, playername: inpString,)));
  }

  void roomGetter(String room, String name) async{
    FirebaseDatabase database = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/" );
    final DatabaseReference ref = database.ref("Rooms");
    var roomRef=await ref.child(room).get();
    if (roomRef.value!=null){
      Map<dynamic, dynamic> values = roomRef.value as Map<dynamic, dynamic>;
      if (values['count']<6){
        Map<String, dynamic> data={
          'dice_count': 6,
          'd1': '',
          'd2': '',
          'd3': '',
          'd4': '',
          'd5': '',
          'd6': '',
          'status': 'alive'
      };
      final Map<String, dynamic> updates = {};
      updates['/$room/count'] = values['count']+1;
      ref.update(updates);
      ref.child('/$room/players/$name').set(data);
      // var leader = await ref.child(room).child('player1').get();
      // Map <dynamic, dynamic> leadermap = leader.value as Map<dynamic, dynamic>;
      // print(leadermap['player1']);
      if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => Lobby(lobbyCode: room, leadername: values['leader'], playername: name,)));
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
              popUpCreate(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade300),
            ),
            child: Text(
              "Create Lobby",
              style: GoogleFonts.aleo(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          ElevatedButton(
            onPressed: () {
              popUpJoin(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red.shade300),
            ),
            child: Text(
              "Join Lobby",
              style: GoogleFonts.aleo(
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
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          floatingLabelStyle: GoogleFonts.aleo(
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
                    var username = roomController.text;
                    roomCreator(username);
                    setState(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.aleo(
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
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Room ID',
                          floatingLabelStyle: GoogleFonts.aleo(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        controller: roomController,
                      ),
                      const Padding(padding: EdgeInsets.all(20)),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          floatingLabelStyle: GoogleFonts.aleo(
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
                    var roomName = roomController.text;
                    var userName = userController.text;
                    roomGetter(roomName, userName);
                    setState(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.red.shade300),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.aleo(
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
