
import '../utils/api_client.dart';
import '../models/variedad_model.dart';

class VariedadRepository {
  static Future<Map<String, dynamic>> obtenerVariedades() async {
    try {
      final res = await ApiClient.get('/api/variedades/', auth: true);

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      print('🌸 [VARIEDADES] Código: $status');
      print('🌸 [VARIEDADES] Respuesta: $data');

      if (status == 200) {
        final rawList = (data['data'] ?? []) as List;
        final variedades = rawList
            .map((e) => VariedadModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return {'success': true, 'variedades': variedades};
      }

      return {'success': false, 'message': data['error'] ?? 'Error ($status)'};
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener variedades: $e'};
    }
  }
}
