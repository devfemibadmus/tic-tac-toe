import 'package:flutter/material.dart';
import 'package:tictactoe/game.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String level = '';
  late BuildContext userDialogContext;
  late BuildContext computerDialogContext;
  final _url = Uri.parse('https://github.com/devfemibadmus/tic-tac-toe');

  void _level(BuildContext context, player) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        computerDialogContext = context;
        if (player == 'User') {
          return const AlertDialog(
            title: Text('Coming soon'),
            content:
                Text('Play with user remotly by generating playing room link'),
          );
        }
        return AlertDialog(
          title: const Text('Level'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                level = value;
              });
            },
            obscureText: true, // Set obscureText to true
            decoration: const InputDecoration(hintText: 'Enter hard or level'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (level == 'hard') {
                  Navigator.of(computerDialogContext).pop();
                  _navigateToPlayScreen(context, 'hard', player);
                } else if (level == 'easy') {
                  Navigator.of(computerDialogContext).pop();
                  _navigateToPlayScreen(context, 'easy', player);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please enter easy or hard.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _navigateToPlayScreen(
      BuildContext context, String md, String firstPlayer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicTacToeGame(mode: md, cp: firstPlayer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              _launchURL();
            },
            icon: const Icon(Icons.link),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _level(context, 'Computer');
              },
              child: Container(
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.computer,
                      size: 100,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Computer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _level(context, 'User');
              },
              child: Container(
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
