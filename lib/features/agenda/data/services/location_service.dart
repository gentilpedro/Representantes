import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({this.position, this.errorMessage});

  final Position? position;
  final String? errorMessage;

  bool get isSuccess => position != null;
}

/// Fino wrapper sobre o `geolocator`, tratando permissão/serviço desligado
/// sem lançar exceção — usado para validar a localização no check-in/out da
/// Agenda de Visitas.
class LocationService {
  Future<LocationResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          errorMessage: 'Serviço de localização desativado no dispositivo.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationResult(
          errorMessage: 'Permissão de localização negada.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      return LocationResult(position: position);
    } catch (e) {
      return LocationResult(
        errorMessage: 'Não foi possível obter a localização: $e',
      );
    }
  }
}
