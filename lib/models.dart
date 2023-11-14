import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
          updates['/players/$player/d${i + 1}'] = random.nextInt(6) + 1;
        }
        updates['/players/$player/order'] = playerNum;
        updates['/total_dice'] += 5;
        playerNum++;
      }
    }
    updates['/status'] = 'started';
    updates['/current_face'] = 0;
    updates['/current_number'] = 0;
    updates['/first_turn'] = true;
    updates['/minutes_flag'] = true;
    updates['/seconds_flag'] = false;
    updates['/player_turn'] = 1;
    updates['/message'] = 'First turn of the game';
    await databaseReference.update(updates);
    // await databaseReference.child('/player_turn').set(1);
    // await databaseReference.child('/flag').set(true);
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
  final String player;
  CountDownController timercontroller = CountDownController();
  CarouselController faceController = CarouselController();
  CarouselController numberController = CarouselController();
  bool timerFlag = true; // true for 1 min false for 5 second
  List faces = [2, 3, 4, 5, 6];
  List numbers = [];
  int centerFace = 2;
  int centerNumber = 1;
  // late Map<int, String> playerOrder;
  // FIGURE OUT TIMER ISSUE ON BET, FIX SOME EDGE CASES FOR CAROUSEL VALUES

  GameProvider(this.code, this.data, this.isLeader, this.player) {
    databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$code');
    for (var i = 0; i < data['total_dice']; i++) {
      numbers.add(i + 1);
    }
    databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> olddata = data;
        data = event.snapshot.value as Map;
        print(olddata['minutes_flag']==data['minutes_flag']);
        if (data['player_turn'] == data['players'][player]['order']) {
          numbers.clear();
          if (data['first_turn']) {
            faces = [2, 3, 4, 5, 6];

            for (var i = 0; i < data['total_dice']; i++) {
              numbers.add(i + 1);
            }
            changedNumber(0);
            numberController.jumpToPage(0);
            faceController.jumpToPage(0);
          } else {
            // jump to face 2
            faces = [1, 2, 3, 4, 5, 6];
            if (data['current_face'] == 1) {
              for (var i = (data['current_number'] * 2);
                  i < data['total_dice'];
                  i++) {
                numbers.add(i + 1);
              }
            } else {
              for (var i = data['current_number'];
                  i < data['total_dice'];
                  i++) {
                numbers.add(i + 1);
              }
            }
            print('reached b4 changednumber');
            changedNumber(0);
            print('reached after changednumber');
            faceController.jumpToPage(1);
            print('reached after face jump 1');
            numberController.jumpToPage(0);
            print('reached after num jump 0');
          }
        }
        // if (data['current_face']!=olddata['current_face'] || data['current_number']!=olddata['current_number']){
        //   timercontroller.restart(duration: 60);
        // }
        if (data['minutes_flag']!=olddata['minutes_flag']) {
          timercontroller.restart(duration: 60);
          print('restart signal 1 min given');
        } 
        if (data['seconds_flag']!=olddata['seconds_flag']) {
          if (data['seconds_flag']) {
            timercontroller.restart(duration: 5);
          }
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

  Future<void> leaderTimerExpire() async{
    Map<String, dynamic> updates;
    if(data['seconds_flag']){
      updates = restartTimer('5 Second timer expired',false);
    }
    else{
      updates= restartTimer('1 minute timer expired',true);
      // implement player inactive kick
    }
    await databaseReference.update(updates);
  }

  Map<String, dynamic> rollDice() {
    Random random = Random();
    final Map<String, dynamic> updates = {};
    for (var player in data['players'].keys) {
      for (var i = 0; i < data['players'][player]['dice_count']; i++) {
        updates['/players/$player/d${i + 1}'] = random.nextInt(6) + 1;
      }
    }
    return updates;
  }

  void changedFace(int faceidx) {
    centerFace = faces[faceidx];
    if(data['first_turn']) return;
    numbers.clear();
    if (data['current_face'] != 1) {
      if (centerFace != 1) {
          for (var i = data['current_number']; i < data['total_dice']; i++) {
            numbers.add(i + 1);
          }
      } else {
        for (var i = (data['current_number'] / 2).ceil() - 1;
            i < data['total_dice'];
            i++) {
          numbers.add(i + 1);
        }
      }
    } else {
      if (centerFace == 1) {
        for (var i = data['current_number']; i < data['total_dice']; i++) {
          numbers.add(i + 1);
        }
      } else {
        for (var i = (data['current_number'] * 2);
            i < data['total_dice'];
            i++) {
          numbers.add(i + 1);
        }
      }
    }
    changedNumber(0);
    numberController.jumpToPage(0);

    notifyListeners();
  }

  void changedNumber(int numidx){
    centerNumber = numbers[numidx];
  }

  Future<void> placeBet() async{
    int face = centerFace;
    int number = centerNumber;
    Map<String, dynamic> updates;
    updates = restartTimer("$player thinks that there are $number ${face}s in total", true);
    updates['/current_face'] = face;
    updates['/current_number'] = number;
    if(data['first_turn']){
      updates['/first_turn'] = false;
    }
    // When eliminating player, change player turn logic
    updates['/player_turn'] = (data['player_turn']%data['count'])+1;
    await databaseReference.update(updates);
  }

  Map<String, dynamic> restartTimer(String message, bool type){ //'type' is for 1 minute or 5 seconds
    final Map<String, dynamic> updates = {};
    if(type){
      updates['/minutes_flag'] = !data['minutes_flag'];
    }
    else{
      updates['/seconds_flag'] = !data['seconds_flag'];
    }
    updates['/message'] = message;
    return updates;
  }

  void dummy() {
    return;
  }
}
