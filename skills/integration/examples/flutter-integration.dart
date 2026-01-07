import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifly_flutter/notifly_flutter.dart';

// Flutter 인앱 팝업 이벤트 예시(공식 문서 스니펫):
// https://docs.notifly.tech/ko/advanced/inapp-popup-event-listener.md
//
// 참고:
// - 먼저 Notifly를 초기화하세요.
// - NotiflyPlugin.inAppEvents.listen(...)로 인앱 이벤트를 구독하세요.

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
    // Notifly SDK 초기화
    await NotiflyPlugin.initialize(
      projectId: 'YOUR_PROJECT_ID',
      username: 'YOUR_USERNAME',
      password: 'YOUR_PASSWORD',
    );

    // 인앱 메시지 이벤트 구독
    _subscription = NotiflyPlugin.inAppEvents.listen(
      (event) {
        print('인앱 메시지 이벤트 발생: ${event.eventName}');
        print('이벤트 파라미터: ${event.eventParams}');

        // 이벤트별 처리
        switch (event.eventName) {
          case 'main_button_click':
            // 메인 버튼 클릭 처리
            break;
          case 'close_button_click':
            // 닫기 버튼 클릭 처리
            break;
        }
      },
      onError: (error, stackTrace) {
        print('인앱 메시지 이벤트 오류: $error');
        print('스택 트레이스: $stackTrace');
      },
      cancelOnError: false, // 오류가 발생해도 계속 수신
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
        body: Center(child: Text('Notifly Flutter 연동 예시')),
      ),
    );
  }
}
