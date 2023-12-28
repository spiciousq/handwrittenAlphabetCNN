import 'dart:convert' show json;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class UppercaseClassifier {
  UppercaseClassifier();

  Future<String> classifyDrawing(List<Offset> points) async {
    final picture = toPicture(points); // Convert list to Picture
    final image = await picture.toImage(28, 28);
    final imgBytes = await image.toByteData();

    if (imgBytes == null) {
      throw Exception("Failed to convert image to byte data.");
    }

    final imgAsList = imgBytes.buffer.asUint8List();
    print('Image bytes: $imgAsList');
    return _getPred(imgAsList);
  }

  Future<Map<int, String>> loadLabelToCharMapping() async {
    String jsonString =
        await rootBundle.loadString('assets/label_to_char.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    Map<int, String> mapping = {};
    jsonMap.forEach((key, value) {
      mapping[int.parse(key)] = value as String;
    });
    return mapping;
  }

  Future<Map<String, int>> loadCharToLabelMapping() async {
    String jsonString =
        await rootBundle.loadString('assets/char_to_label.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    Map<String, int> mapping = {};
    jsonMap.forEach((key, value) {
      mapping[key] = int.parse(value.toString());
    });
    return mapping;
  }

  Future<String> _getPred(Uint8List imgAsList) async {
    List<double> resultBytes = List<double>.filled(28 * 28, 0);
    Map<int, String> labelToCharMapping = await loadLabelToCharMapping();
    Map<String, int> charToLabelMapping = await loadCharToLabelMapping();

    int index = 0;

    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
      index++;
    }

    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1 * 52, 0).reshape([1, 52]);

    InterpreterOptions interpreterOptions = InterpreterOptions();

    try {
      Interpreter interpreter = await Interpreter.fromAsset(
        'emnist_model_alphabet.tflite',
        options: interpreterOptions,
      );
      interpreter.run(input, output);
    } catch (e) {
      print("Error loading model or running model: $e");
    }

    double highestProb = 0;
    int letterPred = 0; // Assign a default value

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        letterPred = i;
      }
    }

    if (letterPred >= 0 && letterPred < 26) {
      // Uppercase A to Z
      String predictedLetter = labelToCharMapping[letterPred]!;
      return predictedLetter.toUpperCase(); // Convert to uppercase
    } else if (letterPred >= 26 && letterPred < 52) {
      // Lowercase a to z
      String predictedLetter = labelToCharMapping[letterPred - 26]!;
      return predictedLetter.toLowerCase(); // Convert to lowercase
    } else {
      // Handle the case when the predicted label is outside the valid range
      return ''; // Return empty string or handle it as per your requirement
    }
  }

  ui.Picture toPicture(List<Offset> points) {
    final _whitePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..strokeWidth = 16.0;

    final _bgPaint = Paint()..color = Colors.black;
    final _canvasCullRect = Rect.fromPoints(Offset(0, 0), Offset(28.0, 28.0));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, _canvasCullRect)..scale(28 / 300);

    canvas.drawRect(Rect.fromLTWH(0, 0, 28, 28), _bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], _whitePaint);
      }
    }

    return recorder.endRecording();
  }

  bool compareLetters(String predictedLetter, String userInput) {
    return predictedLetter.toUpperCase() == userInput.toUpperCase();
  }
}
