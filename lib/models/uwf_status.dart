/// --------------------------------------------------------------------------
/// MODELLI DI DATI
/// --------------------------------------------------------------------------

class UwfStatus {
  final bool isEnabled; // current session filter state
  final bool isNextSessionEnabled;
  final bool isVolumeProtected; // effective UI protection state
  final bool isCurrentSessionProtected;
  final bool isNextSessionProtected;
  final String overlayMode;
  final String overlaySize;
  final List<String> exclusions;

  UwfStatus({
    this.isEnabled = false,
    this.isNextSessionEnabled = false,
    this.isVolumeProtected = false,
    this.isCurrentSessionProtected = false,
    this.isNextSessionProtected = false,
    this.overlayMode = 'N/D',
    this.overlaySize = '0 MB',
    this.exclusions = const [],
  });

  bool get hasPendingProtectionChange =>
      isCurrentSessionProtected != isNextSessionProtected;
}
