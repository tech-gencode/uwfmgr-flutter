import 'dart:io';

/// --------------------------------------------------------------------------
/// GESTIONE LOCALIZZAZIONE (IT / FR / EN)
/// --------------------------------------------------------------------------

enum _Lang { it, fr, en }

class Strings {
  static _Lang get _lang {
    final locale = Platform.localeName.toLowerCase();
    if (locale.startsWith('it')) return _Lang.it;
    if (locale.startsWith('fr')) return _Lang.fr;
    return _Lang.en;
  }

  static String _s(String it, String fr, String en) {
    switch (_lang) {
      case _Lang.it:
        return it;
      case _Lang.fr:
        return fr;
      case _Lang.en:
        return en;
    }
  }

  static bool get isIt => _lang == _Lang.it;
  static bool get isFr => _lang == _Lang.fr;

  static String title = 'UWF Manager V1.0';

  static String get dashboard =>
      _s('Dashboard', 'Tableau de bord', 'Dashboard');
  static String get network => _s('Rete', 'Réseau', 'Network');
  static String get system => _s('Sistema', 'Système', 'System');
  static String get keyboard => _s('Tastiera', 'Clavier', 'Keyboard');

  static String get uwfStateTitle => _s(
        'Stato Unified Write Filter',
        'État du Unified Write Filter',
        'Unified Write Filter Status',
      );
  static String get uwfProtected => _s(
        'Sistema Protetto (C:)',
        'Système protégé (C:)',
        'System Protected (C:)',
      );
  static String get uwfUnprotected => _s(
        'Protezione Disattivata',
        'Protection désactivée',
        'Protection Disabled',
      );
  static String get uwfDescProtected => _s(
        'Le modifiche verranno scartate al riavvio.',
        'Les modifications seront ignorées au redémarrage.',
        'Changes will be discarded upon reboot.',
      );
  static String get uwfDescUnprotected => _s(
        'Attenzione: Modifiche permanenti.',
        'Attention : modifications permanentes.',
        'Warning: Changes are permanent.',
      );
  static String get btnEnable => _s(
        'ATTIVA PROTEZIONE',
        'ACTIVER LA PROTECTION',
        'ENABLE PROTECTION',
      );
  static String get btnDisable => _s(
        'DISATTIVA PROTEZIONE',
        'DÉSACTIVER LA PROTECTION',
        'DISABLE PROTECTION',
      );

  static String get exceptions =>
      _s('Eccezioni Attive', 'Exclusions actives', 'Active Exclusions');
  static String get noExceptions =>
      _s('Nessuna eccezione', 'Aucune exclusion', 'No exclusions');

  static String get netMonitor => _s(
        'Monitoraggio Dispositivi',
        'Surveillance des appareils',
        'Device Monitoring',
      );
  static String get emptyList =>
      _s('Lista IP vuota', 'Liste d\'adresses IP vide', 'Empty IP list');
  static String get sysConfig => _s(
        'Configurazione Sistema',
        'Configuration du système',
        'System Configuration',
      );
  static String get hostName => _s(
        'Imposta Nome Host (PC Name)',
        'Définir le nom d\'hôte (nom du PC)',
        'Set Host Name',
      );
  static String get pcDesc => _s(
        'Imposta Descrizione PC',
        'Définir la description du PC',
        'Set PC Description',
      );
  static String get btnApply => _s(
        'APPLICA MODIFICHE',
        'APPLIQUER LES MODIFICATIONS',
        'APPLY CHANGES',
      );
  static String get cmdSent => _s(
        'Comando inviato. Riavvio necessario.',
        'Commande envoyée. Redémarrage requis.',
        'Command sent. Reboot required.',
      );

  static String get dimensionUWF => _s('Dimensione', 'Taille', 'Size');
  static String get overlay => 'Overlay';
  static String get selectOption => _s(
        'Seleziona opzione',
        'Sélectionner une option',
        'Select an option',
      );
  static String statusError(Object error) => _s(
        'Errore stato: $error',
        'Erreur d\'état : $error',
        'Status error: $error',
      );
  static String get online => 'ONLINE';
  static String get offline => 'OFFLINE';

  // --------------------------------------------------------------------------
  // PULIZIA DEL SISTEMA
  // --------------------------------------------------------------------------
  static String get maintenance =>
      _s('Manutenzione', 'Maintenance', 'Maintenance');

  static String get maintenanceTitle => _s(
        'Ottimizzazione Sistema',
        'Optimisation du système',
        'System Optimization',
      );

  static String get maintenanceSubtitle => _s(
        'Rimuovi file temporanei, svuota i cestini e pulisci i log per liberare spazio.',
        'Supprimez les fichiers temporaires, videz les corbeilles et nettoyez les journaux pour libérer de l\'espace.',
        'Remove temporary files, empty trash bins, and clean logs to free up space.',
      );

  static String get startMaintenance => _s(
        'Avvia Pulizia',
        'Démarrer le nettoyage',
        'Start Cleaning',
      );

  static String get cleaningInProgress => _s(
        'Ottimizzazione in corso...',
        'Optimisation en cours...',
        'Optimizing...',
      );

  static String get cleaningCompleted => _s(
        'Sistema Ottimizzato',
        'Système optimisé',
        'System Optimized',
      );

  static String get statusIdle => _s('Pronto', 'Prêt', 'Ready');

  static String get checkingPermissions => _s(
        'Verifica permessi...',
        'Vérification des autorisations...',
        'Checking permissions...',
      );

  static String get permissionError => _s(
        'Errore verifica permessi',
        'Erreur de vérification des autorisations',
        'Permission check error',
      );

  static String get requiresAdmin => _s(
        'Richiede privilegi Admin',
        'Privilèges administrateur requis',
        'Requires admin privileges',
      );

  static String get rebootRequired =>
      _s('Riavvio Richiesto', 'Redémarrage requis', 'Reboot Required');

  static String get rebootUwfMessage => _s(
        'Le impostazioni UWF sono state aggiornate.\n\nÈ necessario riavviare il sistema per rendere effettive le modifiche. Vuoi riavviare ora?',
        'Les paramètres UWF ont été mis à jour.\n\nUn redémarrage du système est nécessaire pour appliquer les modifications. Voulez-vous redémarrer maintenant ?',
        'UWF settings have been updated.\n\nA system reboot is required to apply changes. Reboot now?',
      );

  static String get btnLater => _s('PIÙ TARDI', 'PLUS TARD', 'LATER');

  static String get btnRebootNow =>
      _s('RIAVVIA ORA', 'REDÉMARRER MAINTENANT', 'REBOOT NOW');

  // --------------------------------------------------------------------------
  // SERVICING / WINDOWS UPDATE
  // --------------------------------------------------------------------------
  static String get servicing => 'Servicing';

  static String get servicingTitle => _s(
        'Aggiornamento Sistema Operativo',
        'Mise à jour du système d\'exploitation',
        'Operating System Update',
      );

  static String get servicingSubtitle => _s(
        'Riattiva temporaneamente Windows Update, avvia la ricerca/installazione aggiornamenti e poi ripristina la configurazione bloccata.',
        'Réactivez temporairement Windows Update, lancez la recherche/l\'installation des mises à jour, puis restaurez la configuration verrouillée.',
        'Temporarily re-enable Windows Update, start scanning/installing updates, then restore the locked configuration.',
      );

  static String get wuCaptureState => _s(
        'Salva stato attuale',
        'Enregistrer l\'état actuel',
        'Capture current state',
      );

  static String get wuEnable => _s(
        'Riattiva Windows Update',
        'Réactiver Windows Update',
        'Enable Windows Update',
      );

  static String get wuStart => _s(
        'Avvia aggiornamenti',
        'Démarrer les mises à jour',
        'Start updates',
      );

  static String get wuOpenSettings => _s(
        'Apri Windows Update',
        'Ouvrir Windows Update',
        'Open Windows Update',
      );

  static String get wuRestore => _s(
        'Ripristina configurazione',
        'Restaurer la configuration',
        'Restore configuration',
      );

  static String get wuRunFull => _s(
        'Esegui flusso guidato',
        'Exécuter le flux guidé',
        'Run guided flow',
      );

  static String get wuLog =>
      _s('Log operazioni', 'Journal des opérations', 'Operation log');

  static String get wuAdminRequired => _s(
        'Richiede privilegi Admin per Windows Update',
        'Privilèges administrateur requis pour Windows Update',
        'Admin privileges required for Windows Update',
      );
}
