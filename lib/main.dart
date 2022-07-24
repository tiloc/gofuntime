import 'package:camera/camera.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gofuntime/ui/capture_sign_board.dart';
import 'package:gofuntime/ui/element_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

List<CameraDescription> cameras = <CameraDescription>[];
XFile? currentImageFile;
RecognizedText? recognizedText;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(const FuntimeApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => CaptureSignBoard(
        cameras: cameras,
      ),
    ),
    GoRoute(
      path: '/select-elements',
      name: 'select-elements',
      builder: (context, state) => ElementSelector(
        imageFile: currentImageFile!,
        recognizedText: recognizedText!,// TODO: She-bang op = a cat dies!
      ),
    ),
  ],
);

class FuntimeApp extends StatelessWidget {
  const FuntimeApp({super.key});

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
        builder:
            (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) =>
                MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Go Funtime Now!',
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ).copyWith(
            textTheme: GoogleFonts.indieFlowerTextTheme(),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ).copyWith(
            textTheme: GoogleFonts.indieFlowerTextTheme(),
          ),
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        ),
      );
}
