// lib/widgets/virtual_keyboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

// --------------------------------------------------------------------------
// 1. DraggableWrapper per gestire la posizione e il trascinamento
// --------------------------------------------------------------------------

class DraggableVirtualKeyboard extends ConsumerStatefulWidget {
  const DraggableVirtualKeyboard({super.key});

  @override
  ConsumerState<DraggableVirtualKeyboard> createState() =>
      _DraggableVirtualKeyboardState();
}

class _DraggableVirtualKeyboardState
    extends ConsumerState<DraggableVirtualKeyboard> {
  double _currentX = 0;
  double _currentY = 0;
  bool isDragging = false;

  // DIMENSIONI OTTIMIZZATE
  static const keyboardWidth = 550.0;
  static const keyboardHeight = 240.0;

  @override
  void initState() {
    super.initState();
    _currentY = keyboardHeight;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_currentX == 0 && _currentY == keyboardHeight) {
      // Calcolo posizione iniziale (Centrata e in basso)
      _currentX = (screenSize.width - keyboardWidth) / 2;
      _currentY = screenSize.height - keyboardHeight - 10;
    }

    const minX = 5.0;
    const minY = 5.0;
    final maxX = screenSize.width - keyboardWidth - 5;
    final maxY = screenSize.height - keyboardHeight - 5;

    return Positioned(
      left: _currentX,
      top: _currentY,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            // Clamping per non uscire dai bordi
            _currentX = (_currentX + details.delta.dx).clamp(minX, maxX);
            _currentY = (_currentY + details.delta.dy).clamp(minY, maxY);
          });
        },
        onPanEnd: (details) {
          setState(() {
            isDragging = false;
          });
        },
        child: Material(
          elevation: isDragging ? 16.0 : 8.0,
          borderRadius: BorderRadius.circular(16),
          child: const VirtualKeyboardContent(),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. TASTIERA VIRTUALE (UI Pura) - Layout ISO e Fix Overflow
// --------------------------------------------------------------------------

class VirtualKeyboardContent extends ConsumerWidget {
  const VirtualKeyboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Layout standard QWERTY
    final keys = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Del'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '.', '-'],
    ];

    void onKeyPress(String key) {
      try {
        final controller = ref.read(activeTextControllerProvider);

        if (controller == null) return;

        final text = controller.text;
        int cursorPos = controller.selection.baseOffset;
        if (cursorPos < 0 || cursorPos > text.length) {
          cursorPos = text.length;
        }

        String newText = text;
        int newCursorPos = cursorPos;

        if (key == 'Del') {
          if (text.isNotEmpty && cursorPos > 0) {
            newText =
                text.substring(0, cursorPos - 1) + text.substring(cursorPos);
            newCursorPos = cursorPos - 1;
          }
        } else if (key == 'Enter') {
          ref.read(keyboardVisibleProvider.notifier).state = false;
          ref.read(activeTextControllerProvider.notifier).state = null;
          return;
        } else if (key == 'Space') {
          newText =
              "${text.substring(0, cursorPos)} ${text.substring(cursorPos)}";
          newCursorPos = cursorPos + 1;
        } else if (key == 'Close') {
          ref.read(keyboardVisibleProvider.notifier).state = false;
          ref.read(activeTextControllerProvider.notifier).state = null;   
          return;
        } else {
          newText =
              text.substring(0, cursorPos) + key + text.substring(cursorPos);
          newCursorPos = cursorPos + 1;
        }

        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursorPos),
        );
      } catch (e) {
        debugPrint("Virtual Keyboard Error (Safe Catch): $e");
      }
    }

    // Altezza corretta per prevenire l'overflow (240 - 36 di padding/handle)
    const keysAreaHeight = 204.0;

    return Container(
      width: _DraggableVirtualKeyboardState.keyboardWidth,
      height: _DraggableVirtualKeyboardState.keyboardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildDragHandle(context),

          SizedBox(
            height: keysAreaHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonna 1: Tasti standard
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Righe standard (QWERTY)
                      ...keys.map((row) => _buildKeyRow(row, onKeyPress)),

                      // Riga Spazio, punto, meno (con larghezze ricalcolate)
                      _buildBottomRow(onKeyPress),
                    ],
                  ),
                ),

                // Colonna 2: Tasti Enter e Chiudi
                _buildRightColumn(context, ref, onKeyPress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce la riga standard QWERTY
  Widget _buildKeyRow(List<String> rowKeys, void Function(String) onKeyPress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          rowKeys.map((key) {
            final isSpecial = key.length > 1;
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                width: isSpecial ? 40 : 38,
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => onKeyPress(key),
                  child:
                      isSpecial
                          ? (key == 'Del'
                              ? const Icon(Icons.backspace_outlined, size: 16)
                              : Text(key, style: const TextStyle(fontSize: 14)))
                          : Text(
                            key,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Costruisce la riga inferiore con Space, . e -
  Widget _buildBottomRow(void Function(String) onKeyPress) {
    // La larghezza dei tasti è stata ricalcolata per stare all'interno dell'Expanded
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSingleKey('.', onKeyPress, 38), // Punto
        _buildSingleKey('-', onKeyPress, 38), // Meno
        _buildSingleKey('Space', onKeyPress, 360), // Space grande
      ],
    );
  }

  // Colonna destra con Enter grande e bottone di chiusura
  Widget _buildRightColumn(
    BuildContext context,
    WidgetRef ref,
    void Function(String) onKeyPress,
  ) {
    return SizedBox(
      width: 80, // Larghezza fissa per la colonna Enter/Chiudi
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tasto ENTER (Alto)
          Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 2.0,
              top: 2.0,
              bottom: 2.0,
            ),
            child: SizedBox(
              height: 150, // Altezza per coprire le righe QWERTY
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => onKeyPress('Enter'),
                child: const Icon(Icons.keyboard_return, size: 28),
              ),
            ),
          ),

          // Tasto di Chiusura (Basso a destra)
          Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 2.0,
              top: 2.0,
              bottom: 2.0,
            ),
            child: SizedBox(
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => onKeyPress('Close'),
                child: const Icon(Icons.keyboard_hide, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Metodo helper per creare un singolo tasto con larghezza variabile
  Widget _buildSingleKey(
    String key,
    void Function(String) onKeyPress,
    double width,
  ) {
    final isSpecial = key.length > 1;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: width,
        height: 38, // Altezza fissa
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () => onKeyPress(key),
          child:
              isSpecial
                  ? Text(key, style: const TextStyle(fontSize: 14))
                  : Text(
                    key,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      height: 15,
      margin: const EdgeInsets.only(bottom: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
      ),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
