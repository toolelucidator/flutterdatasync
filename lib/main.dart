import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dataController = TextEditingController();
  final databaseReference =
      FirebaseDatabase.instance.ref("Firebase IoT").child("Temperatura");
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  String data = "";

  void addData(String data) {
    databaseReference.set({'valor': data});
  }

  String printFromDatabase() {
    databaseReference.once().then((DatabaseEvent event) {
      print(event.snapshot.value);
    });

    DatabaseReference _relayreference =
        FirebaseDatabase.instance.ref("Firebase IoT").child("Temperatura");
    _relayreference.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value.toString();
      setState(() {
        this.data = data;
      });
      print(data);
    });
    return data;

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    printFromDatabase();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Listener"),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  printFromDatabase(),
                  style: const TextStyle(fontSize: 30, color: Colors.green),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _dataController,
                    decoration: const InputDecoration(hintText: "Insert Data"),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {
                      addData(_dataController.text);
                    },
                    color: Colors.greenAccent,
                    child: const Text("Add Data to Firebase"),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {
                      printFromDatabase();
                    },
                    color: Colors.redAccent,
                    child: const Text("Print Data from Firebase"),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
