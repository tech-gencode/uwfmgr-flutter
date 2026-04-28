// lib/utils/system_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';


class SystemUtils {
  /// Verifica se l'app è in esecuzione come amministratore
  static Future<bool> isAdmin() async {
    if (!Platform.isWindows) return false;

    try {
      final result = await Process.run('net', ['session']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Esegue un comando di sistema
  static Future<int> execute(String executable, List<String> arguments) async {
    if (!Platform.isWindows) {
      debugPrint("Comando Windows ignorato su piattaforma non Windows.");
      await Future.delayed(const Duration(milliseconds: 100));
      return 0;
    }

    try {
      final result = await Process.run(executable, arguments);

      if (result.exitCode != 0) {
        debugPrint(
          "Errore comando $executable (Exit ${result.exitCode})",
        );
        debugPrint("STDERR: ${result.stderr}");
      }

      return result.exitCode;
    } catch (e) {
      debugPrint("Eccezione processo $executable: $e");
      return -1;
    }
  }

  /// Pulizia completa stile batch
  static Future<void> runFullCleanup(WidgetRef ref) async {
    final isAdmin = await SystemUtils.isAdmin();

    // Blocca subito se non admin
    if (!isAdmin) {
      debugPrint("Permessi insufficienti: esegui come amministratore.");
      return;
    }

    ref.read(isCleaningProvider.notifier).state = true;
    ref.read(cleaningProgressProvider.notifier).state = 0.0;

    try {
      double progress = 0.0;

      /// ------------------------------------------------------------
      /// 1. Pulizia cestini
      /// ------------------------------------------------------------
      final List<(String, List<String>)> recycleCommands = [
        ('cmd', ['/c', 'rd', '/s', '/q', 'c:\\\$Recycle.Bin']),
        ('cmd', ['/c', 'rd', '/s', '/q', 'd:\\\$Recycle.Bin']),
      ];

      for (final cmd in recycleCommands) {
        await execute(cmd.$1, cmd.$2);

        progress += 0.1;
        ref.read(cleaningProgressProvider.notifier).state = progress;

        await Future.delayed(const Duration(milliseconds: 200));
      }

      /// ------------------------------------------------------------
      /// 2. Pulizia COMPLETA Event Logs
      /// ------------------------------------------------------------
      debugPrint("Recupero lista Event Logs...");

      final logsResult = await Process.run('wevtutil.exe', ['el']);

      if (logsResult.exitCode != 0) {
        debugPrint("Errore recupero logs");
        return;
      }

      final logs = (logsResult.stdout as String)
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final totalLogs = logs.length;

      debugPrint("Totale logs trovati: $totalLogs");

      for (int i = 0; i < totalLogs; i++) {
        final logName = logs[i];

        debugPrint("Pulizia log: $logName");

        await execute('wevtutil.exe', ['cl', logName]);

        // Progress dinamico (dal 20% al 100%)
        final logProgress = (i + 1) / totalLogs;
        ref.read(cleaningProgressProvider.notifier).state =
            0.2 + (logProgress * 0.8);

        await Future.delayed(const Duration(milliseconds: 50));
      }

      debugPrint("Pulizia completata!");
    } catch (e) {
      debugPrint("Errore critico: $e");
    } finally {
      ref.read(cleaningProgressProvider.notifier).state = 1.0;

      await Future.delayed(const Duration(milliseconds: 500));

      ref.read(isCleaningProvider.notifier).state = false;
      ref.read(cleaningProgressProvider.notifier).state = 0.0;
    }
  }
}