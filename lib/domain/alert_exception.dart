class AlertException implements Exception {
  String msg;
  AlertException(this.msg);

  @override
  String toString() {
    return msg;
  }
}
