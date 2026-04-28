import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const targetSize = Size(800, 600);
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(800, 600),
    maximumSize: targetSize,
    center: false,
    title: 'UWF Manager Pro',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBounds(
      const Rect.fromLTWH(0, 0, 800, 600),
      animate: false,
    );
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: AppRoot()));
}
