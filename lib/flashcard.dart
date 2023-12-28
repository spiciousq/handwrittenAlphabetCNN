// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:just_audio/just_audio.dart';

class Flashcard extends StatefulWidget {
   final List<String> imageList;
   

  const Flashcard({Key? key, required this.imageList}) : super(key: key);

  @override
  _FlashcardState createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  int _currentIndex = 0;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Flashcards"),
        foregroundColor: Colors.deepOrange,
        centerTitle: true,
        toolbarHeight: 100,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        elevation: 0.00,
        backgroundColor: Color.fromRGBO(255, 241, 118, 1.0),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            SizedBox(height: 30.0),
            Container(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 350,
                  aspectRatio: 191 / 287,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                // items: widget.imageList.map((item) {
                //   return Container(
                //     child: Center(
                //       child: Image.asset(
                //         item,
                //         fit: BoxFit.cover,
                //         height: 287,
                //         width: 200,
                //       ),
                //     ),
                //   );
                // }).toList(),
                items: widget.imageList.map((item) {

                return Container(
  height: 350, // Adjust the height value as needed
  child: Column(
    children: [
      Image.asset(
        item,
        fit: BoxFit.cover,
        height: 287,
        width: 200,
      ),
      
    ],
  ),
);

                
              }).toList(),

              ),
            ),
            SizedBox(height: 60.0),
          
          ],
      ),
      ),
    );
  }
}
