import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  static Future<List<String>> getCarMakes() async {
    final url = Uri.parse('$_baseUrl/getallmakes?format=json');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['Results'] as List;
      return results.map((item) => item['Make_Name'].toString()).toList();
    } else {
      throw Exception('Failed to load car makes: ${response.statusCode}');
    }
  }

  static Future<List<String>> getModelsByMake(String make) async {
    final url = Uri.parse('$_baseUrl/getmodelsformake/$make?format=json');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['Results'] as List;
      if (results.isEmpty) throw Exception('No models found for "$make"');
      return results.map((item) => item['Model_Name'].toString()).toList();
    } else {
      throw Exception('Failed to load models: ${response.statusCode}');
    }
  }
}
