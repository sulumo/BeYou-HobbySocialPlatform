import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Map<String, Color> hobbyColors = {
  'Cars': Color(0xFFE74C3C), // Red
  'Music': Color(0xFF9B59B6), // Purple
  'Running': Color(0xFF3498DB), // Blue
  'Traveling': Color(0xFF1ABC9C), // Turquoise
  'Reading': Color(0xFF2ECC71), // Green
  'Swimming': Color(0xFF16A085), // Deep Teal
  'Cycling': Color(0xFFF1C40F), // Yellow
  'Writing': Color(0xFF34495E), // Dark Blue
  'Art': Color(0xFFE67E22), // Orange
  'Animals': Color(0xFF95A5A6), // Grey
  'Cooking': Color(0xFFD35400), // Dark Orange
  'Photo': Color(0xFF7F8C8D), //Dark Grey
};

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  final Map<MarkerId, Map<String, dynamic>> _usersData = {};
  final Map<MarkerId, Marker> _markers = {};
  final Map<String, BitmapDescriptor> _avatarIcons = {};

  MarkerId? _selectedMarker;
  String _filter = 'all';
  List<String> _currentUserHobbies = [];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    final pos = await _determinePosition();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });
    _currentUserHobbies = await _loadCurrentUserHobbies();
    _loadUsers();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<String>> _loadCurrentUserHobbies() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('hobby_details')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<BitmapDescriptor> _createCircularMarker(String avatarUrl) async {
    if (_avatarIcons.containsKey(avatarUrl)) {
      return _avatarIcons[avatarUrl]!;
    }

    final file = await DefaultCacheManager().getSingleFile(avatarUrl);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 128);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(100, 100);

    final paint = Paint()..color = Colors.pinkAccent;
    canvas.drawCircle(size.center(Offset.zero), 50, paint);

    final avatarPaint = Paint();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: 44));
    canvas.save();
    canvas.clipPath(clipPath);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCircle(center: size.center(Offset.zero), radius: 44),
      avatarPaint,
    );
    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(100, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final descriptor = BitmapDescriptor.fromBytes(pngBytes);

    _avatarIcons[avatarUrl] = descriptor;
    return descriptor;
  }

  Future<void> _loadUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uid = data['uid'];
      final location = data['lastLocation'];

      if (uid != null && location is GeoPoint) {
        final hobbiesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('hobby_details')
            .get();
        final hobbies = hobbiesSnapshot.docs.map((doc) => doc.id).toList();
        final markerId = MarkerId(uid);
        _usersData[markerId] = {...data, 'hobbies': hobbies};

        final isMe = uid == currentUid;
        final LatLng position = isMe
            ? _currentPosition!
            : LatLng(location.latitude, location.longitude);

        BitmapDescriptor icon;
        if (isMe) {
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          );
        } else if (data['avatarUrl'] != null) {
          icon = await _createCircularMarker(data['avatarUrl']);
        } else {
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRose,
          );
        }

        final marker = Marker(
          markerId: markerId,
          position: position,
          icon: icon,
          onTap: () {
            setState(() {
              _selectedMarker = markerId;
            });
          },
        );

        setState(() {
          _markers[markerId] = marker;
        });
      }
    }
  }

  bool _matchesFilter(Map<String, dynamic> userData) {
    if (_filter == 'all') return true;
    final userHobbies = List<String>.from(userData['hobbies'] ?? []);
    return userHobbies.any((hobby) => _currentUserHobbies.contains(hobby));
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedMarker = null;
    });
  }

  double? _getDistance(LatLng userLatLng) {
    if (_currentPosition == null) return null;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          userLatLng.latitude,
          userLatLng.longitude,
        ) /
        1000.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final visibleMarkers = _markers.entries
        .where((entry) => _matchesFilter(_usersData[entry.key]!))
        .map((entry) => entry.value)
        .toSet();

    final selectedUser = _selectedMarker != null
        ? _usersData[_selectedMarker]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text("All Users"),
                selected: _filter == 'all',
                onSelected: (_) => setState(() {
                  _filter = 'all';
                  _clearSelectedUser();
                }),
                backgroundColor: Colors.black,
                selectedColor: Colors.black87,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text("Similar Hobbies"),
                selected: _filter == 'similar',
                onSelected: (_) => setState(() {
                  _filter = 'similar';
                  _clearSelectedUser();
                }),
                backgroundColor: Colors.black,
                selectedColor: Colors.black87,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: visibleMarkers,
                  onTap: (_) => _clearSelectedUser(),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                if (selectedUser != null) _buildUserOverlay(selectedUser),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserOverlay(Map<String, dynamic> userData) {
    final LatLng userLatLng = LatLng(
      userData['lastLocation'].latitude,
      userData['lastLocation'].longitude,
    );

    final double? distance = _getDistance(userLatLng);

    return Positioned(
      bottom: 30,
      left: 10,
      right: 10,
      child: Card(
        color: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (distance != null &&
                  userData['uid'] != FirebaseAuth.instance.currentUser!.uid)
                Text(
                  "${distance.toStringAsFixed(1)} km away",
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 32,
                backgroundImage: userData['avatarUrl'] != null
                    ? CachedNetworkImageProvider(userData['avatarUrl'])
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                userData['name'] ?? 'Anonymous',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (userData['hobbies'] as List).map((hobby) {
                  final color = hobbyColors[hobby] ?? Colors.grey;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hobby,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
