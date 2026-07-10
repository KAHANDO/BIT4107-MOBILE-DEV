import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/database_helper.dart';

class PartsNearMeScreen extends StatefulWidget {
  const PartsNearMeScreen({super.key});

  @override
  State<PartsNearMeScreen> createState() => _PartsNearMeScreenState();
}

class _PartsNearMeScreenState extends State<PartsNearMeScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;
  List<Map<String, dynamic>> _nearbyParts = [];
  bool _isLoadingParts = false;
  String _nearestEstate = '';

  // Nairobi seller estate coordinates
  final Map<String, Map<String, double>> _estateCoordinates = {
    'Kirinyaga Road, Nairobi': {'lat': -1.2833, 'lng': 36.8333},
    'Grogan Road, Nairobi': {'lat': -1.2866, 'lng': 36.8290},
    'Industrial Area, Nairobi': {'lat': -1.3031, 'lng': 36.8450},
    'Thika Road, Nairobi': {'lat': -1.2197, 'lng': 36.8880},
    'Ngong Road, Nairobi': {'lat': -1.3031, 'lng': 36.7816},
    'River Road, Nairobi': {'lat': -1.2833, 'lng': 36.8267},
    'Westlands, Nairobi': {'lat': -1.2641, 'lng': 36.8028},
    'South B, Nairobi': {'lat': -1.3119, 'lng': 36.8356},
    'Mombasa Road, Nairobi': {'lat': -1.3204, 'lng': 36.8495},
    'Lunga Lunga Road, Nairobi': {'lat': -1.2950, 'lng': 36.8350},
  };

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
      _currentPosition = null;
      _nearbyParts = [];
    });

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled. Please enable GPS in your phone settings.';
        _isLoadingLocation = false;
      });
      return;
    }

    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permission denied. Please allow location access to find nearby parts.';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permission permanently denied. Please enable it in phone Settings > Apps > SpareDash > Permissions.';
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      await _findNearbyParts(position);
    } catch (e) {
      setState(() {
        _locationError = 'Could not get location. Please try again.';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _findNearbyParts(Position position) async {
    setState(() => _isLoadingParts = true);

    // Find nearest estate using Geolocator.distanceBetween
    double minDistance = double.infinity;
    String nearestEstate = '';

    _estateCoordinates.forEach((estate, coords) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        coords['lat']!,
        coords['lng']!,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestEstate = estate;
      }
    });

    // Load all parts and filter by nearest estate location
    final allParts = await DatabaseHelper.instance.getAllParts();
    final nearby = allParts.where((part) {
      final location = part['location'] as String? ?? '';
      // Match parts from the same general area
      final estateKey = nearestEstate.split(',').first.toLowerCase();
      return location.toLowerCase().contains(estateKey) ||
          location.toLowerCase().contains('nairobi');
    }).toList();

    setState(() {
      _nearestEstate = nearestEstate;
      _nearbyParts = nearby.take(10).toList();
      _isLoadingParts = false;
    });
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m away';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
    }
  }

  double _getDistanceToEstate(String estate) {
    if (_currentPosition == null) return 0;
    final coords = _estateCoordinates[estate];
    if (coords == null) return 0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords['lat']!,
      coords['lng']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Parts Near Me',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // GPS header area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Find spare parts sellers near you',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),

                // GPS coordinates display
                if (_currentPosition != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.location_on, color: Color(0xFFF59E0B), size: 16),
                          SizedBox(width: 6),
                          Text('Your GPS Location',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.my_location, color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.my_location, color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.speed, color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ]),
                        if (_nearestEstate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.store, color: Color(0xFFF59E0B), size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Nearest sellers: $_nearestEstate',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ]),
                          Text(
                            _formatDistance(_getDistanceToEstate(_nearestEstate)),
                            style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Get Location button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isLoadingLocation
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.gps_fixed, color: Colors.white),
                    label: Text(
                      _isLoadingLocation
                          ? 'Getting Location...'
                          : _currentPosition == null
                          ? 'Get My Location'
                          : 'Refresh Location',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_locationError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_locationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Parts list
          Expanded(
            child: _currentPosition == null && !_isLoadingLocation
                ? _buildEmptyState()
                : _isLoadingParts
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2563EB)),
                  SizedBox(height: 16),
                  Text('Finding parts near you...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : _buildPartsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_searching, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Tap "Get My Location"',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'We will find spare parts sellers\nnear your current location',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          const Text(
            'GPS coordinates: Nairobi area',
            style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsList() {
    if (_nearbyParts.isEmpty) {
      return const Center(
        child: Text('No parts found near your location',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${_nearbyParts.length} parts found near $_nearestEstate',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E40AF)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nearbyParts.length,
            itemBuilder: (context, index) {
              final part = _nearbyParts[index];
              final inStock = (part['in_stock'] as int?) == 1;
              final location = part['location'] as String? ?? '';
              final distance = _estateCoordinates.containsKey(location)
                  ? _getDistanceToEstate(location)
                  : null;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.car_repair,
                            color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(part['name'] as String? ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(part['price'] as String? ?? '',
                                style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.store, size: 11, color: Colors.grey),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  part['seller'] as String? ?? '',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                            Row(children: [
                              const Icon(Icons.location_on, size: 11, color: Colors.grey),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: inStock ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inStock ? 'In Stock' : 'Out',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9),
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDistance(distance),
                              style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}