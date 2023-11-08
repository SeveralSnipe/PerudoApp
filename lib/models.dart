import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class LobbyProvider extends ChangeNotifier {
  late DatabaseReference databaseReference;
  final String code;
  final String player1;
  late final Map<int, String> data = {1: player1};
  late Map<dynamic, dynamic> gameData;
  int count = 1;
  bool started = false;

  LobbyProvider(this.code, this.player1) {
    // Initialize your database reference
    databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$code');

    // Listen to changes in the database and update the data list
    databaseReference.onValue.listen((event) {
      // Parse and update the data as needed
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> temp = event.snapshot.value as Map;
        if (temp['status'] == 'started') {
          started = true;
          gameData = temp;
          notifyListeners();
          return;
        }
        int counter = 2;
        for (var player in temp['players'].keys) {
          if (player == player1) continue;
          data[counter] = player;
          counter++;
        }
        count = temp['count'];
        // values.forEach((key, value) {
        //   data.add(value.toString());
        // });
      }
      // Notify listeners to trigger a rebuild
      notifyListeners();
    });
  }

  void startGame() async {
    databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$code');
    Random random = Random();
    var playersRef = await databaseReference.child('/players').get();
    final Map<String, dynamic> updates = {};
    if (playersRef.value != null) {
      Map<dynamic, dynamic> values = playersRef.value as Map<dynamic, dynamic>;
      int playerNum = 1;
      updates['/total_dice'] = 0;
      for (var player in values.keys) {
        for (var i = 0; i < values[player]['dice_count']; i++) {
          updates['/players/$player/d${i+1}'] = random.nextInt(6)+1;
        }
        updates['/players/$player/order'] = playerNum;
        updates['/total_dice'] += 5;
        playerNum++;
      }
    }
    updates['/status'] = 'started';
    updates['/current_face'] = 0;
    updates['/current_number'] = 0;
    await databaseReference.update(updates);
    await databaseReference.child('/player_turn').set(1);
    await databaseReference.child('/flag').set(true);
    started = true;
    var gameRef = await databaseReference.get();
    gameData = gameRef.value as Map<dynamic, dynamic>;
    notifyListeners();
  }
}

class GameProvider extends ChangeNotifier {
  late DatabaseReference databaseReference;
  final String code;
  late Map<dynamic, dynamic> data;
  late bool isLeader;
  CountDownController timercontroller = CountDownController();
  CountDownController breakcontroller = CountDownController();
  bool timerFlag = true; // true for 1 min false for 5 second
  String message = '1 Min timer';
  List faces = [2, 3, 4, 5, 6];
  List numbers = [];
  // late Map<int, String> playerOrder;

  GameProvider(this.code, this.data, this.isLeader){
    databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$code');
    for (var i = 0; i < data['total_dice']; i++) {
      numbers.add(i + 1);
    }
    databaseReference.onValue.listen((event){
      if (event.snapshot.value != null) {
        data = event.snapshot.value as Map;
        numbers.clear();
        for (var i = 0; i < data['total_dice']; i++) {
          numbers.add(i + 1);
        }
        if (data['flag']) {
          message = '1 Min timer';
          timercontroller.restart(duration: 60);
        } else {
          message = '5 second break';
          timercontroller.restart(duration: 5);
        }
      }
      notifyListeners();
    });
  }

  Future<void> flipTimerFlag() async {
     Map<String, dynamic> updates = {};
    if (!data['flag'] && isLeader) updates = rollDice();
    updates['/flag'] = !data['flag'];
    await databaseReference.update(updates);
  }

  Map<String,dynamic> rollDice() {
      Random random = Random();
      final Map<String, dynamic> updates = {};
      for (var player in data['players'].keys) {
        for (var i = 0; i < data['players'][player]['dice_count']; i++) {
          updates['/players/$player/d${i+1}'] = random.nextInt(6)+1;
        }
      }
      return updates;
    }

  void changedFace(int face){

  }

  void dummy() {
    return;
  }
}
