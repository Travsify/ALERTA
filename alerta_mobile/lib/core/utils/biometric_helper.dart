import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }


  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Scan your fingerprint to access Alerta',
      );
    } catch (e) {
      return false;
    }
  }
}
