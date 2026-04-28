// lib/widgets/apple_maintenance_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/strings.dart';
import '../core/constants.dart'; // Assicurati che kAccentColor e kBorderRadius siano qui
import '../providers/providers.dart';
import '../utils/system_utils.dart';

class CleanUpButtonWidget extends ConsumerWidget {
  const CleanUpButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCleaning = ref.watch(isCleaningProvider);
    final progress = ref.watch(cleaningProgressProvider);
    final adminAsync = ref.watch(isAdminProvider);
    final isLocked = ref.watch(
      uwfProvider.select(
        (uwfState) => uwfState.asData?.value.isEnabled ?? false,
      ),
    );

    // Colori in stile Apple
    const cardColor = Colors.white;
    const textColor = Color(0xFF1D1D1F);
    const subTextColor = Color(0xFF86868B);

    // Se è bloccato da UWF o se sta pulendo, disabilitiamo l'interazione
    final bool isActionDisabled = adminAsync.maybeWhen(
      data: (isAdmin) => !isAdmin || isCleaning,
      orElse: () => true,
    );

    return Container(
      width: 400, // Larghezza fissa per un look "Card"
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(
          20,
        ), // Bordi molto arrotondati (Apple style)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Icona Superiore (Stile iOS App Icon)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00C6FB),
                  Color(0xFF005BEA),
                ], // Gradiente Blu Apple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005BEA).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isCleaning
                  ? Icons.autorenew_rounded
                  : Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 20),

          // 2. Titolo e Descrizione
          Text(
            Strings.maintenanceTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Strings.maintenanceSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: subTextColor,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 30),

          // 3. Area di Progresso / Stato
          if (isCleaning) ...[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.cleaningInProgress,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(
                      0xFFF2F2F7,
                    ), // Grigio chiaro Apple
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      kAccentColor,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Stato di riposo o completato
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: progress >= 1.0 ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    progress >= 1.0
                        ? Strings.cleaningCompleted
                        : Strings.statusIdle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          progress >= 1.0
                              ? Colors.green[700]
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          // 4. Bottone Principale (Stile iOS/macOS filled button)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  isActionDisabled
                      ? null
                      : () =>
                          ref.read(cleanupControllerProvider).runFullCleanup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                elevation: 0, // Apple style è flat
                disabledBackgroundColor: kAccentColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: adminAsync.when(
                data: (isAdmin) => Text(
                  isAdmin
                      ? Strings.startMaintenance
                      : Strings.requiresAdmin,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => Text(Strings.checkingPermissions),
                error: (_, __) => Text(Strings.permissionError),
              ),
            ),
          ),

          if (isLocked) ...[
            const SizedBox(height: 12),
            Text(
              Strings.uwfProtected,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
