class SignupFailedException implements Exception {
  String cause;

  SignupFailedException({this.cause});
}