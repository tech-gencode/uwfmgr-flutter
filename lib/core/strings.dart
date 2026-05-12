import 'dart:io';

/// --------------------------------------------------------------------------
/// GESTIONE LOCALIZZAZIONE (Semplificata)
/// --------------------------------------------------------------------------

class Strings {
    static bool get isIt => Platform.localeName.startsWith('it');

    static String title = "UWF Manager V1.0";
    static String get dashboard => isIt ? "Dashboard" : "Dashboard";
    static String get network => isIt ? "Rete" : "Network";
    static String get system => isIt ? "Sistema" : "System";
    static String get keyboard => isIt ? "Tastiera" : "Keyboard";

    static String get uwfStateTitle =>
        isIt ? "Stato Unified Write Filter" : "Unified Write Filter Status";
    static String get uwfProtected =>
        isIt ? "Sistema Protetto (C:)" : "System Protected (C:)";
    static String get uwfUnprotected =>
        isIt ? "Protezione Disattivata" : "Protection Disabled";
    static String get uwfDescProtected =>
        isIt
            ? "Le modifiche verranno scartate al riavvio."
            : "Changes will be discarded upon reboot.";
    static String get uwfDescUnprotected =>
        isIt
            ? "Attenzione: Modifiche permanenti."
            : "Warning: Changes are permanent.";
    static String get btnEnable =>
        isIt ? "ATTIVA PROTEZIONE" : "ENABLE PROTECTION";
    static String get btnDisable =>
        isIt ? "DISATTIVA PROTEZIONE" : "DISABLE PROTECTION";

    static String get exceptions =>
        isIt ? "Eccezioni Attive" : "Active Exclusions";
    static String get noExceptions =>
        isIt ? "Nessuna eccezione" : "No exclusions";

    static String get netMonitor =>
        isIt ? "Monitoraggio Dispositivi" : "Device Monitoring";
    static String get emptyList => 
        isIt ? "Lista IP vuota" : "Empty IP list";        
    static String get sysConfig =>
        isIt ? "Configurazione Sistema" : "System Configuration";
    static String get hostName =>
        isIt ? "Imposta Nome Host (PC Name)" : "Set Host Name";
    static String get pcDesc =>
        isIt ? "Imposta Descrizione PC" : "Set PC Description";
    static String get btnApply => isIt ? "APPLICA MODIFICHE" : "APPLY CHANGES";
    static String get cmdSent =>
        isIt
            ? "Comando inviato. Riavvio necessario."
            : "Command sent. Reboot required.";

    static String get dimensionUWF => isIt ? "Dimensione" : "Size";
    static String get overlay => isIt ? "Overlay" : "Overlay";
    static String get selectOption =>
        isIt ? "Seleziona opzione" : "Select an option";
    static String statusError(Object error) =>
        isIt ? "Errore stato: $error" : "Status error: $error";
    static String get online => isIt ? "ONLINE" : "ONLINE";
    static String get offline => isIt ? "OFFLINE" : "OFFLINE";

  // --------------------------------------------------------------------------
  // NUOVE STRINGHE PER LA PULIZIA DEL SISTEMA
  // --------------------------------------------------------------------------
    static String get maintenance => isIt ? "Manutenzione" : "Maintenance";

    static String get maintenanceTitle =>
        isIt ? "Ottimizzazione Sistema" : "System Optimization";

    static String get maintenanceSubtitle =>
        isIt
            ? "Rimuovi file temporanei, svuota i cestini e pulisci i log per liberare spazio."
            : "Remove temporary files, empty trash bins, and clean logs to free up space.";

    static String get startMaintenance =>
        isIt ? "Avvia Pulizia" : "Start Cleaning";

    static String get cleaningInProgress =>
        isIt ? "Ottimizzazione in corso..." : "Optimizing...";

    static String get cleaningCompleted =>
        isIt ? "Sistema Ottimizzato" : "System Optimized";

    static String get statusIdle => isIt ? "Pronto" : "Ready";

    static String get checkingPermissions =>
        isIt ? "Verifica permessi..." : "Checking permissions...";

    static String get permissionError =>
        isIt ? "Errore verifica permessi" : "Permission check error";

    static String get requiresAdmin =>
        isIt ? "Richiede privilegi Admin" : "Requires admin privileges";

    static String get rebootRequired =>
        isIt ? "Riavvio Richiesto" : "Reboot Required";

    static String get rebootUwfMessage =>
        isIt 
        ? "Le impostazioni UWF sono state aggiornate.\n\nÈ necessario riavviare il sistema per rendere effettive le modifiche. Vuoi riavviare ora?"
        : "UWF settings have been updated.\n\nA system reboot is required to apply changes. Reboot now?";

    static String get btnLater =>
        isIt ? "PIÙ TARDI" : "LATER";

    static String get btnRebootNow =>
        isIt ? "RIAVVIA ORA" : "REBOOT NOW";        

  // --------------------------------------------------------------------------
  // SERVICING / WINDOWS UPDATE
  // --------------------------------------------------------------------------
    static String get servicing => isIt ? "Servicing" : "Servicing";

    static String get servicingTitle =>
        isIt ? "Aggiornamento Sistema Operativo" : "Operating System Update";

    static String get servicingSubtitle =>
        isIt
            ? "Riattiva temporaneamente Windows Update, avvia la ricerca/installazione aggiornamenti e poi ripristina la configurazione bloccata."
            : "Temporarily re-enable Windows Update, start scanning/installing updates, then restore the locked configuration.";

    static String get wuCaptureState =>
        isIt ? "Salva stato attuale" : "Capture current state";

    static String get wuEnable =>
        isIt ? "Riattiva Windows Update" : "Enable Windows Update";

    static String get wuStart =>
        isIt ? "Avvia aggiornamenti" : "Start updates";

    static String get wuOpenSettings =>
        isIt ? "Apri Windows Update" : "Open Windows Update";

    static String get wuRestore =>
        isIt ? "Ripristina configurazione" : "Restore configuration";

    static String get wuRunFull =>
        isIt ? "Esegui flusso guidato" : "Run guided flow";

    static String get wuLog =>
        isIt ? "Log operazioni" : "Operation log";

    static String get wuAdminRequired =>
        isIt ? "Richiede privilegi Admin per Windows Update" : "Admin privileges required for Windows Update";
}
