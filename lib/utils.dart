import 'dart:math';
import 'package:flutter/material.dart';



Future<void> alert(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Okay'),
            onPressed: () {
              if(context.mounted){
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },   
  ); 
}



String generateRandomString(int len) {
  var r = Random();
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

int findPlayerNumber(String playername, Map<dynamic,dynamic> values){
  int playernumber;
  if(playername==values['player1']['name']){
    playernumber=1;
  }
  else if(playername==values['player2']['name']){
    playernumber=2;
  }
  else if(playername==values['player3']['name']){
    playernumber=3;
  }
  else if(playername==values['player4']['name']){
    playernumber=4;
  }
  else if(playername==values['player5']['name']){
    playernumber=5;
  }
  else if(playername==values['player6']['name']){
    playernumber=6;
  }
  else{
    playernumber=-1; //error
  }

  return playernumber;
}
