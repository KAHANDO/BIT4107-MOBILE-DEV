import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class VehicleSearchScreen extends StatefulWidget {
  const VehicleSearchScreen({super.key});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchedMake;

  Future<void> _searchModels() async {
    final make = _searchController.text.trim();
    if (make.isEmpty) {
      setState(() => _errorMessage = 'Please enter a car make (e.g. Toyota)');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
      _searchedMake = make;
    });
    try {
      final models = await VehicleService.getModelsByMake(make);
      setState(() {
        _results = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        title: const Text('Vehicle Search', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF1E40AF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Find parts by vehicle',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter make (e.g. Toyota, Nissan)',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.directions_car,
                              color: Color(0xFFF59E0B)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _searchModels(),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchModels,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: _buildResultsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 16),
            Text('Fetching vehicle models...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchModels,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB)),
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (_results.isEmpty && _searchedMake == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search for a vehicle make\nto find compatible parts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15)),
            SizedBox(height: 8),
            Text('Try: Toyota, Nissan, Subaru, Isuzu',
                style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            '${_results.length} models found for "$_searchedMake"',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E40AF)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF59E0B),
                  child: Icon(Icons.directions_car,
                      color: Colors.white, size: 18),
                ),
                title: Text(_results[index],
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(_searchedMake ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Finding parts for ${_results[index]}...'),
                    backgroundColor: const Color(0xFF2563EB),
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}