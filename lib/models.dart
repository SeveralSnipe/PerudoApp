import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseProvider extends ChangeNotifier {
  late DatabaseReference databaseReference;
  final String code;
  final String player1;
  late final Map<int, String> data = {1: player1};
  int count = 1;

  DatabaseProvider(this.code, this.player1){
    // Initialize your database reference
    databaseReference = FirebaseDatabase(databaseURL: "https://perudo-flutter-default-rtdb.asia-southeast1.firebasedatabase.app/").ref('Rooms/$code');

    // Listen to changes in the database and update the data list
    databaseReference.onValue.listen((event) {
      // Parse and update the data as needed
      if (event.snapshot.value != null) {
        Map<dynamic,dynamic> temp = event.snapshot.value as Map;
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
}