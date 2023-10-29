import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  late DatabaseReference databaseReference;
  final String code;
  final String player1;
  late final Map<int, String> data = {1: player1};
  int count = 1;
  bool started = false;

  DatabaseProvider(this.code, this.player1){
    // Initialize your database reference
    databaseReference = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/").ref('Rooms/$code');

    // Listen to changes in the database and update the data list
    databaseReference.onValue.listen((event) {
      // Parse and update the data as needed
      if (event.snapshot.value != null) {
        Map<dynamic,dynamic> temp = event.snapshot.value as Map;
        if (temp['status']=='started'){
          started = true;
          notifyListeners();
          return;
        }
        int counter = 2;
        for (var player in temp['players'].keys) {
          if (player==player1) continue;
          data[counter]=player;
          counter++;
        }
        count=temp['count'];
        // values.forEach((key, value) {
        //   data.add(value.toString());
        // });
      }
      // Notify listeners to trigger a rebuild
      notifyListeners();
    });
  }

  void startGame() async{
    databaseReference = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/").ref('Rooms/$code');
    var playersRef = await databaseReference.child('/players').get();
    final Map<String, dynamic> updates = {};
    if(playersRef.value !=null){
      Map<dynamic, dynamic> values = playersRef.value as Map<dynamic, dynamic>;
      int playerNum=1;
      for (var player in values.keys) {
        updates['/players/$player/order']=playerNum;
        playerNum++;
      }
    }
    updates['/status'] = 'started'; 
    await databaseReference.update(updates);
    started = true;
    notifyListeners();
  }
}