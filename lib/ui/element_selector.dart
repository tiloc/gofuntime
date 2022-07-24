import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class ElementSelector extends StatefulWidget {
  final XFile imageFile;
  final RecognizedText recognizedText;

  const ElementSelector(
      {super.key, required this.imageFile, required this.recognizedText});

  @override
  State<ElementSelector> createState() => _ElementSelectorState();
}

class _ElementSelectorState extends State<ElementSelector> {
  final titleNode = FocusNode(debugLabel: 'title');
  final descriptionNode = FocusNode(debugLabel: 'description');
  final locationNode = FocusNode(debugLabel: 'location');
  final timeProseNode = FocusNode(debugLabel: 'timeProse');
  final beginNode = FocusNode(debugLabel: 'begin');
  final endNode = FocusNode(debugLabel: 'end');

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final timeProseController = TextEditingController();
  final beginController = TextEditingController();
  final endController = TextEditingController();

  DateTime? beginDateTime;
  DateTime? endDateTime;

  final _modelManager = EntityExtractorModelManager();
  final _entityExtractor =
      EntityExtractor(language: EntityExtractorLanguage.german);

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    timeProseController.dispose();
    beginController.dispose();
    endController.dispose();
    _entityExtractor.close().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("What's the 411?"),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(children: [
          FocusTraversalGroup(
            child: Form(
              child: Wrap(
                children: [
                  TextFormField(
                    focusNode: titleNode,
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      hintText: 'How would you title the event?',
                      labelText: 'Title *',
                    ),
                  ),
                  TextFormField(
                    focusNode: descriptionNode,
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      hintText: 'How would you describe the event?',
                      labelText: 'Description',
                    ),
                  ),
                  TextFormField(
                    focusNode: locationNode,
                    controller: locationController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.pin_drop),
                      hintText: 'Where is the event?',
                      labelText: 'Location',
                    ),
                  ),
                  if (beginController.text.isEmpty)
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: timeProseNode,
                          controller: timeProseController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.date_range),
                            hintText: 'When is the event?',
                            labelText: 'Date / Time',
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await _extractDateTime();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.check_circle)),
                    ]),
                  if (beginController.text.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            focusNode: beginNode,
                            controller: beginController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Begin',
                              icon: Icon(Icons.date_range),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            focusNode: endNode,
                            controller: endController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'End',
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              beginController.text = '';
                              endController.text = '';
                              beginDateTime = null;
                              endDateTime = null;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.clear)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          if (!keyboardVisible)
            ExcludeFocus(
              // Tapping a chip should not de-focus the input fields
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 480,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: widget.recognizedText.blocks
                          .map<Widget>(
                            (textBlock) => OutlinedButton(
                              child: Text(textBlock.text),
                              onPressed: () {
                                final child =
                                    FocusScope.of(context).focusedChild;
                                final controller = (child == titleNode)
                                    ? titleController
                                    : (child == descriptionNode)
                                        ? descriptionController
                                        : (child == locationNode)
                                            ? locationController
                                            : (child == timeProseNode)
                                                ? timeProseController
                                                : (child == beginNode)
                                                    ? beginController
                                                    : endController;
                                String addtlText = '';
                                for (final line in textBlock.lines) {
                                  addtlText += (addtlText.isEmpty)
                                      ? line.text
                                      : ' ${line.text}';
                                }
                                final newText = (controller.text.isEmpty)
                                    ? controller.text = addtlText
                                    : controller.text += ' $addtlText';
                                controller.value = TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(offset: newText.length),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ),
          ButtonBar(
            children: [
              ElevatedButton(  // TODO: criteria for enablement
                  onPressed: () {
                    final event = _buildEvent(
                        title: titleController.text,
                        description: descriptionController.text,
                        location: locationController.text,
                        beginDateTime: beginDateTime!,
                        endDateTime: endDateTime ?? beginDateTime!);

                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: const Text('Create Event'))
            ],
          )
        ]),
      ),
    );
  }

  /// Fetch text from date field and try to extract entities for date and time range
  Future<void> _extractDateTime() async {
    final dateTimeFormatter = DateFormat.yMd().add_Hm();

    await _modelManager.downloadModel(EntityExtractorLanguage.german.name);
    final dateTimeText = _normalizeDateTime(timeProseController.text);
    final result = await _entityExtractor.annotateText(dateTimeText);
    if (result.isNotEmpty) {
      if (result[0].entities.length == 1 &&
          result[0].entities[0].type == EntityType.dateTime) {
        final timeInMillis =
            (result[0].entities[0] as DateTimeEntity).timestamp;
        beginDateTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
        final beginDateTimeString = dateTimeFormatter.format(beginDateTime!);
        beginController.value = TextEditingValue(
          text: beginDateTimeString,
          selection: TextSelection.fromPosition(
            TextPosition(offset: beginDateTimeString.length),
          ),
        );
      }
    }

    if (result.length == 2) {
      if (result[1].entities.length == 1 &&
          result[1].entities[0].type == EntityType.dateTime) {
        final timeInMillis =
            (result[1].entities[0] as DateTimeEntity).timestamp;
        // This is using the current day!!!! Need to combine begin date with end time.
        final endTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
        endDateTime = DateTime(beginDateTime!.year, beginDateTime!.month,
            beginDateTime!.day, endTime.hour, endTime.minute);
        final endDateTimeString = dateTimeFormatter.format(endDateTime!);
        endController.value = TextEditingValue(
          text: endDateTimeString,
          selection: TextSelection.fromPosition(
            TextPosition(offset: endDateTimeString.length),
          ),
        );
      }
    }
  }

  /// Normalize some artistic freedoms from typical sign boards that are not understood by ML Kit.
  String _normalizeDateTime(String words) => words
      .replaceAllMapped(
          RegExp(
              r'( )(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23)( |-)',
              caseSensitive: true),
          (Match m) => "${m[1]}${m[2]}:00${m[3]}")
      .replaceAllMapped(
          RegExp(
              r'(-)(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23)( )',
              caseSensitive: true),
          (Match m) => "${m[1]}${m[2]}:00${m[3]}")
      .replaceAllMapped(
          RegExp(
              r'(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23)[\.](00|15|30)',
              caseSensitive: true),
          (Match m) => "${m[1]}:${m[2]}");

  Event _buildEvent(
      {required String title,
      required String description,
      required String location,
      required DateTime beginDateTime,
      required DateTime endDateTime}) {
    return Event(
      title: title,
      description: description,
      location: location,
      startDate: beginDateTime,
      endDate: endDateTime,
      allDay: false,
    );
  }
}
