import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// IMPORTA i tuoi provider
import '../providers/providers.dart';
import '../core/constants.dart';
import '../core/strings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _deviceOptions = [
    "NC-TOUCH CONSOLE",
    "7-INCH PC",
    "7-INCH CONSOLE",
    "12-INCH PC",
  ];

  final TextEditingController _hostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadComputerIdentity);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _loadComputerIdentity() async {
    final (hostName, description) = await ref
        .read(systemServiceProvider)
        .getComputerIdentity();

    if (!mounted) return;

    _hostController.text = hostName;
    if (description != null && _deviceOptions.contains(description)) {
      ref.read(deviceTypeProvider.notifier).state = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.sysConfig,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSafeInput(
                  context,
                  ref,
                  Strings.hostName,
                  _hostController,
                  Icons.computer,
                ),
                const SizedBox(height: 20),

              SafeDropdownInput(
                label: Strings.pcDesc,
                icon: Icons.description,
                provider: deviceTypeProvider,
                options: _deviceOptions,
              ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final selectedDescription = ref.read(deviceTypeProvider);

                      await ref
                          .read(systemServiceProvider)
                          .setComputerIdentity(
                            _hostController.text,
                            selectedDescription,
                          );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(Strings.cmdSent)));
                    },
                    child: Text(
                      Strings.btnApply,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// WIDGET SICURO PER DESKTOP – ZERO CRASH GARANTITO
/// --------------------------------------------------------------------------
Widget buildSafeInput(
  BuildContext context,
  WidgetRef ref,
  String label,
  TextEditingController controller,
  IconData icon,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        // Ora permettiamo il focus reale per ricevere input dalla tastiera fisica
        readOnly: false, 
        showCursor: true,
        // Questo impedisce l'apertura della tastiera di sistema su Android/iOS/Linux
        keyboardType: TextInputType.none, 
        
        onTap: () {
          // Attiva la tua TASTIERA VIRTUALE personalizzata
          ref.read(activeTextControllerProvider.notifier).state = controller;
          ref.read(keyboardVisibleProvider.notifier).state = true;
        },
        
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    ],
  );
}

class SafeDropdownInput extends ConsumerWidget {
  final String label;
  final IconData icon;
  final StateProvider<String?> provider; // Modificato in String?
  final List<String> options;

  const SafeDropdownInput({
    super.key,
    required this.label,
    required this.icon,
    required this.provider,
    required this.options,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              // Se selectedValue è null, cerchiamo di non far crashare il widget
              value: options.contains(selectedValue) ? selectedValue : null,
              isExpanded: true,
              hint: Text(Strings.selectOption), // Mostrato se il valore è null
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              borderRadius: BorderRadius.circular(8),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  ref.read(provider.notifier).state = newValue;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// --------------------------------------------------------------------------
/// FocusNode speciale che IMPEDISCE al TextField di prendere focus.
/// Questo ELIMINA il crash del GTK IME su Linux.
/// --------------------------------------------------------------------------
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
