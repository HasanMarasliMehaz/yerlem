import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MapScreen extends StatefulWidget {
  final bool showFilteredRoute;
  const MapScreen({super.key, this.showFilteredRoute = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  late Location _locationService;
  Marker? _currentLocationMarker;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _locationService = Location();
    Provider.of<LocationProvider>(context, listen: false).initDatabase();
    _initWebSocket();
    _listenLocation();

    if (widget.showFilteredRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final filtered = Provider.of<LocationProvider>(context, listen: false).pastRoutes;
        setState(() {
          _routePoints = filtered.map((e) => LatLng(e['latitude'], e['longitude'])).toList();
        });
      });
    }
  }

  void _initWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.org'), // Test sunucu
    );
  }

  void _listenLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationService.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newPoint = LatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          _routePoints.add(newPoint);
          _currentLocationMarker = Marker(
            markerId: const MarkerId('current_location'),
            position: newPoint,
          );
        });

        // ignore: use_build_context_synchronously
        Provider.of<LocationProvider>(context, listen: false).insertLocation(newPoint);
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
        _sendLocationOverWebSocket(newPoint);
      }
    });
  }

  void _sendLocationOverWebSocket(LatLng point) {
    if (_channel != null) {
      final locationData = {
        'latitude': point.latitude,
        'longitude': point.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _channel!.sink.add(jsonEncode(locationData));
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Rotalar ve Canlı Konum'),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          final List<LatLng> pastRoutePoints =
              locationProvider.pastRoutes.map((e) => LatLng(e['latitude'], e['longitude'])).toList();

          if (widget.showFilteredRoute && pastRoutePoints.isNotEmpty && _mapController != null) {
            final firstPoint = pastRoutePoints.first;
            _mapController!.animateCamera(CameraUpdate.newLatLngZoom(firstPoint, 15));
          }

          Set<Polyline> polylines = {
            if (widget.showFilteredRoute && pastRoutePoints.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('filtered_route'),
                points: pastRoutePoints,
                color: Colors.red,
                width: 5,
              )
            else
              Polyline(
                polylineId: const PolylineId('live_route'),
                points: _routePoints,
                color: Colors.blue,
                width: 5,
              ),
          };

          Set<Marker> markers = {};
          if (_currentLocationMarker != null) {
            markers.add(_currentLocationMarker!);
          }

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.8726, 32.4926),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;

              if (widget.showFilteredRoute) {
                final pastRoutePoints = Provider.of<LocationProvider>(context, listen: false)
                    .pastRoutes
                    .map((e) => LatLng(e['latitude'], e['longitude']))
                    .toList();

                if (pastRoutePoints.isNotEmpty) {
                  final firstPoint = pastRoutePoints.first;
                  _mapController!.animateCamera(CameraUpdate.newLatLngZoom(firstPoint, 15));
                }
              }
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}
