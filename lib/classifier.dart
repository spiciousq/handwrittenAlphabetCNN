import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:typed_data';

class Classifier {
  Classifier();

  Future<String> classifyDrawing(List<Offset> points) async {
    final picture = toPicture(points); // Convert list to Picture
    final image = await picture.toImage(28, 28);
    ByteData? imgBytes = await image.toByteData();

    if (imgBytes != null) {
      var imgAsList = imgBytes.buffer.asUint8List();
      return getPred(imgAsList);
    } else {
      // Handle the case when imgBytes is null
      throw Exception("Failed to convert image to byte data.");
    }
  }

  Future<String> getPred(Uint8List imgAsList) async {
  List<double> resultBytes = List<double>.filled(28 * 28, 0);

  int index = 0;

  for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
    final r = imgAsList[i];
    final g = imgAsList[i + 1];
    final b = imgAsList[i + 2];

    resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
    index++;
  }

  var input = resultBytes.reshape([1, 28, 28, 1]);
  var output = List.filled(1 * 26, 0).reshape([1, 26]);

  InterpreterOptions interpreterOptions = InterpreterOptions();

  try {
    Interpreter interpreter = await Interpreter.fromAsset(
      'emnist_model_lower.tflite',
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
    String predictedLetter = String.fromCharCode(letterPred + 65);
    return predictedLetter.toUpperCase(); // Convert to uppercase
  } else if (letterPred >= 26 && letterPred < 52) {
    // Lowercase a to z
    String predictedLetter = String.fromCharCode(letterPred + 71);
    return predictedLetter.toLowerCase(); // Convert to lowercase
  } else {
    // Handle the case when the predicted letter is outside the valid range
    return ''; // Return empty string or handle it as per your requirement
  }
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
