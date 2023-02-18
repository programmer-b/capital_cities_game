import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Future<void> guardWithCrashLytics(void Function() mainFunction,
    {required FirebaseCrashlytics? crashlytics}) async {
  await runZonedGuarded<Future<void>>(() async {
    if (kDebugMode) {
      Logger.root.level = Level.FINE;
    }
    Logger.root.onRecord.listen((event) {
      final message = '${event.level.name} : ${event.time}';
      debugPrint(message);
      log(message);

      crashlytics?.log(message);

      if (event.level == Level.SEVERE) {
        crashlytics?.recordError(message, filterStackTrace(StackTrace.current),
            fatal: true);
      }
    });

    if (crashlytics != null) {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = crashlytics.recordFlutterFatalError;
    }
    if (kIsWeb) {
      Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
        final errorAndStackTrace = pair as List<dynamic>;
        await crashlytics?.recordError(
            errorAndStackTrace.first, errorAndStackTrace.last as StackTrace?,
            fatal: true);
      }).sendPort);
    }
    mainFunction();
  }, (error, stack) {});
}

@visibleForTesting
StackTrace filterStackTrace(StackTrace stackTrace) {
  try {
    final lines = stackTrace.toString().split('\n');
    final buf = StringBuffer();

    for (final line in lines) {
      if (line.contains('crashlytic.dart') ||
          line.contains('_BroadcastStreamController.java') ||
          line.contains('logger.dart')) {
        continue;
      }
      buf.writeln(line);
    }
    return StackTrace.fromString(buf.toString());
  } catch (e) {
    log('Problem while filtering stack trace: $e');
  }

  return stackTrace;
}
