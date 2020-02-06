class FTPException implements Exception {
  final String message;
  final String response;
  
  FTPException(this.message, [this.response]);
}