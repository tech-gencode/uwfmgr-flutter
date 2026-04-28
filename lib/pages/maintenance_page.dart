// lib/pages/maintenance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/strings.dart';
import '../widgets/cleanup_button_widget.dart';

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usiamo un LayoutBuilder per centrare perfettamente la card
    // e dare una struttura pulita alla pagina.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intestazione Pagina (Stile macOS Settings)
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            Strings.maintenance,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),

        // Area Contenuto Centrata
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CleanUpButtonWidget(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
