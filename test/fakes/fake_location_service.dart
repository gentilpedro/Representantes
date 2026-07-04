import 'package:josapar_representantes/features/agenda/data/services/location_service.dart';

/// A instância real usa o plugin `geolocator`, que trava esperando resposta
/// de platform channel em ambiente de teste (sem handler mockado).
class FakeLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentPosition() async {
    return const LocationResult(
      errorMessage: 'GPS indisponível neste ambiente de teste.',
    );
  }
}
