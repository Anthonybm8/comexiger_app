

import '../utils/api_client.dart';

class MesaRepository {
  static Future<Map<String, dynamic>> obtenerMesas() async {
    try {
      final res = await ApiClient.get('/api/mesas/', auth: true);

      final status = res['status'] as int;
      final data = res['data'] as Map<String, dynamic>;

      print('🪑 [MESAS] Código: $status');
      print('🪑 [MESAS] Respuesta: $data');

      if (status == 200) {
        final rawList = (data['data'] ?? []) as List;

        // ✅ tu backend manda: {id, nombre}
        final mesas = rawList.map((e) => (e['nombre'] ?? '').toString()).where((x) => x.isNotEmpty).toList();

        return {'success': true, 'mesas': mesas, 'count': mesas.length};
      }

      return {'success': false, 'message': data['error'] ?? 'Error ($status)', 'raw': data};
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener mesas: $e'};
    }
  }
}
