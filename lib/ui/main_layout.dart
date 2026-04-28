import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../pages/maintenance_page.dart';
import '../providers/providers.dart';
import '../pages/dashboard_page.dart';
import '../pages/network_page.dart';
import '../pages/settings_page.dart';
import '../widgets/virtual_keyboard.dart';

/// --------------------------------------------------------------------------
/// UI ROOT
/// --------------------------------------------------------------------------

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: kMacOsBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccentColor),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = ref.watch(keyboardVisibleProvider);

    final List<Widget> pages = [
      const DashboardPage(),
      const NetworkPage(),
      const SettingsPage(),
      const MaintenancePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // SIDEBAR
              Container(
                width: 200,
                color: kMacOsSidebar,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Icon(
                      Icons.shield_moon,
                      size: 40,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Strings.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    _buildNavItem(
                      0,
                      Icons.dashboard_rounded,
                      Strings.dashboard,
                    ),
                    _buildNavItem(
                      1,
                      Icons.network_check_rounded,
                      Strings.network,
                    ),
                    _buildNavItem(
                      2,
                      Icons.settings_suggest_rounded,
                      Strings.system,
                    ),
                    _buildNavItem(
                      3, // Usa il prossimo indice disponibile
                      Icons
                          .cleaning_services_rounded, // Icona del cestino/pulizia
                      Strings.maintenance, // Stringa localizzata
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isKeyboardVisible
                                  ? kAccentColor
                                  : Colors.grey[300],
                          foregroundColor:
                              isKeyboardVisible ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ref.read(keyboardVisibleProvider.notifier).state =
                              !isKeyboardVisible;
                        },
                        icon: const Icon(Icons.keyboard),
                        label: Text(Strings.keyboard),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // CONTENUTO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: pages[_selectedIndex],
                ),
              ),
            ],
          ),

          // TASTIERA OVERLAY
          if (isKeyboardVisible)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DraggableVirtualKeyboard(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Quando cambio pagina, resetto la tastiera e il controller per sicurezza
        ref.read(keyboardVisibleProvider.notifier).state = false;
        ref.read(activeTextControllerProvider.notifier).state = null;
        setState(() => _selectedIndex = index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? kAccentColor : Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
