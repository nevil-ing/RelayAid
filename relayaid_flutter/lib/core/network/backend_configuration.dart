class BackendConfigurationFailure implements Exception {
  const BackendConfigurationFailure();
  String get message =>
      'This build is missing a valid secure server address. Ask the beta organizer for an updated build.';
}

abstract final class BackendConfiguration {
  static String validate(String address, {required bool release}) {
    final uri = Uri.tryParse(address.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const BackendConfigurationFailure();
    }
    final host = uri.host.toLowerCase();
    final loopback =
        host == 'localhost' ||
        host.endsWith('.localhost') ||
        host == '::1' ||
        host == '[::1]' ||
        host == '0.0.0.0' ||
        host.startsWith('127.');
    if (release && (uri.scheme != 'https' || loopback)) {
      throw const BackendConfigurationFailure();
    }
    return uri.toString().endsWith('/') ? uri.toString() : '${uri.toString()}/';
  }
}
