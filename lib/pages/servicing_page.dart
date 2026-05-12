import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../providers/providers.dart';

class ServicingPage extends ConsumerWidget {
  const ServicingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAsync = ref.watch(isAdminProvider);
    final isServicing = ref.watch(isServicingProvider);
    final progress = ref.watch(servicingProgressProvider);
    final log = ref.watch(servicingLogProvider);
    final hasCapturedState =
        (ref.watch(windowsUpdateOriginalStartTypesProvider) ?? {}).isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            Strings.servicingTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.servicingSubtitle,
                        style: TextStyle(color: Colors.grey[700], height: 1.3),
                      ),
                      const SizedBox(height: 16),
                      adminAsync.when(
                        data: (isAdmin) {
                          if (!isAdmin) {
                            return _warnCard(Strings.wuAdminRequired);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kAccentColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.all(14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: isServicing
                                          ? null
                                          : () => ref
                                              .read(servicingControllerProvider)
                                              .runGuidedFlow(),
                                      icon: const Icon(Icons.play_circle_fill),
                                      label: Text(Strings.wuRunFull),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (isServicing) ...[
                                LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(height: 14),
                              ],
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: isServicing
                                        ? null
                                        : () => ref
                                            .read(servicingControllerProvider)
                                            .captureStateIfNeeded(),
                                    icon: Icon(
                                      hasCapturedState
                                          ? Icons.check_circle
                                          : Icons.save,
                                    ),
                                    label: Text(Strings.wuCaptureState),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: isServicing
                                        ? null
                                        : () => ref
                                            .read(servicingControllerProvider)
                                            .enableWindowsUpdate(),
                                    icon: const Icon(Icons.power_settings_new),
                                    label: Text(Strings.wuEnable),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: isServicing
                                        ? null
                                        : () => ref
                                            .read(servicingControllerProvider)
                                            .startUpdates(),
                                    icon: const Icon(Icons.system_update_alt),
                                    label: Text(Strings.wuStart),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: isServicing
                                        ? null
                                        : () => ref
                                            .read(servicingControllerProvider)
                                            .openWindowsUpdate(),
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(Strings.wuOpenSettings),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: isServicing
                                        ? null
                                        : () => ref
                                            .read(servicingControllerProvider)
                                            .restoreWindowsUpdate(),
                                    icon: const Icon(Icons.restore),
                                    label: Text(Strings.wuRestore),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(),
                        ),
                        error: (_, __) => _warnCard(Strings.permissionError),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.wuLog,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 140),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          log.isEmpty ? '-' : log,
                          style: const TextStyle(
                            fontFamily: 'Consolas',
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _warnCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

