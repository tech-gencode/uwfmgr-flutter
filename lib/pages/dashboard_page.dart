import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../providers/providers.dart';
import '../models/uwf_status.dart';


/// --------------------------------------------------------------------------
/// PAGE: DASHBOARD
/// --------------------------------------------------------------------------

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uwfAsync = ref.watch(uwfProvider);
    final adminAsync = ref.watch(isAdminProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.uwfStateTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        uwfAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, stack) => Text(
                "Status Error: $err",
                style: const TextStyle(color: Colors.red),
              ),
          data: (status) {
            final isReallyProtected =
                status.hasPendingProtectionChange
                    ? status.isNextSessionProtected
                    : status.isCurrentSessionProtected;

            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildStatusCard(
                      context,
                      ref,
                      status,
                      isReallyProtected,
                      adminAsync,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildDetailCard(
                          "Overlay",
                          status.overlayMode,
                          Icons.layers,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          Strings.dimensionUWF,
                          status.overlaySize,
                          Icons.data_usage,
                        ),
                        const SizedBox(height: 16),
                        _buildExclusionsCard(status.exclusions),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    UwfStatus status,
    bool isProtected,
    AsyncValue<bool> adminAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProtected ? Icons.lock : Icons.lock_open_rounded,
            size: 80,
            color: isProtected ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 20),
          Text(
            isProtected ? Strings.uwfProtected : Strings.uwfUnprotected,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            isProtected ? Strings.uwfDescProtected : Strings.uwfDescUnprotected,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isProtected ? Colors.redAccent : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async { // 1. Aggiungi async qui
              // Recuperiamo isAdmin dai dati dell'async value
              final isAdmin = adminAsync.value ?? false;

              if (!isAdmin) {
                // Se non è admin, non facciamo nulla (o mostriamo un avviso)
                return;
              }

              // 2. Esegui il toggle e attendi il risultato
              // Nota: ho aggiunto 'await' e salvato il risultato in 'success'
              bool success = await ref.read(uwfProvider.notifier).toggleProtection(!isProtected);

              // 3. Se il comando è riuscito, mostriamo il Dialog
              if (success && context.mounted) {
                _showRebootDialog(context, ref);
              }
            },
            
            child: 
            adminAsync.when(
                data: (isAdmin) => Text(
                !isAdmin
                  ? Strings.requiresAdmin
                  : (isProtected ? Strings.btnDisable : Strings.btnEnable),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => Text(Strings.checkingPermissions),
                error: (_, __) => Text(Strings.permissionError),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kAccentColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExclusionsCard(List<String> exclusions) {
    return Container(
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
            Strings.exceptions,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (exclusions.isEmpty)
            Text(
              Strings.noExceptions,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          // Utilizza ListView.builder per evitare overflow con molte eccezioni,
          // anche se in questo contesto un Column con ...map è accettabile
          ...exclusions.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showRebootDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(Strings.rebootRequired),
        content: Text(Strings.rebootUwfMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Strings.btnLater),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(systemServiceProvider).rebootSystem();
            },
            child: Text(
              Strings.btnRebootNow, 
              style: const TextStyle(color: Colors.white)
            ),
          ),
        ],
      ),
    );
  }
}
