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

    test('parses Italian Windows 10.0.26100 uwfmgr output', () {
      const output = r'''
Utilità di configurazione Filtro scrittura unificato versione 10.0.26100

Impostazioni sessione corrente


IMPOSTAZIONI FILTRO
    Stato filtro: ATTIVATA
    Commit in sospeso: NO
    Arresto in sospeso: NO
    Modalità HORM:         DISATTIVATA

IMPOSTAZIONI MANUTENZIONE
    Stato manutenzione: DISATTIVATA

IMPOSTAZIONI OVERLAY
Tipo     : RAM
    Dimensione massima: 2048 MB
    Soglia avviso: 512 MB
    Soglia critica: 1024 MB

IMPOSTAZIONI VOLUME
Volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
    stato volume: Un-protected
    ID volume: b84608a6-bcd8-400a-9015-d2de6b15df5c

Esclusioni file:
Esclusioni della sessione corrente per il volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
    C:\Windows\temp
    C:\ProgramData\Microsoft\Crypto

ESCLUSIONI REGISTRO DI SISTEMA
    HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers

Impostazioni sessione successiva


IMPOSTAZIONI FILTRO
    Stato filtro: ATTIVATA

IMPOSTAZIONI OVERLAY
Tipo     : RAM
    Dimensione massima: 2048 MB

IMPOSTAZIONI VOLUME
Volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
    stato volume: Un-protected
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
      expect(status.exclusions, contains(r'C:\Windows\temp'));
      expect(
        status.exclusions,
        contains(r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'),
      );
    });

    test('parses legacy Italian uwfmgr output', () {
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

    test('parses French Windows 10.0.26100 uwfmgr output', () {
      const output = r'''
Utilitaire de configuration de filtre d'écriture unifiée version 10.0.26100

Paramètres de la session en cours


PARAMÈTRES DE FILTRE
    État du filtre : ACTIVÉ

PARAMÈTRES DE MAINTENANCE
    État de maintenance : DÉSACTIVÉ

PARAMÈTRES DE SUPERPOSITION
Type de      : RAM
    Taille maximale : 2048 Mo

PARAMÈTRES DE VOLUME
Volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
État du volume      : Protégé

Exclusions de fichiers :
Exclusions de la session en cours pour le volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
    C:\Windows\temp

EXCLUSIONS DE REGISTRE
    HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers

Paramètres de la session suivante


PARAMÈTRES DE FILTRE
    État du filtre : ACTIVÉ

PARAMÈTRES DE SUPERPOSITION
Type de      : RAM
    Taille maximale : 2048 Mo

PARAMÈTRES DE VOLUME
Volume b84608a6-bcd8-400a-9015-d2de6b15df5c [C:]
État du volume      : Protégé
''';

      final status = SystemService().parseUwfStatus(output);

      expect(status.isEnabled, isTrue);
      expect(status.isNextSessionEnabled, isTrue);
      expect(status.isCurrentSessionProtected, isTrue);
      expect(status.isNextSessionProtected, isTrue);
      expect(status.isVolumeProtected, isTrue);
      expect(status.overlayMode, 'RAM');
      expect(status.overlaySize, '2048 MB');
      expect(
        status.exclusions,
        contains(r'C:\Windows\temp'),
      );
      expect(
        status.exclusions,
        contains(r'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'),
      );
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
