import 'package:tflite/tflite.dart';

class Recognizer {
  Future loadModel() {
    Tflite.close();
    return Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assests/model.txt",
    );
  }
}
