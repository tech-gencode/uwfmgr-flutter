import 'dart:async';
import 'dart:convert';
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

final Set<String> _currentSessionHeaders = {
  // EN
  'CURRENT SESSION',
  'CURRENT SESSION SETTINGS',
  // IT
  'IMPOSTAZIONI SESSIONE CORRENTE',
  'SESSIONE CORRENTE',
  // ES
  'CONFIGURACION DE LA SESION ACTUAL',
  // FR (older + Windows 10.0.26100+)
  'CONFIGURATION DE LA SESSION ACTUELLE',
  'PARAMETRES DE LA SESSION EN COURS',
  // DE
  'KONFIGURATION DER AKTUELLEN SITZUNG',
  // RU
  'CONFIGURATION DE LA SESSION ACTUELLE', // placeholder to replace
};

final Set<String> _nextSessionHeaders = {
  // EN
  'NEXT SESSION',
  'NEXT SESSION SETTINGS',
  // IT (Windows 10.0.26100+ uses plural "Impostazioni")
  'IMPOSTAZIONI SESSIONE SUCCESSIVA',
  'IMPOSTAZIONE SESSIONE SUCCESSIVA',
  'SESSIONE SUCCESSIVA',
  // ES
  'CONFIGURACION DE LA SESION SIGUIENTE',
  // FR (older + Windows 10.0.26100+)
  'CONFIGURATION DE LA SESSION SUIVANTE',
  'PARAMETRES DE LA SESSION SUIVANTE',
  // DE
  'KONFIGURATION DER NACHSTEN SITZUNG',
  // RU
  'CONFIGURATION DE LA SESSION SUIVANTE', // placeholder to replace
};

final Set<String> _filterConfigHeaders = {
  // EN
  'FILTER CONFIGURATION',
  'FILTER SETTINGS',
  // IT
  'IMPOSTAZIONI FILTRO',
  'CONFIGURAZIONE FILTRO',
  // ES
  'CONFIGURACION DE FILTRO',
  // FR (older + Windows 10.0.26100+)
  'CONFIGURATION DU FILTRE',
  'PARAMETRES DE FILTRE',
  // DE
  'FILTERKONFIGURATION',
  // RU
  'CONFIGURATION DU FILTRE', // placeholder to replace
};

final Set<String> _overlayConfigHeaders = {
  // EN
  'OVERLAY CONFIGURATION',
  'OVERLAY SETTINGS',
  // IT
  'IMPOSTAZIONI OVERLAY',
  'CONFIGURAZIONE OVERLAY',
  // ES
  'CONFIGURACION DE SUPERPOSICION',
  // FR (older + Windows 10.0.26100+)
  'CONFIGURATION DE LA SUPERPOSITION',
  'PARAMETRES DE SUPERPOSITION',
  // DE
  'OVERLAYKONFIGURATION',
  // RU
  'CONFIGURATION DE LA SUPERPOSITION', // placeholder to replace
};

final Set<String> _volumeConfigHeaders = {
  // EN
  'VOLUME CONFIGURATION',
  'VOLUME SETTINGS',
  // IT
  'IMPOSTAZIONI VOLUME',
  'CONFIGURAZIONE VOLUME',
  // ES
  'CONFIGURACION DE VOLUMEN',
  // FR (older + Windows 10.0.26100+)
  'CONFIGURATION DU VOLUME',
  'PARAMETRES DE VOLUME',
  // DE
  'VOLUMENKONFIGURATION',
  // RU
  'CONFIGURATION DU VOLUME', // placeholder to replace
};

final Set<String> _filterStateLabels = {
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

final Set<String> _volumeStateLabels = {
  // EN
  'VOLUME STATE',
  // IT
  'STATO VOLUME',
  // ES
  'ESTADO DEL VOLUMEN',
  // FR
  'ETAT DU VOLUME',
  // DE
  'VOLUMSTATUS',
  // RU
  'ETAT DU VOLUME', // placeholder to replace
};

final Set<String> _overlayTypeLabels = {
  // EN
  'OVERLAY TYPE',
  'TYPE',
  // IT
  'IMPOSTAZIONI OVERLAY',
  'TIPO OVERLAY',
  'TIPO',
  // ES
  'TIPO',
  // FR (uwfmgr may shorten to "Type de : RAM")
  'TYPE DE SUPERPOSITION',
  'TYPE DE',
  'TYPE',
  // DE
  'OVERLAYTYP',
  'TYP',
  // RU
  'TYPE', // placeholder to replace
};

final Set<String> _overlaySizeLabels = {
  // EN
  'OVERLAY MAXIMUM SIZE',
  'MAXIMUM SIZE',
  // IT
  'DIMENSIONE OVERLAY',
  'DIMENSIONE MASSIMA',
  'DIMENSIONI MASSIME',
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
  'ABILITATA',
  'ATTIVO',
  'ATTIVATA',
  'ACTIVADO',
  'ACTIF',
  'AKTIVIERT',
};

const Set<String> _disabledTokens = {
  'OFF',
  'DISABLED',
  'INACTIVE',
  'DISABILITATO',
  'DISABILITATA',
  'DISATTIVATO',
  'DISATTIVATA',
  'DESACTIVADO',
  'DESACTIVE',
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
  static const List<String> defaultNetworkIps = [
    '192.168.1.199',
    '192.168.1.198',
    '192.168.1.197',
    '192.168.1.196',
    '192.168.1.195',
    '192.168.1.194',
    '192.168.1.193',
    '192.168.1.192',
    '192.168.1.191',
    '192.168.1.190',
    '192.168.1.189',
    '192.168.1.188',
    '192.168.1.187',
    '192.168.1.186',
    '192.168.1.185',
    '192.168.1.184',
  ];

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
      final result = await Process.run(
        'uwfmgr',
        ['get-config'],
        stdoutEncoding: SystemEncoding(),
        stderrEncoding: SystemEncoding(),
      );

      final rawStdout = result.stdout.toString();
      final rawStderr = result.stderr.toString();
      final stdout = _sanitizeCommandOutput(rawStdout);
      final stderr = _sanitizeCommandOutput(rawStderr);

      await _writeUwfDebugDump(
        stdout: stdout,
        stderr: stderr,
        exitCode: result.exitCode,
      );

      return parseUwfStatus(stdout);
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
      final parts = _extractNormalizedParts(line);
      final label = parts?.$1;
      final value = parts?.$2;

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

      if (currentBlock == 'filter' &&
          label != null &&
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

      if (currentBlock == 'volume' &&
          label != null &&
          (_volumeStateLabels.contains(label) || label.startsWith('VOLUME '))) {
        final protected = _parseProtectedValue(value ?? normalizedLine);
        if (protected != null) {
          if (currentSection == 'current') {
            currentProtected = protected;
          } else if (currentSection == 'next') {
            nextProtected = protected;
          }
        }
      }

      if (currentBlock == 'overlay' &&
          label != null &&
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

      if (currentBlock == 'overlay' &&
          label != null &&
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

    final exclusions = <String>{...fileExclusions, ...regExclusions}.toList();

    return UwfStatus(
      isEnabled: resolvedCurrentEnabled,
      isNextSessionEnabled: resolvedNextEnabled,
      isVolumeProtected: effectiveProtection,
      isCurrentSessionProtected: resolvedCurrentProtected,
      isNextSessionProtected: resolvedNextProtected,
      overlayMode: resolvedOverlayType,
      overlaySize: resolvedOverlaySize,
      exclusions: exclusions,
    );
  }

  Future<void> _writeUwfDebugDump({
    required String stdout,
    required String stderr,
    required int exitCode,
  }) async {
    try {
      final dumpFile = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}uwf_get_config_output.txt',
      );

      final buffer = StringBuffer()
        ..writeln('timestamp=${DateTime.now().toIso8601String()}')
        ..writeln('exit_code=$exitCode')
        ..writeln('temp_file=${dumpFile.path}')
        ..writeln('--- STDOUT BEGIN ---')
        ..writeln(stdout)
        ..writeln('--- STDOUT END ---')
        ..writeln('--- STDERR BEGIN ---')
        ..writeln(stderr)
        ..writeln('--- STDERR END ---');

      await dumpFile.writeAsString(buffer.toString(), flush: true);
      debugPrint('UWF dump scritto in: ${dumpFile.path}');
    } catch (e) {
      debugPrint('Impossibile scrivere dump UWF: $e');
    }
  }

  String _sanitizeCommandOutput(String input) {
    return input
        .replaceAll('\u0000', '')
        .replaceAll('\uFEFF', '')
        .replaceAll('\r\r\n', '\r\n');
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

  (String, String)? _extractNormalizedParts(String line) {
    final colonIndex = line.indexOf(':');
    if (colonIndex != -1) {
      final label = line.substring(0, colonIndex).trim();
      final value = line.substring(colonIndex + 1).trim();
      if (label.isNotEmpty && value.isNotEmpty) {
        return (_normalizeForMatch(label), _normalizeForMatch(value));
      }
    }

    final match = RegExp(r'^(.*?)\s{2,}(.+)$').firstMatch(line);
    if (match == null) {
      return null;
    }

    final label = match.group(1)?.trim();
    final value = match.group(2)?.trim();
    if (label == null || value == null || label.isEmpty || value.isEmpty) {
      return null;
    }

    return (_normalizeForMatch(label), _normalizeForMatch(value));
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
      r'(\d+(?:[.,]\d+)?)\s*(MB|GB|MO|GO|ME|GI)',
      caseSensitive: false,
    ).firstMatch(rawValue);
    if (match == null) {
      return null;
    }
    final unit = switch (match.group(2)!.toUpperCase()) {
      'MO' || 'ME' => 'MB',
      'GO' || 'GI' => 'GB',
      _ => match.group(2)!.toUpperCase(),
    };
    return '${match.group(1)} $unit';
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
      r'C:\Windows\temp',
      r'C:\Windows\System32\Winevt\Logs'
    ];
    
    for (var path in fileExclusions) {
      await runCommand('uwfmgr', ['file', 'add-exclusion', path]);
    }

    // --- ESCLUSIONI REGISTRO PER ORA SOLARE/LEGALE ---
    // Queste chiavi permettono a Windows di salvare il cambio orario e ethernet anche sotto UWF
    final regExclusions = [
      // TIME & SYSTEM
      r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones',
      r'HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
    ];

    for (var key in regExclusions) {
      await runCommand('uwfmgr', ['registry', 'add-exclusion', key]);
    }
  }

  // Metodo di utility industriale per il riavvio
  Future<void> rebootSystem() async {
    await Process.run('shutdown', ['/r', '/t', '0']);
  }

  Future<(String hostName, String? description)> getComputerIdentity() async {
    final hostName = Platform.localHostname;
    final description = await _getComputerDescription();
    return (hostName, description);
  }

  Future<void> setComputerIdentity(String newName, String? description) async {
    final trimmedName = newName.trim();
    final trimmedDescription = description?.trim();

    if (trimmedName.isEmpty && (trimmedDescription == null || trimmedDescription.isEmpty)) {
      return;
    }

    final commands = <String>[];

    if (trimmedName.isNotEmpty) {
      commands.add(
        "Rename-Computer -NewName '${_escapePowerShell(trimmedName)}' -Force",
      );
    }

    if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
      commands.add(
        "Set-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters' -Name 'srvcomment' -Value '${_escapePowerShell(trimmedDescription)}'",
      );
    }

    await runCommand('powershell', [
      '-Command',
      commands.join('; '),
    ]);
  }

  String _escapePowerShell(String value) {
    return value.replaceAll("'", "''");
  }

  Future<String?> _getComputerDescription() async {
    try {
      final result = await Process.run(
        'powershell',
        [
          '-Command',
          r"(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'srvcomment' -ErrorAction SilentlyContinue).srvcomment",
        ],
        stdoutEncoding: SystemEncoding(),
        stderrEncoding: SystemEncoding(),
      );

      final output = _sanitizeCommandOutput(result.stdout.toString()).trim();
      if (output.isEmpty) {
        return null;
      }
      return output;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> loadNetworkIps() async {
    try {
      final configFile = await _ensureNetworkConfigFile();
      final content = await configFile.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) return [];

      final devices = decoded['devices'];
      if (devices is! List) return [];

      return devices
          .whereType<Map>()
          .map((device) => device['ip'])
          .whereType<String>()
          .map((ip) => ip.trim())
          .where((ip) => ip.isNotEmpty)
          .toList(); 
        // Nota: rimosso il controllo .isEmpty che rimandava ai default!
  } catch (_) {
    // Se il file è corrotto o non leggibile, restituisce lista vuota
    return []; 
  }
}

  Future<File> _ensureNetworkConfigFile() async {
    final exeDirectory = File(Platform.resolvedExecutable).parent;
    final configFile = File(
      '${exeDirectory.path}${Platform.pathSeparator}network_config.json',
    );

    if (!await configFile.exists()) {
      await configFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'version': 1,
          'devices': defaultNetworkIps.map((ip) => {'ip': ip}).toList(),
        }),
        flush: true,
      );
    }

    return configFile;
  }

  // --------------------------------------------------------------------------
  // SERVICING / WINDOWS UPDATE
  // --------------------------------------------------------------------------

  static const List<String> _windowsUpdateServices = [
    'wuauserv', // Windows Update
    'bits', // Background Intelligent Transfer Service
    'dosvc', // Delivery Optimization
    'usosvc', // Update Orchestrator Service
  ];

  /// Ritorna una mappa { serviceName: startType } (es: Manual/Automatic/Disabled).
  Future<Map<String, String>> captureWindowsUpdateServiceStartTypes() async {
    final script = r'''
$ErrorActionPreference = 'SilentlyContinue'
$svcs = @('wuauserv','bits','dosvc','usosvc')
$state = @{}
foreach ($s in $svcs) {
  $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
  if ($null -ne $svc) {
    $state[$s] = "$($svc.StartType)"
  }
}
$state | ConvertTo-Json -Compress
''';

    final json = await runCommand('powershell', ['-Command', script]);
    if (json.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  /// Imposta i servizi Windows Update in stato "operativo" (tipicamente Manual) e li avvia.
  Future<void> enableWindowsUpdateServices() async {
    final script = r'''
$ErrorActionPreference = 'SilentlyContinue'
$svcs = @('wuauserv','bits','dosvc','usosvc')
foreach ($s in $svcs) {
  try { Set-Service -Name $s -StartupType Manual } catch {}
  try { Start-Service -Name $s } catch {}
}
''';
    await runCommand('powershell', ['-Command', script]);
  }

  /// Ripristina gli start-type salvati; se un servizio viene ripristinato su Disabled lo ferma.
  Future<void> restoreWindowsUpdateServices(Map<String, String> startTypes) async {
    if (startTypes.isEmpty) return;

    final entries = startTypes.entries
        .where((e) => _windowsUpdateServices.contains(e.key))
        .map((e) {
          final name = _escapePowerShell(e.key);
          final typeRaw = e.value.toLowerCase();
          final startupType =
              typeRaw.contains('auto') ? 'Automatic' : (typeRaw.contains('dis') ? 'Disabled' : 'Manual');
          return "'$name'='$startupType'";
        })
        .join('; ');

    final script = '''
\$ErrorActionPreference = 'SilentlyContinue'
\$state = @{ $entries }
foreach (\$k in \$state.Keys) {
  \$t = \$state[\$k]
  try { Set-Service -Name \$k -StartupType \$t } catch {}
  if (\$t -eq 'Disabled') {
    try { Stop-Service -Name \$k -Force } catch {}
  }
}
''';

    await runCommand('powershell', ['-Command', script]);
  }

  /// Avvia (best-effort) scan/download/install tramite UsoClient.
  /// Nota: non blocca fino a fine aggiornamenti; innesca solo il processo.
  Future<void> startWindowsUpdateWorkflow() async {
    // UsoClient è il modo più “nativo” su Windows 10/11 per orchestrare WU.
    // Alcuni comandi possono non produrre output: è normale.
    await runCommand('cmd', ['/c', 'UsoClient', 'StartScan']);
    await Future.delayed(const Duration(seconds: 2));
    await runCommand('cmd', ['/c', 'UsoClient', 'StartDownload']);
    await Future.delayed(const Duration(seconds: 2));
    await runCommand('cmd', ['/c', 'UsoClient', 'StartInstall']);
  }

  /// Apre la UI di Windows Update (Settings).
  Future<void> openWindowsUpdateSettings() async {
    await runCommand('cmd', ['/c', 'start', '', 'ms-settings:windowsupdate']);
  }
}
