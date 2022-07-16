import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gofuntime/ui/capture_sign_board.dart';

void main() {
  runApp(const FuntimeApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const CaptureSignBoard(),
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
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        ),
      );
}
