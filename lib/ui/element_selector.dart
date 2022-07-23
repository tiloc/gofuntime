import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ElementSelector extends StatefulWidget {
  final XFile imageFile;

  const ElementSelector({super.key, required this.imageFile});

  @override
  State<ElementSelector> createState() => _ElementSelectorState();
}

class _ElementSelectorState extends State<ElementSelector> {
  @override
  Widget build(BuildContext context) {
    return Material(child: Text('Element-Selector'),);
  }
}
