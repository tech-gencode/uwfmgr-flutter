import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/uwf_status.dart';

/// --------------------------------------------------------------------------
/// SERVIZI DI SISTEMA
/// --------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// UWF localized keywords
// Add new translations here first when you need to support more languages.
// Every entry is normalized before matching:
// - uppercase
// - accents removed (for latin alphabets)
// - repeated spaces collapsed
// - hyphen/underscore normalized to spaces
// ---------------------------------------------------------------------------

const Set<String> _currentSessionHeaders = {
  // EN
  'CURRENT SESSION',
  // IT
  'SESSIONE CORRENTE',
  // ES
  'CONFIGURACION DE LA SESION ACTUAL',
  // FR
  'CONFIGURATION DE LA SESSION ACTUELLE',
  // DE
  'KONFIGURATION DER AKTUELLEN SITZUNG',
  // RU
  'CONFIGURATION DE LA SESSION ACTUELLE', // placeholder to replace
};

const Set<String> _nextSessionHeaders = {
  // EN
  'NEXT SESSION',
  // IT
  'SESSIONE SUCCESSIVA',
  // ES
  'CONFIGURACION DE LA SESION SIGUIENTE',
  // FR
  'CONFIGURATION DE LA SESSION SUIVANTE',
  // DE
  'KONFIGURATION DER NACHSTEN SITZUNG',
  // RU
  'CONFIGURATION DE LA SESSION SUIVANTE', // placeholder to replace
};

const Set<String> _filterConfigHeaders = {
  // EN
  'FILTER CONFIGURATION',
  // IT
  'CONFIGURAZIONE FILTRO',
  // ES
  'CONFIGURACION DE FILTRO',
  // FR
  'CONFIGURATION DU FILTRE',
  // DE
  'FILTERKONFIGURATION',
  // RU
  'CONFIGURATION DU FILTRE', // placeholder to replace
};

const Set<String> _overlayConfigHeaders = {
  // EN
  'OVERLAY CONFIGURATION',
  // IT
  'CONFIGURAZIONE OVERLAY',
  // ES
  'CONFIGURACION DE SUPERPOSICION',
  // FR
  'CONFIGURATION DE LA SUPERPOSITION',
  // DE
  'OVERLAYKONFIGURATION',
  // RU
  'CONFIGURATION DE LA SUPERPOSITION', // placeholder to replace
};

const Set<String> _volumeConfigHeaders = {
  // EN
  'VOLUME CONFIGURATION',
  // IT
  'CONFIGURAZIONE VOLUME',
  // ES
  'CONFIGURACION DE VOLUMEN',
  // FR
  'CONFIGURATION DU VOLUME',
  // DE
  'VOLUMENKONFIGURATION',
  // RU
  'CONFIGURATION DU VOLUME', // placeholder to replace
};

const Set<String> _filterStateLabels = {
  // EN
  'FILTER STATE',
  // IT
  'STATO FILTRO',
  // ES
  'ESTADO DE FILTRO',
  // FR
  'ETAT DU FILTRE',
  // DE
  'FILTERSTATUS',
  // RU
  'ETAT DU FILTRE', // placeholder to replace
};

const Set<String> _volumeStateLabels = {
  // EN
  'VOLUME STATE',
  // IT
  'STATO DEL VOLUME',
  // ES
  'ESTADO DEL VOLUMEN',
  // FR
  'ETAT DU VOLUME',
  // DE
  'VOLUMSTATUS',
  // RU
  'ETAT DU VOLUME', // placeholder to replace
};

const Set<String> _overlayTypeLabels = {
  // EN
  'OVERLAY TYPE',
  'TYPE',
  // IT
  'TIPO OVERLAY',
  'TIPO',
  // ES
  'TIPO',
  // FR
  'TYPE DE SUPERPOSITION',
  'TYPE',
  // DE
  'OVERLAYTYP',
  'TYP',
  // RU
  'TYPE', // placeholder to replace
};

const Set<String> _overlaySizeLabels = {
  // EN
  'OVERLAY MAXIMUM SIZE',
  'MAXIMUM SIZE',
  // IT
  'DIMENSIONE OVERLAY',
  'DIMENSIONE MASSIMA',
  'DIMENSIONE',
  // ES
  'TAMANO MAXIMO',
  // FR
  'TAILLE MAXIMALE',
  // DE
  'MAXIMALE GROSSE',
  // RU
  'TAILLE MAXIMALE', // placeholder to replace
};

const Set<String> _enabledTokens = {
  'ON',
  'ENABLED',
  'ACTIVE',
  'ACTIVATED',
  'ABILITATO',
  'ATTIVO',
  'ACTIVADO',
  'ACTIF',
  'AKTIVIERT',
};

const Set<String> _disabledTokens = {
  'OFF',
  'DISABLED',
  'INACTIVE',
  'DISABILITATO',
  'DISATTIVATO',
  'DESACTIVADO',
  'INACTIF',
  'DEAKTIVIERT',
};

const Set<String> _protectedTokens = {
  'PROTECTED',
  'PROTETTO',
  'PROTEGIDO',
  'PROTEGE',
  'GESCHUTZT',
};

const Set<String> _unprotectedTokens = {
  'UNPROTECTED',
  'UN PROTECTED',
  'NON PROTETTO',
  'NO PROTEGIDO',
  'NON PROTEGE',
  'UNGESCHUTZT',
};

class SystemService {
  Future<String> runCommand(String executable, List<String> args) async {
    try {
      final result = await Process.run(executable, args, runInShell: true);
      return result.stdout.toString().trim();
    } catch (e) {
      debugPrint("System Error: $e");
      return "";
    }
  }

  Future<bool> pingAddress(String ip) async {
    try {
      final result = await Process.run('ping', [ip, '-n', '1', '-w', '300']);
      final output = result.stdout.toString().toUpperCase();
      // Controlla per "TTL=" o la traduzione italiana (es. Durata)
      return output.contains("TTL=") || output.contains("DURATA=");
    } catch (e) {
      return false;
    }
  }

  Future<UwfStatus> getUwfStatus() async {
    try {
      // Eseguiamo il comando
      final result = await Process.run(
        'uwfmgr',
        ['get-config'],
        stdoutEncoding: SystemEncoding(),
      );

      return parseUwfStatus(result.stdout.toString());
    } catch (e) {
      debugPrint("Errore critico UWF: $e");
      return UwfStatus(
        isEnabled: false,
        isVolumeProtected: false,
        overlayMode: "Error",
        overlaySize: "0 MB",
        exclusions: [],
      );
    }
  }

  UwfStatus parseUwfStatus(String output) {
    final lines = output
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    bool? currentFilterEnabled;
    bool? nextFilterEnabled;
    bool? currentProtected;
    bool? nextProtected;
    String? currentOverlayType;
    String? nextOverlayType;
    String? currentOverlaySize;
    String? nextOverlaySize;
    String currentSection = 'none';
    String currentBlock = 'none';

    for (final line in lines) {
      final normalizedLine = _normalizeForMatch(line);
      final label = _extractNormalizedLabel(line);
      final value = _extractNormalizedValue(line);

      if (_currentSessionHeaders.contains(normalizedLine)) {
        currentSection = 'current';
        currentBlock = 'none';
        continue;
      }

      if (_nextSessionHeaders.contains(normalizedLine)) {
        currentSection = 'next';
        currentBlock = 'none';
        continue;
      }

      if (_filterConfigHeaders.contains(normalizedLine)) {
        currentBlock = 'filter';
        continue;
      }

      if (_overlayConfigHeaders.contains(normalizedLine)) {
        currentBlock = 'overlay';
        continue;
      }

      if (_volumeConfigHeaders.contains(normalizedLine)) {
        currentBlock = 'volume';
        continue;
      }

      if (label != null &&
          currentBlock == 'filter' &&
          _filterStateLabels.contains(label)) {
        final enabled = _parseEnabledValue(value ?? normalizedLine);
        if (enabled != null) {
          if (currentSection == 'current') {
            currentFilterEnabled = enabled;
          } else if (currentSection == 'next') {
            nextFilterEnabled = enabled;
          }
        }
      }

      if (label != null &&
          currentBlock == 'volume' &&
          _volumeStateLabels.contains(label)) {
        final protected = _parseProtectedValue(value ?? normalizedLine);
        if (protected != null) {
          if (currentSection == 'current') {
            currentProtected = protected;
          } else if (currentSection == 'next') {
            nextProtected = protected;
          }
        }
      }

      if (label != null &&
          currentBlock == 'overlay' &&
          _overlayTypeLabels.contains(label)) {
        final parsedType = _parseOverlayType(value ?? normalizedLine);
        if (parsedType != null) {
          if (currentSection == 'current') {
            currentOverlayType = parsedType;
          } else if (currentSection == 'next') {
            nextOverlayType = parsedType;
          }
        }
      }

      if (label != null &&
          currentBlock == 'overlay' &&
          _overlaySizeLabels.contains(label)) {
        final parsedSize = _parseOverlaySize(value ?? line);
        if (parsedSize != null) {
          if (currentSection == 'current') {
            currentOverlaySize = parsedSize;
          } else if (currentSection == 'next') {
            nextOverlaySize = parsedSize;
          }
        }
      }
    }

    final resolvedCurrentEnabled = currentFilterEnabled ?? nextFilterEnabled ?? false;
    final resolvedNextEnabled = nextFilterEnabled ?? currentFilterEnabled ?? false;
    final resolvedCurrentProtected = currentProtected ?? nextProtected ?? false;
    final resolvedNextProtected = nextProtected ?? currentProtected ?? false;
    final resolvedOverlayType = currentOverlayType ?? nextOverlayType ?? "N/D";
    final resolvedOverlaySize = currentOverlaySize ?? nextOverlaySize ?? "0 MB";

    final effectiveProtection =
        resolvedCurrentProtected != resolvedNextProtected
            ? resolvedNextProtected
            : resolvedCurrentProtected;

    // 4. Esclusioni (Usa startsWith con ignoreCase o regex)
    List<String> fileExclusions = lines
        .where((l) => RegExp(r'^[a-zA-Z]:\\', caseSensitive: false).hasMatch(l))
        .toList();
    List<String> regExclusions = lines
        .where((l) => l.toUpperCase().startsWith("HKLM"))
        .toList();

    return UwfStatus(
      isEnabled: resolvedCurrentEnabled,
      isNextSessionEnabled: resolvedNextEnabled,
      isVolumeProtected: effectiveProtection,
      isCurrentSessionProtected: resolvedCurrentProtected,
      isNextSessionProtected: resolvedNextProtected,
      overlayMode: resolvedOverlayType,
      overlaySize: resolvedOverlaySize,
      exclusions: [...fileExclusions, ...regExclusions].isNotEmpty
          ? [...fileExclusions, ...regExclusions]
          : ["Nessuna esclusione"],
    );
  }

  String _normalizeForMatch(String input) {
    final upper = input.toUpperCase();
    final withoutAccents = upper
        .replaceAll('Á', 'A')
        .replaceAll('À', 'A')
        .replaceAll('Ä', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ã', 'A')
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ì', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Î', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ò', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('Ô', 'O')
        .replaceAll('Õ', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ù', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ñ', 'N')
        .replaceAll('Ç', 'C')
        .replaceAll('ß', 'SS');

    return withoutAccents
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _extractNormalizedLabel(String line) {
    final parts = line.split(':');
    if (parts.length < 2) {
      return null;
    }
    return _normalizeForMatch(parts.first);
  }

  String? _extractNormalizedValue(String line) {
    final separatorIndex = line.indexOf(':');
    if (separatorIndex == -1) {
      return null;
    }
    return _normalizeForMatch(line.substring(separatorIndex + 1));
  }

  bool? _parseEnabledValue(String normalizedValue) {
    if (_containsAnyToken(normalizedValue, _disabledTokens)) {
      return false;
    }
    if (_containsAnyToken(normalizedValue, _enabledTokens)) {
      return true;
    }
    return null;
  }

  bool? _parseProtectedValue(String normalizedValue) {
    if (_containsAnyToken(normalizedValue, _unprotectedTokens)) {
      return false;
    }
    if (_containsAnyToken(normalizedValue, _protectedTokens)) {
      return true;
    }
    return null;
  }

  String? _parseOverlayType(String normalizedValue) {
    if (RegExp(r'\bRAM\b').hasMatch(normalizedValue)) {
      return 'RAM';
    }
    if (RegExp(r'\bDISK\b').hasMatch(normalizedValue)) {
      return 'Disk';
    }
    return null;
  }

  String? _parseOverlaySize(String rawValue) {
    final match = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(MB|GB)',
      caseSensitive: false,
    ).firstMatch(rawValue);
    if (match == null) {
      return null;
    }
    return "${match.group(1)} ${match.group(2)!.toUpperCase()}";
  }

  bool _containsAnyToken(String text, Set<String> tokens) {
    for (final token in tokens) {
      if (RegExp('\\b${RegExp.escape(token)}\\b').hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  Future<void> toggleUwf(bool enable) async {
    if (enable) {
      // Aggiunta eccezioni richieste prima di attivare
      await _addExclusions();

      // Abilita filtro e proteggi volume
      await runCommand('uwfmgr', ['filter', 'enable']);
      await runCommand('uwfmgr', ['overlay', 'set-type', 'RAM']);
      await runCommand('uwfmgr', ['overlay', 'set-size', '2048']);
      await runCommand('uwfmgr', ['volume', 'protect', 'C:']);
    } 
    else 
    {
      await runCommand('uwfmgr', ['volume', 'unprotect', 'C:']);
      // Nota: Disabilitare il filtro richiede riavvio solitamente
      await runCommand('uwfmgr', ['filter', 'disable']);
    }
  }

  Future<void> _addExclusions() async {
    // --- ESCLUSIONI FILE PER PERSISTENZA LOG ---
    final fileExclusions = [
      r'C:\Windows\System32\winevt\Logs',     // Fondamentale per log eventi Windows
      r'C:\Windows\Temp',                     // Temp di sistema
      r'C:\ProgramData\Microsoft\WLSC'        // per la licenza
    ];

    for (var path in fileExclusions) {
      await runCommand('uwfmgr', ['file', 'add-exclusion', path]);
    }

    // --- ESCLUSIONI REGISTRO PER ORA SOLARE/LEGALE ---
    // Queste chiavi permettono a Windows di salvare il cambio orario e ethernet anche sotto UWF
    final regExclusions = [
      r'HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
      r'HKLM\SYSTEM\CurrentControlSet\Services\W32Time',
      r'HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles',
    ];

    for (var key in regExclusions) {
      await runCommand('uwfmgr', ['registry', 'add-exclusion', key]);
    }
  }

  // Metodo di utility industriale per il riavvio
  Future<void> rebootSystem() async {
    await Process.run('shutdown', ['/r', '/t', '0']);
  }

  Future<void> setHostname(String newName) async {
    await runCommand('powershell', [
      '-Command',
      'Rename-Computer -NewName "$newName" -Force',
    ]);
  }
}
