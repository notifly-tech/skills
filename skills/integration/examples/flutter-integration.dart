import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifly_flutter/notifly_flutter.dart';

// Flutter in-app popup events example (official docs snippet):
// https://docs.notifly.tech/ko/advanced/inapp-popup-event-listener.md
//
// Notes:
// - Initialize Notifly first.
// - Subscribe to in-app events via NotiflyPlugin.inAppEvents.listen(...)

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _initNotifly();
  }

  Future _initNotifly() async {
    // Initialize Notifly SDK
    await NotiflyPlugin.initialize(
      projectId: 'YOUR_PROJECT_ID',
      username: 'YOUR_USERNAME',
      password: 'YOUR_PASSWORD',
    );

    // Subscribe to in-app message events
    _subscription = NotiflyPlugin.inAppEvents.listen(
      (event) {
        print('InAppMessage event dispatched: ${event.eventName}');
        print('Event params: ${event.eventParams}');

        // Handle specific events
        switch (event.eventName) {
          case 'main_button_click':
            // Handle main button click
            break;
          case 'close_button_click':
            // Handle close button click
            break;
        }
      },
      onError: (error, stackTrace) {
        print('InAppMessage event error: $error');
        print('Stack trace: $stackTrace');
      },
      cancelOnError: false, // Continue listening even after an error
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Notifly Flutter Integration Example')),
      ),
    );
  }
}
