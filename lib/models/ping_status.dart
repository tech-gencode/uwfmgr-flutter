/// --------------------------------------------------------------------------
/// MODELLI DI DATI
/// --------------------------------------------------------------------------

class PingStatus {
  final String ip;
  final bool isOnline;

  PingStatus({required this.ip, this.isOnline = false});
}
