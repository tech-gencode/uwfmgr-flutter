import 'package:flutter_test/flutter_test.dart';
import 'package:uwf_managerpro/services/system_service.dart';

void main() {
  group('SystemService.parseUwfStatus', () {
    test('parses English current and next session states', () {
      const output = r'''
Unified Write Filter settings

Current Session
Filter Configuration
Filter State                ON
Volume Configuration
Volume State                Protected
Overlay Configuration
Overlay Type                Disk
Overlay Maximum Size        3072 MB

Next Session
Filter Configuration
Filter State                OFF
Volume Configuration
Volume State                Unprotected
Overlay Configuration
Overlay Type                RAM
Overlay Maximum Size        2048 MB

C:\Windows\Temp
HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
''';

      final status = SystemService().parseUwfStatus(output);

      expect(status.isEnabled, isTrue);
      expect(status.isNextSessionEnabled, isFalse);
      expect(status.isCurrentSessionProtected, isTrue);
      expect(status.isNextSessionProtected, isFalse);
      expect(status.hasPendingProtectionChange, isTrue);
      expect(status.isVolumeProtected, isFalse);
      expect(status.overlayMode, 'Disk');
      expect(status.overlaySize, '3072 MB');
      expect(status.exclusions, contains(r'C:\Windows\Temp'));
      expect(
        status.exclusions,
        contains(
          r'HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles',
        ),
      );
    });

    test('parses Italian output and detects RAM overlay', () {
      const output = r'''
Impostazioni Unified Write Filter

Sessione corrente
Configurazione filtro
Stato filtro                Attivo
Configurazione volume
Volume C:                   Protetto
Configurazione overlay
Tipo overlay                RAM
Dimensione overlay          2048 MB

Sessione successiva
Configurazione filtro
Stato filtro                Attivo
Configurazione volume
Volume C:                   Protetto
''';

      final status = SystemService().parseUwfStatus(output);

      expect(status.isEnabled, isTrue);
      expect(status.isNextSessionEnabled, isTrue);
      expect(status.isCurrentSessionProtected, isTrue);
      expect(status.isNextSessionProtected, isTrue);
      expect(status.hasPendingProtectionChange, isFalse);
      expect(status.isVolumeProtected, isTrue);
      expect(status.overlayMode, 'RAM');
      expect(status.overlaySize, '2048 MB');
    });

    test('parses Spanish localized output', () {
      const output = r'''
Utilidad de configuracion del Filtro de escritura unificado version 10.0.17763

Configuracion de la sesion actual

CONFIGURACION DE FILTRO
    Estado de filtro:    Activado

CONFIGURACION DE SUPERPOSICION
    Tipo:               RAM
    Tamano maximo:       2048 MB

CONFIGURACION DE VOLUMEN
Volumen 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    Estado del volumen:     Un-protected

EXCLUSIONES DEL REGISTRO
    HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation

Configuracion de la sesion siguiente

CONFIGURACION DE FILTRO
    Estado de filtro:    Activado

CONFIGURACION DE SUPERPOSICION
    Tipo:               RAM
    Tamano maximo:       2048 MB

CONFIGURACION DE VOLUMEN
Volumen 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    Estado del volumen:     Un-protected
''';

      final status = SystemService().parseUwfStatus(output);

      expect(status.isEnabled, isTrue);
      expect(status.isNextSessionEnabled, isTrue);
      expect(status.isCurrentSessionProtected, isFalse);
      expect(status.isNextSessionProtected, isFalse);
      expect(status.hasPendingProtectionChange, isFalse);
      expect(status.isVolumeProtected, isFalse);
      expect(status.overlayMode, 'RAM');
      expect(status.overlaySize, '2048 MB');
      expect(
        status.exclusions,
        contains(r'HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'),
      );
    });

    test('parses real uwfmgr settings output and deduplicates exclusions', () {
      const output = r'''
Unified Write Filter Configuration Utility version 10.0.17763
Copyright (C) Microsoft Corporation. All rights reserved.

Current Session Settings


FILTER SETTINGS
    Filter state:    ON
    Pending commit:  N/A
    Shutdown pending:No

SERVICING SETTINGS
    Servicing State: OFF

OVERLAY SETTINGS
    Type:               RAM
    Maximum size:       2048 MB
    Warning Threshold:  512 MB
    Critical Threshold: 1024 MB
    Freespace Passthrough: OFF
    Persistent: OFF
    Reset Mode: N/A



VOLUME SETTINGS
Volume 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    Volume state:     Un-protected
    Volume ID:        812f1528-33ff-48b8-ba59-35e5663af46b

    File Exclusions:
Current Session Exclusions for Volume 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    C:\Windows\System32\winevt\Logs
    C:\Windows\Temp
    C:\ProgramData\Microsoft\WLSC



REGISTRY EXCLUSIONS
    HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
    HKLM\SYSTEM\CurrentControlSet\Services\W32Time
    HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles

Next Session Settings


FILTER SETTINGS
    Filter state:    ON
    Pending commit:  N/A

SERVICING SETTINGS
    Servicing State: OFF

OVERLAY SETTINGS
    Type:               RAM
    Maximum size:       2048 MB
    Warning Threshold:  512 MB
    Critical Threshold: 1024 MB
    Freespace Passthrough: OFF
    Persistent: OFF
    Reset Mode: N/A



VOLUME SETTINGS
Volume 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    Volume state:     Un-protected
    Volume ID:        812f1528-33ff-48b8-ba59-35e5663af46b

    File Exclusions:
Next Session Exclusions for Volume 812f1528-33ff-48b8-ba59-35e5663af46b [C:]
    C:\Windows\System32\winevt\Logs
    C:\Windows\Temp
    C:\ProgramData\Microsoft\WLSC



REGISTRY EXCLUSIONS
    HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
    HKLM\SYSTEM\CurrentControlSet\Services\W32Time
    HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
''';

      final status = SystemService().parseUwfStatus(output);

      expect(status.isEnabled, isTrue);
      expect(status.isNextSessionEnabled, isTrue);
      expect(status.isCurrentSessionProtected, isFalse);
      expect(status.isNextSessionProtected, isFalse);
      expect(status.overlayMode, 'RAM');
      expect(status.overlaySize, '2048 MB');
      expect(
        status.exclusions.where((e) => e == r'C:\Windows\Temp').length,
        1,
      );
      expect(
        status.exclusions,
        contains(r'HKLM\SYSTEM\CurrentControlSet\Services\W32Time'),
      );
    });
  });
}
