import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../providers/providers.dart';

/// --------------------------------------------------------------------------
/// PAGE: NETWORK
/// --------------------------------------------------------------------------

class NetworkPage extends ConsumerWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(networkProvider);
    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.netMonitor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(networkProvider.notifier).pingAll(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(right: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: devices.length,
              itemBuilder: (ctx, index) {
                final device = devices[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    border: Border.all(
                      color:
                          device.isOnline
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.1),
                      width: device.isOnline ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: device.isOnline ? Colors.green : Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  device.isOnline
                                      ? Colors.green.withOpacity(0.4)
                                      : Colors.red.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.ip,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            device.isOnline ? "ONLINE" : "OFFLINE",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  device.isOnline
                                      ? Colors.green[700]
                                      : Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
