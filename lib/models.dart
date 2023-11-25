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
    var playersRef = await databaseReference.get();
    final Map<String, dynamic> updates = {};
    if (playersRef.value != null) {
      Map<dynamic, dynamic> values = playersRef.value as Map<dynamic, dynamic>;
      int playerNum = 1;
      updates['/total_dice'] = 0;
      for (var player in values['players'].keys) {
        for (var i = 0; i < values['players'][player]['dice_count']; i++) {
          updates['/players/$player/d${i + 1}'] = random.nextInt(6) + 1;
        }
        updates['/players/$player/order'] = playerNum;
        updates['/total_dice'] += 5;
        playerNum++;
      }
      updates['/alive_count'] = values['count'];
    }
    updates['/status'] = 'started';
    updates['/current_face'] = 0;
    updates['/current_number'] = 0;
    updates['/first_turn'] = true;
    updates['/minutes_flag'] = true;
    updates['/seconds_flag'] = false;
    updates['/player_turn'] = 1;
    updates['/palefico'] = false;
    updates['/message'] = 'First turn of the game';
    updates['/break'] = false;
    await databaseReference.update(updates);
    // await databaseReference.child('/player_turn').set(1);
    // await databaseReference.child('/flag').set(true);
    // started = true;
    // gameData = playersRef.value as Map<dynamic, dynamic>;
    // notifyListeners();
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
  bool compulsoryChallenge = false;
  String victoryMessage = '';
  // late Map<int, String> playerOrder;
  // IMPLEMENT CALZA, VICTORY, HOW TO PLAY

  GameProvider(this.code, this.data, this.isLeader, this.player) {
    databaseReference = FirebaseDatabase(
            databaseURL:
                "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref('Rooms/$code');
    for (var i = 0; i < data['total_dice']; i++) {
      numbers.add(i + 1);
    }
    print('entered here 3');
    databaseReference.onValue.listen((event) {
      compulsoryChallenge = false;
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> olddata = data;
        data = event.snapshot.value as Map;
        if (data['player_turn'] == data['players'][player]['order']) {
          numbers.clear();
          if (data['first_turn']) {
            if (data['palefico']) {
              faces = [1, 2, 3, 4, 5, 6];
              centerFace = 1;
            } else {
              faces = [2, 3, 4, 5, 6];
              centerFace = 2;
            }

            for (var i = 0; i < data['total_dice']; i++) {
              numbers.add(i + 1);
            }
            changedNumber(0);
            // numberController.animateToPage(0);
            // faceController.animateToPage(0);
          } else if (data['current_number'] == data['total_dice']) {
            if (data['current_face'] == 1 || data['palefico']) {
              compulsoryChallenge = true;
              numbers.add(0);
            } else {
              faces = [
                1,
              ];
              for (var i = (data['current_number'] / 2).ceil();
                  i < data['total_dice'];
                  i++) {
                numbers.add(i + 1);
              }
              centerFace = 1;
            }
            changedNumber(0);
          } else {
            if (!data['palefico']) {
              faces = [1, 2, 3, 4, 5, 6];
              centerFace = 1;
              if (data['current_face'] == 1) {
                if (data['current_number'] >= data['total_dice'] / 2) {
                  faces = [1, ];
                  centerFace = 1;
                }
                for (var i = (data['current_number']);
                    i < data['total_dice'];
                    i++) {
                  numbers.add(i + 1);
                }
              } else {
                for (var i = (data['current_number'] / 2).ceil();
                    i < data['total_dice'];
                    i++) {
                  numbers.add(i + 1);
                }
              }
            } else {
              faces = [data['current_face'], ];
              centerFace = data['current_face'];
              for (var i = (data['current_number']);
                    i < data['total_dice'];
                    i++) {
                  numbers.add(i + 1);
                }
            }
            changedNumber(0);
          }
        }
        // if (data['current_face']!=olddata['current_face'] || data['current_number']!=olddata['current_number']){
        //   timercontroller.restart(duration: 60);
        // }
        if (data['minutes_flag'] != olddata['minutes_flag']) {
          timercontroller.restart(duration: 60);
        }
        if (data['seconds_flag'] != olddata['seconds_flag']) {
          if (data['seconds_flag']) {
            timercontroller.restart(duration: 5);
          }
          else{
            timercontroller.restart(duration: 60);
          }
        }
      }
      if (data['alive_count']==1) {
        for (var player in data['players'].keys) {
          if (data['players'][player]['status']=='alive') {
            victoryMessage = '$player has won the game with ${data['players'][player]['dice_count']} dice left!';
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

  Future<void> leaderTimerExpire() async {
    Map<String, dynamic> updates;
    if (data['seconds_flag']) {
      updates = restartTimer(data['message'], false);
      updates['/break'] = false;
      updates.addAll(rollDice());
    } else {
      String currentPlayer = '';
      for (var player in data['players'].keys){
        if (data['players'][player]['order']==data['player_turn']) {
          currentPlayer = player;
        }
      }
      updates = restartTimer('$currentPlayer is inactive and has been eliminated.', false);
      int diceRemoved = data['players'][currentPlayer]['dice_count'];
      updates['/total_dice'] = data['total_dice'] - diceRemoved;
      updates['/players/$currentPlayer/dice_count'] = 0;
      updates['/players/$currentPlayer/status'] = 'eliminated';
      updates['/alive_count'] = data['alive_count'] - 1;
      updates['/first_turn'] = true;
      updates['/current_face'] = 0;
      updates['/current_number'] = 0;
      updates['/players/$currentPlayer/order'] = -1;
      if (data['player_turn']==data['alive_count']) {
        updates['/player_turn'] = 1;
      } else{
        for (var player in data['players'].keys){
          if (data['players'][player]['status']=='alive' && data['players'][player]['order']>data['players'][currentPlayer]['order']) {
            updates['/players/$player/order'] = data['players'][player]['order'] - 1;
          }
        }
      }
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
    if (data['first_turn']) return;
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

  void changedNumber(int numidx) {
    centerNumber = numbers[numidx];
  }

  Future<void> placeBet() async {
    int face = centerFace;
    int number = centerNumber;
    Map<String, dynamic> updates;
    updates = restartTimer(
        "$player thinks that there are $number ${face}s in total", true);
    updates['/current_face'] = face;
    updates['/current_number'] = number;
    if (data['first_turn']) {
      updates['/first_turn'] = false;
    }
    updates['/player_turn'] = (data['player_turn'] % data['alive_count']) + 1;
    await databaseReference.update(updates);
  }

  Future<void> challenge() async {
    Map<String, dynamic> updates = {};
    int diceCount = 0;
    compulsoryChallenge = false;
    for (var player in data['players'].keys) {
      if (data['players'][player]['status']=='alive') {
        for (var i = 1; i < data['players'][player]['dice_count'] + 1; i++) {
          if ((data['players'][player]['d$i'] == data['current_face']) || ((data['players'][player]['d$i'] == 1) && !data['palefico'])) {
            diceCount++;
          }
        }
      }
    }
    if (diceCount>=data['current_number']) {
      for (var player in data['players'].keys) {
          if (data['players'][player]['order'] == data['player_turn']) {
            updates = restartTimer('$player has lost the challenge and loses a dice.', false);
            updates['/player_turn'] = data['players'][player]['order'];
            updates['/total_dice'] = data['total_dice'] - 1;
            updates['/players/$player/dice_count'] = data['players'][player]['dice_count'] - 1;
            updates['/palefico'] = false;
            if (data['players'][player]['dice_count'] == 2 && !data['players'][player]['palefico_done']) {
              updates['/palefico'] = true;
              updates['/players/$player/palefico_done'] = true;
              updates['/message'] = '$player has lost the challenge and loses a dice. Their palefico begins!';
            }
            if (data['players'][player]['dice_count'] == 1) {
              updates['/message'] = '$player has lost the challenge and loses their last dice.';
              updates['/players/$player/status'] = 'eliminated';
              updates['/alive_count'] = data['alive_count'] - 1;
              updates['/current_face'] = 0;
              updates['/current_number'] = 0;
              updates['/players/$player/order'] = -1;
              if (data['player_turn']==data['alive_count']) {
                updates['/player_turn'] = 1;
              } else{
                for (var player in data['players'].keys){
                  if (data['players'][player]['status']=='alive' && data['players'][player]['order']>data['players'][player]['order']) {
                    updates['/players/$player/order'] = data['players'][player]['order'] - 1;
                  }
                }
              }
            }
            break;
          }
        }
      }
    else{
      int challengedOrder;
      String challengedPlayer = '';
      for (var player in data['players'].keys) {
        if (data['players'][player]['order'] == data['player_turn']) {
          if (data['players'][player]['order'] == 1) {
            challengedOrder = data['alive_count'];
          } else {
            challengedOrder = data['players'][player]['order'] - 1;
          }
          for (var player2 in data['players'].keys) {
            if (data['players'][player2]['order'] == challengedOrder) {
              challengedPlayer = player2;
            }
          }
          updates = restartTimer('$player has won the challenge, $challengedPlayer loses a die.', false);
          updates['/player_turn'] = challengedOrder;
          updates['/total_dice'] = data['total_dice'] - 1;
          updates['/players/$challengedPlayer/dice_count'] = data['players'][challengedPlayer]['dice_count'] - 1;
          updates['/palefico'] = false;
          if (data['players'][challengedPlayer]['dice_count'] == 2 && !data['players'][challengedPlayer]['palefico_done']) {
            updates['/palefico'] = true;
            updates['/players/$player/palefico_done'] = true;
            updates['/message'] = '$player has won the challenge, $challengedPlayer loses a dice. Their palefico begins!';
          }
          if (data['players'][challengedPlayer]['dice_count'] == 1) {
            updates['/message'] = '$player has won the challenge, and $challengedPlayer loses their last dice.';
            updates['/players/$challengedPlayer/status'] = 'eliminated';
            updates['/alive_count'] = data['alive_count'] - 1;
            updates['/current_face'] = 0;
            updates['/current_number'] = 0;
            updates['/players/$challengedPlayer/order'] = -1;
            if (data['player_turn']==data['alive_count']) {
              updates['/player_turn'] = 1;
            } else{
              for (var player2 in data['players'].keys){
                if (data['players'][player2]['status']=='alive' && data['players'][player2]['order']>data['players'][player2]['order']) {
                  updates['/players/$player2/order'] = data['players'][player2]['order'] - 1;
                }
              }
            }
          }
          break;
        }
      }
    }
    updates['/first_turn'] = true;
    await databaseReference.update(updates);
    timercontroller.restart(duration: 5);
  }

  Future<void> calza() async{
    Map<String, dynamic> updates = {};
    compulsoryChallenge = false;
    int diceCount = 0;
    for (var player in data['players'].keys) {
      if (data['players'][player]['status']=='alive') {
        for (var i = 1; i < data['players'][player]['dice_count'] + 1; i++) {
          if ((data['players'][player]['d$i'] == data['current_face']) || ((data['players'][player]['d$i'] == 1) && !data['palefico'])) {
            diceCount++;
          }
        }
      }
    }

    if (diceCount == data['current_number']) {
      updates = restartTimer('$player called Calza and won, they get a dice back.', false);
      updates['/total_dice'] = data['total_dice']+1;
      updates['/player_turn'] = data['players'][player]['order'];
      updates['/players/$player/dice_count'] = data['players'][player]['dice_count'] + 1;
    }
    else{
      updates = restartTimer('$player called Calza and lost, they lose a dice.', false);
      updates['/total_dice'] = data['total_dice'] - 1;
      updates['/players/$player/dice_count'] = data['players'][player]['dice_count'] - 1;
      updates['/player_turn'] = data['players'][player]['order'];
      if (data['players'][player]['dice_count'] == 2 && !data['players'][player]['palefico_done']) {
        updates['/palefico'] = true;
        updates['/players/$player/palefico_done'] = true;
        updates['/message'] = '$player called Calza and lost, they lose a dice. Their palefico begins!';
      }
      if (data['players'][player]['dice_count'] == 1) {
        updates['/message'] = '$player called Calza and lost, hence losing their last dice.';
        updates['/players/$player/status'] = 'eliminated';
        updates['/alive_count'] = data['alive_count'] - 1;
        updates['/current_face'] = 0;
        updates['/current_number'] = 0;
        updates['/players/$player/order'] = -1;
        if (data['player_turn']==data['alive_count']) {
          updates['/player_turn'] = 1;
        } else{
          for (var player2 in data['players'].keys){
            if (data['players'][player2]['status']=='alive' && data['players'][player2]['order']>data['players'][player2]['order']) {
              updates['/players/$player2/order'] = data['players'][player2]['order'] - 1;
            }
          }
        }
      }
    }

    updates['/first_turn'] = true;
    await databaseReference.update(updates);
    timercontroller.restart(duration: 5);
  }

  Map<String, dynamic> restartTimer(String message, bool type) {
    //'type' is for 1 minute or 5 seconds
    final Map<String, dynamic> updates = {};
    if (type) {
      updates['/minutes_flag'] = !data['minutes_flag'];
    } else {
      updates['/seconds_flag'] = !data['seconds_flag'];
      updates['/break'] = true;
    }
    updates['/message'] = message;
    return updates;
  }

  void dummy() {
    return;
  }
}
