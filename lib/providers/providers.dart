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
