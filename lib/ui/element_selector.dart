import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ElementSelector extends StatefulWidget {
  final XFile imageFile;
  final RecognizedText recognizedText;

  const ElementSelector(
      {super.key, required this.imageFile, required this.recognizedText});

  @override
  State<ElementSelector> createState() => _ElementSelectorState();
}

class _ElementSelectorState extends State<ElementSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Found something!'),),
      body: ListView(
        children: widget.recognizedText.blocks
            .map<Widget>((textBlock) => Text(textBlock.text))
            .toList(growable: false),
      ),
    );
  }
}
