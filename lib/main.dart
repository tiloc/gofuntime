import 'package:camera/camera.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gofuntime/ui/capture_sign_board.dart';
import 'package:google_fonts/google_fonts.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: This is shitty. Camera View should be self-contained.
  cameras = await availableCameras();

  runApp(const FuntimeApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => CaptureSignBoard(cameras: cameras,),
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
          ).copyWith(textTheme: GoogleFonts.indieFlowerTextTheme(),),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ).copyWith(textTheme: GoogleFonts.indieFlowerTextTheme(),),
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        ),
      );
}
