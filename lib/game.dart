import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

enum Player { X, O }

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key, required this.mode, required this.cp});
  final String mode;
  final String cp;

  @override
  TicTacToeGameState createState() => TicTacToeGameState();
}

class TicTacToeGameState extends State<TicTacToeGame> {
  late List<List<Player?>> gameBoard;
  late Player currentPlayer;
  late Player nextPlayer;
  late bool gameOver;

  @override
  void initState() {
    super.initState();
    newGame();
  }

  void newGame() {
    setState(() {
      gameBoard = List.generate(3, (_) => List.filled(3, null));
      gameOver = false;
      if (widget.cp == 'User') {
        currentPlayer = Player.X;
      } else {
        currentPlayer = Player.O;
        computerPlay();
      }
    });
  }

  void handleCellClick(int row, int col) {
    if (gameBoard[row][col] != null || gameOver) {
      return;
    }

    Player currentPlayerMove =
        currentPlayer; // Store current player before making move
    gameBoard[row][col] = currentPlayerMove;

    bool continueGame = checkGameStatus(currentPlayerMove);
    currentPlayer = (currentPlayer == Player.X) ? Player.O : Player.X;

    setState(() {});

    if (currentPlayer == Player.O && continueGame && !gameOver) {
      Future.delayed(const Duration(milliseconds: 500), computerPlay);
    }
  }

  void computerPlay() {
    if (widget.mode == 'easy') {
      return easy();
    } else {
      return hard();
    }
  }

  void easy() {
    Player? move;

    // Check if computer can win in the next move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (gameBoard[i][j] == null) {
          gameBoard[i][j] = Player.O;
          if (checkForWin(Player.O)) {
            move = Player.O;
            break;
          } else {
            gameBoard[i][j] = null;
          }
        }
      }
      if (move != null) break;
    }

    // If no immediate win, choose a random open square
    if (move == null) {
      while (true) {
        int i = Random().nextInt(3);
        int j = Random().nextInt(3);
        if (gameBoard[i][j] == null) {
          gameBoard[i][j] = Player.O;
          move = Player.O;
          break;
        }
      }
    }

    // Update the game state after computer makes a move
    setState(() {
      checkGameStatus(move!);
      currentPlayer = (currentPlayer == Player.X) ? Player.O : Player.X;
    });
  }

  void hard() {
    int bestScore = -1000;
    Move move = Move(-1, -1);

    // Traverse all cells, evaluate minimax function for all empty cells and return the cell with optimal value
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        // Check if cell is empty
        if (gameBoard[i][j] == null) {
          // Make the move
          gameBoard[i][j] = Player.O;

          // Compute evaluation function for this move
          int moveScore = minimax(0, false);

          // Undo the move
          gameBoard[i][j] = null;

          // If the found move is better than the previous one, then update best move
          if (moveScore > bestScore) {
            move = Move(i, j);
            bestScore = moveScore;
          }
        }
      }
    }

    // Make the best move
    gameBoard[move.row][move.col] = Player.O;

    // Update the game state after computer makes a move
    setState(() {
      checkGameStatus(Player.O);
      currentPlayer = Player.X;
    });
  }

  bool checkGameStatus(Player player) {
    if (checkForWin(player)) {
      String winner;
      if (currentPlayer == Player.X) {
        winner = "YOU WIN!";
      } else {
        winner = "YOU LOOSE!";
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(winner),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sendData(currentPlayer.toString());
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      gameOver = true;
    } else if (checkForTie()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("It's a tie!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sendData("Tie");
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      gameOver = true;
    } else {
      return true;
    }

    return false;
  }

  void sendData(String result) {
    //
  }

  bool checkForWin(Player player) {
    // Check rows
    for (int row = 0; row < gameBoard.length; row++) {
      if (gameBoard[row][0] == player &&
          gameBoard[row][1] == player &&
          gameBoard[row][2] == player) {
        return true;
      }
    }

    // Check columns
    for (int col = 0; col < gameBoard[0].length; col++) {
      if (gameBoard[0][col] == player &&
          gameBoard[1][col] == player &&
          gameBoard[2][col] == player) {
        return true;
      }
    }

    // Check diagonals
    if (gameBoard[0][0] == player &&
        gameBoard[1][1] == player &&
        gameBoard[2][2] == player) {
      return true;
    }
    if (gameBoard[0][2] == player &&
        gameBoard[1][1] == player &&
        gameBoard[2][0] == player) {
      return true;
    }

    return false;
  }

  bool checkForTie() {
    for (int row = 0; row < gameBoard.length; row++) {
      for (int col = 0; col < gameBoard[row].length; col++) {
        if (gameBoard[row][col] == null) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int row = index ~/ 3;
                int col = index % 3;
                return GestureDetector(
                  onTap: () => handleCellClick(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Center(
                      child: gameBoard[row][col] == Player.X
                          ? CustomPaint(
                              painter: CrossPainter(), size: const Size(50, 50))
                          : gameBoard[row][col] == Player.O
                              ? CustomPaint(
                                  painter: CirclePainter(),
                                  size: const Size(50, 50))
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  // hard mode
  int evaluateBoard() {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (gameBoard[row][0] == gameBoard[row][1] &&
          gameBoard[row][1] == gameBoard[row][2]) {
        if (gameBoard[row][0] == Player.O) {
          return 1;
        } else if (gameBoard[row][0] == Player.X) {
          return -1;
        }
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      if (gameBoard[0][col] == gameBoard[1][col] &&
          gameBoard[1][col] == gameBoard[2][col]) {
        if (gameBoard[0][col] == Player.O) {
          return 1;
        } else if (gameBoard[0][col] == Player.X) {
          return -1;
        }
      }
    }

    // Check diagonals
    if (gameBoard[0][0] == gameBoard[1][1] &&
        gameBoard[1][1] == gameBoard[2][2]) {
      if (gameBoard[0][0] == Player.O) {
        return 1;
      } else if (gameBoard[0][0] == Player.X) {
        return -1;
      }
    }

    if (gameBoard[0][2] == gameBoard[1][1] &&
        gameBoard[1][1] == gameBoard[2][0]) {
      if (gameBoard[0][2] == Player.O) {
        return 1;
      } else if (gameBoard[0][2] == Player.X) {
        return -1;
      }
    }

    // No one has won
    return 0;
  }

  int minimax(int depth, bool isMaximizingPlayer) {
    int score = evaluateBoard();

    // If the maximizing player has won the game return his/her score
    if (score == 1) {
      return score;
    }

    // If the minimizing player has won the game return his/her score
    if (score == -1) {
      return score;
    }

    // If there are no more moves and no winner then it is a tie
    if (!gameBoard.any((row) => row.contains(null))) {
      return 0;
    }

    // If this maximizer's move
    if (isMaximizingPlayer) {
      int bestScore = -1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          // Check if cell is empty
          if (gameBoard[i][j] == null) {
            // Make the move
            gameBoard[i][j] = Player.O;

            // Call minimax recursively and choose the maximum value
            bestScore = max(bestScore, minimax(depth + 1, !isMaximizingPlayer));

            // Undo the move
            gameBoard[i][j] = null;
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          // Check if cell is empty
          if (gameBoard[i][j] == null) {
            // Make the move
            gameBoard[i][j] = Player.X;

            // Call minimax recursively and choose the minimum value
            bestScore = min(bestScore, minimax(depth + 1, !isMaximizingPlayer));

            // Undo the move
            gameBoard[i][j] = null;
          }
        }
      }
      return bestScore;
    }
  }
}

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 10
      ..style = PaintingStyle
          .stroke; // This makes it an outline (i.e., a circle instead of a filled circle)

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Move {
  int row, col;

  Move(this.row, this.col);
}
