import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp/uppercase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fyp/lowercase_classifier.dart';
import 'package:fyp/lowercase.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class LowercasePage extends StatefulWidget {
  @override
  _LowercasePageState createState() => _LowercasePageState();
}

class _LowercasePageState extends State<LowercasePage> {
  LowercaseClassifier classifier = LowercaseClassifier();
  List<Offset> points = []; // List of points
  List<List<Offset>> lines = []; // List of lines
  String letter = ''; // Updated variable type to String
  String userInput = '';
  String selectedOption = 'lowercase'; // Default selected option

  int currentPage = 0;
 List<String> alphabet = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
];

  void clearCanvas() {
    points.clear();
    lines.clear();
    letter = ''; // Clear the letter
  }

  void goToNextPage() {
    if (currentPage < alphabet.length - 1) {
      currentPage++;
      userInput = alphabet[currentPage];
      clearCanvas();
      setState(() {});
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      currentPage--;
      userInput = alphabet[currentPage];
      clearCanvas();
      setState(() {});
    }
  }

  @override
  void initState() {
    userInput = alphabet[currentPage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Lowercase Alphabet"),
        foregroundColor: Colors.deepOrange,
        centerTitle: true,
        toolbarHeight: 100,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color.fromRGBO(255, 241, 118, 1.0),
      ),
      body: Center(
        child: Column(
          children: [
              SizedBox(
              height: 20,
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'uppercase',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value!;
                    });
                    if (value == 'uppercase') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DrawPage()),
                      );
                    }
                  },
                ),
                Text('Uppercase Letter'),
                SizedBox(width: 20),
                Radio<String>(
                  value: 'lowercase',
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value!;
                    });
                    if (value == 'lowercase') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LowercasePage()),
                      );
                    }
                  },
                ),
                Text('Lowercase Letter'),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Draw $userInput",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails details) {
                  setState(() {
                    points = []; // Clear the points
                    points.add(details.localPosition); // Add the initial point to the list
                    lines.add(List.from(points)); // Add the initial point as a line
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    points.add(details.localPosition); // Add points to the list
                    lines[lines.length - 1] = List.from(points); // Update the last line with the new points
                  });
                },
                onPanEnd: (DragEndDetails details) async {
                  setState(() {
                    // Update the UI if needed
                  });
                },
                child: CustomPaint(
                  painter: Painter(lines: lines),
                  size: Size.fromHeight(300),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                ElevatedButton(
                 onPressed: () async {
                  if (points.isNotEmpty) {
                    // Make the prediction
                                  // Concatenate all lines into a single list of points
                    List<Offset> allPoints = [];
                    for (List<Offset> line in lines) {
                      allPoints.addAll(line);
                    }
                    String predictedLetter = await classifier.classifyDrawing(allPoints);
                    print('Predicted letter: $predictedLetter');

                    // Compare predicted letter with user's input
                    bool isMatched = classifier.compareLetters(predictedLetter, userInput);

                    // Display the result
                    String resultText = isMatched ? "TRUE" : "FALSE";
                    setState(() {
                      letter = resultText;
                    });
                  }
                },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  child: Text(
                    "Recognize",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                 SizedBox(width: 20),
                ElevatedButton(
                  onPressed: clearCanvas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
               
              ],
            ),
            SizedBox(
              height: 30,
            ),
          

            Text(
            letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // You can set the color as per your requirement
            ),
          ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: goToPreviousPage,
              child: Text(
                'Previous',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: goToNextPage,
              child: Text(
                'Next',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class Painter extends CustomPainter {
  final List<List<Offset>> lines;

  Painter({required this.lines});

  final Paint paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect canvasRect = Offset.zero & size;
    final Path clipPath = Path()..addRect(canvasRect);
    canvas.clipPath(clipPath);

    for (final line in lines) {
      if (line.length > 1) {
        for (int i = 0; i < line.length - 1; i++) {
          if (line[i] != null && line[i + 1] != null) {
            canvas.drawLine(line[i], line[i + 1], paintDetails);
          }
        }
      }
    }

    if (lines.isNotEmpty && lines.last.isNotEmpty) {
      canvas.drawLine(lines.last.last, lines.last.last, paintDetails);
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return true;
  }
}



void main() {
  runApp(MaterialApp(
    home: LowercasePage(),
  ));
}