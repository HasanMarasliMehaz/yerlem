import 'dart:async';

import 'package:flutter_application_1/models/location_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Bunu unutma!

class LocationProvider with ChangeNotifier {
  Database? _database;
  List<Map<String, dynamic>> _pastRoutes = [];
  LocationDataModel? _selectedLocation;
  LocationDataModel? get selectedLocation => _selectedLocation;
  // Veritabanını başlatmak
  Future<void> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'routes.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE routes (
            id INTEGER PRIMARY KEY,
            latitude REAL,
            longitude REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> fetchRoutesByDateAndTime(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) async {
    // Başlangıç ve bitiş timestamp’leri ISO formatta
    final startTs = DateTime(date.year, date.month, date.day, start.hour, start.minute).toIso8601String();
    final endTs = DateTime(date.year, date.month, date.day, end.hour, end.minute).toIso8601String();

    final List<Map<String, dynamic>> routes = await _database!.query(
      'routes',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startTs, endTs],
      orderBy: 'timestamp ASC',
    );

    _pastRoutes = routes;
    notifyListeners();
  }

  // Yeni bir rota eklemek
  Future<void> addRoute(double latitude, double longitude) async {
    final timestamp = DateTime.now().toIso8601String();
    await _database?.insert('routes', {'latitude': latitude, 'longitude': longitude, 'timestamp': timestamp});
    notifyListeners(); // Dinleyicilere haber ver
  }

  // insertLocation metodu: MapScreen'deki kullanım için
  Future<void> insertLocation(LatLng point) async {
    await addRoute(point.latitude, point.longitude);
  }

  // Tarihe göre geçmiş rotaları çekmek
  Future<void> fetchRoutesByDate(DateTime date) async {
    final formattedDate = date.toIso8601String().split('T').first;
    final List<Map<String, dynamic>> routes =
        await _database!.query('routes', where: 'timestamp LIKE ?', whereArgs: ['$formattedDate%']);
    _pastRoutes = routes;
    notifyListeners();
  }

  // Geçmiş rotaları almak
  List<Map<String, dynamic>> get pastRoutes => _pastRoutes;

  void showRouteOnMap(LocationDataModel location) {
    _selectedLocation = location;
    notifyListeners();
  }
}
