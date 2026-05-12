import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/system_service.dart';
import '../models/uwf_status.dart';
import '../models/ping_status.dart';
import '../utils/system_utils.dart';

/// --------------------------------------------------------------------------
/// STATE MANAGEMENT
/// --------------------------------------------------------------------------

final systemServiceProvider = Provider((ref) => SystemService());

final deviceTypeProvider = StateProvider<String?>((ref) => null);

final isAdminProvider = FutureProvider<bool>((ref) async {
  return await SystemUtils.isAdmin();
});

// UWF Notifier
final uwfProvider = StateNotifierProvider<UwfNotifier, AsyncValue<UwfStatus>>((
  ref,
) {
  return UwfNotifier(ref.watch(systemServiceProvider));
});


class UwfNotifier extends StateNotifier<AsyncValue<UwfStatus>> {
  final SystemService _service;
  
  UwfNotifier(this._service) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    // Aggiungiamo un piccolo delay per evitare race conditions all'avvio dell'app
    await Future.delayed(const Duration(milliseconds: 500));
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final status = await _service.getUwfStatus();
      state = AsyncData(status);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> toggleProtection(bool enable) async {
    try {
      await _service.toggleUwf(enable);
      // Breve attesa per permettere al sistema di riflettere il comando
      await Future.delayed(const Duration(seconds: 1));
      await refresh();
      return true;
    } catch (e) {
      debugPrint("Errore toggle: $e");
      return false;
    }
  }
}

// Network Notifier
final networkProvider =
    StateNotifierProvider<NetworkNotifier, List<PingStatus>>((ref) {
      return NetworkNotifier(ref.watch(systemServiceProvider));
    });

class NetworkNotifier extends StateNotifier<List<PingStatus>> {
  final SystemService _service;
  Timer? _timer;

  NetworkNotifier(this._service) : super([]) {
    _loadAndPing();
    // Aggiornamento ogni 5 secondi
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadAndPing());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> pingAll() async {
    await _loadConfiguredDevices();
    if (!mounted || state.isEmpty) return;

    final futures = state.map((item) async {
      final isOnline = await _service.pingAddress(item.ip);
      return PingStatus(ip: item.ip, isOnline: isOnline);
    });

    final results = await Future.wait(futures);
    if (mounted) state = results;
  }

  Future<void> _loadAndPing() async {
    await pingAll();
  }

  Future<void> _loadConfiguredDevices() async {
    final ips = await _service.loadNetworkIps();
    final currentStatusByIp = {for (final item in state) item.ip: item.isOnline};
    final nextState = ips
        .map(
          (ip) => PingStatus(ip: ip, isOnline: currentStatusByIp[ip] ?? false),
        )
        .toList();

    if (!mounted) return;
    state = nextState;
  }
}

// UI/Keyboard State Providers
final keyboardVisibleProvider = StateProvider<bool>((ref) => false);
final activeTextControllerProvider = StateProvider<TextEditingController?>(
  (ref) => null,
);

// Stato booleano: true se la pulizia è in corso
final isCleaningProvider = StateProvider<bool>((ref) => false);

// Stato numerico: progresso della pulizia (0.0 a 1.0)
final cleaningProgressProvider = StateProvider<double>((ref) => 0.0);

// Provider derivato per il blocco (come fatto prima)
final isSystemLockedProvider = Provider<bool>((ref) {
  final uwfAsyncValue = ref.watch(uwfProvider);
  return uwfAsyncValue.maybeWhen(
    data: (status) => status.isEnabled,
    orElse: () => false,
  );
});

// IL NUOVO CONTROLLER: Gestisce la logica di pulizia in sicurezza
final cleanupControllerProvider = Provider((ref) => CleanupController(ref));

// ---------------------------------------------------------------------------
// SERVICING / WINDOWS UPDATE STATE
// ---------------------------------------------------------------------------

/// StartType originali (per ripristino) catturati prima del servicing.
final windowsUpdateOriginalStartTypesProvider =
    StateProvider<Map<String, String>?>((ref) => null);

/// true se il flusso di servicing è in corso.
final isServicingProvider = StateProvider<bool>((ref) => false);

/// Progresso (0..1) per UI.
final servicingProgressProvider = StateProvider<double>((ref) => 0.0);

/// Log testuale per UI.
final servicingLogProvider = StateProvider<String>((ref) => '');

final servicingControllerProvider = Provider((ref) => ServicingController(ref));

class ServicingController {
  final Ref ref;

  ServicingController(this.ref);

  SystemService get _service => ref.read(systemServiceProvider);

  void _appendLog(String line) {
    final current = ref.read(servicingLogProvider);
    final ts = DateTime.now().toIso8601String().split('.').first;
    ref.read(servicingLogProvider.notifier).state =
        (current.isEmpty ? '' : '$current\n') + '[$ts] $line';
  }

  Future<void> captureStateIfNeeded() async {
    final existing = ref.read(windowsUpdateOriginalStartTypesProvider);
    if (existing != null && existing.isNotEmpty) {
      _appendLog('Stato già presente (skip).');
      return;
    }
    _appendLog('Salvataggio stato servizi Windows Update...');
    final captured = await _service.captureWindowsUpdateServiceStartTypes();
    ref.read(windowsUpdateOriginalStartTypesProvider.notifier).state = captured;
    _appendLog('Stato salvato: ${captured.isEmpty ? "vuoto" : captured.keys.join(", ")}');
  }

  Future<void> enableWindowsUpdate() async {
    _appendLog('Riattivo servizi Windows Update...');
    await _service.enableWindowsUpdateServices();
    _appendLog('Servizi riattivati (best-effort).');
  }

  Future<void> startUpdates() async {
    _appendLog('Avvio workflow aggiornamenti (scan/download/install)...');
    await _service.startWindowsUpdateWorkflow();
    _appendLog('Comandi aggiornamento inviati.');
  }

  Future<void> openWindowsUpdate() async {
    _appendLog('Apro Windows Update (UI)...');
    await _service.openWindowsUpdateSettings();
  }

  Future<void> restoreWindowsUpdate() async {
    final captured = ref.read(windowsUpdateOriginalStartTypesProvider) ?? {};
    if (captured.isEmpty) {
      _appendLog('Nessuno stato salvato: ripristino non eseguito.');
      return;
    }
    _appendLog('Ripristino configurazione servizi Windows Update...');
    await _service.restoreWindowsUpdateServices(captured);
    _appendLog('Ripristino completato (best-effort).');
  }

  /// Flusso guidato: salva stato → abilita → avvia aggiornamenti → apre UI.
  /// Nota: il ripristino è manuale (bottone dedicato), perché gli update possono durare/rebootare.
  Future<void> runGuidedFlow() async {
    ref.read(isServicingProvider.notifier).state = true;
    ref.read(servicingProgressProvider.notifier).state = 0.0;
    try {
      await captureStateIfNeeded();
      ref.read(servicingProgressProvider.notifier).state = 0.25;

      await enableWindowsUpdate();
      ref.read(servicingProgressProvider.notifier).state = 0.55;

      await startUpdates();
      ref.read(servicingProgressProvider.notifier).state = 0.80;

      await openWindowsUpdate();
      ref.read(servicingProgressProvider.notifier).state = 1.0;
      _appendLog('Flusso guidato completato. Quando finito, usa "Ripristina configurazione".');
    } catch (e) {
      _appendLog('Errore servicing: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      ref.read(isServicingProvider.notifier).state = false;
    }
  }
}

class CleanupController {
  final Ref ref; // Usiamo Ref di Riverpod, non WidgetRef!

  CleanupController(this.ref);

  Future<void> runFullCleanup() async {
    // 1. Imposta lo stato su IN CORSO
    ref.read(isCleaningProvider.notifier).state = true;
    ref.read(cleaningProgressProvider.notifier).state = 0.0;

    // Lista fasi
    final List<(String, double, Future<int> Function())> phases = [
      (
        "Cestino (C:)",
        0.30,
        () => SystemUtils.execute('cmd', [
          '/c',
          'rd',
          '/s',
          '/q',
          'c:\\\$Recycle.Bin',
        ]),
      ),
      (
        "Cestino (D:)",
        0.30,
        () => SystemUtils.execute('cmd', [
          '/c',
          'rd',
          '/s',
          '/q',
          'd:\\\$Recycle.Bin',
        ]),
      ),
      (
        "Event Logs (System)",
        0.10,
        () => SystemUtils.execute('wevtutil.exe', ['cl', 'System']),
      ),
      (
        "Event Logs (Application)",
        0.10,
        () => SystemUtils.execute('wevtutil.exe', ['cl', 'Application']),
      ),
      (
        "Event Logs (Security)",
        0.20,
        () => SystemUtils.execute('wevtutil.exe', ['cl', 'Security']),
      ),
    ];

    double currentProgress = 0.0;

    try {
      for (var (name, weight, command) in phases) {
        debugPrint("Inizio fase: $name");

        // Esegue il comando
        await command();

        // Aggiorna il progresso
        currentProgress += weight;

        // --- QUI AVVENIVA IL CRASH PRIMA ---
        // Ora è sicuro perché usiamo 'ref' del ProviderContainer, che esiste sempre.
        ref.read(cleaningProgressProvider.notifier).state = currentProgress
            .clamp(0.0, 1.0);

        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint("Errore pulizia: $e");
    } finally {
      // Reset finale
      ref.read(cleaningProgressProvider.notifier).state = 1.0;
      await Future.delayed(const Duration(milliseconds: 800));
      ref.read(isCleaningProvider.notifier).state = false;
      ref.read(cleaningProgressProvider.notifier).state = 0.0;
    }
  }
}
