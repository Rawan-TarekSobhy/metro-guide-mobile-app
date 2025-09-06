import 'dart:io';
import 'package:get/get.dart';
import 'station.dart';
import 'package:flutter/material.dart';
import 'stations_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<bool> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Get.snackbar("Error", "Location services are disabled.");
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Get.snackbar("Error", "Location permission denied.");
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Get.snackbar("Error", "Location permission permanently denied.");
    return false;
  }

  return true;
}

Future<Position> _findCurrentLocation() async {
  final hasPermission = await _determinePosition();
  if (!hasPermission) exit(0);

  Position position = await Geolocator.getCurrentPosition();
  return position;
}

Future<Station> findNearestStationFromCurrent() async {
  Station nearest = metroStations.first;
  double minDistance = double.infinity;
  Position pos = await _findCurrentLocation();
  double currentLongitude = pos.longitude;
  double currentLatitude = pos.latitude;
  for (final station in metroStations) {
    final distance = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      station.lat,
      station.lng,
    );

    if (distance < minDistance) {
      minDistance = distance;
      nearest = station;
    }
  }
  Station nearestStation = nearest;
  return nearestStation;
}

Future<Station> findNearestStationFromDestination(
    double distinationLatitude,
    double cdistinationLongitude,
    ) async {
  Station nearest = metroStations.first;
  double minDistance = double.infinity;
  for (final station in metroStations) {
    final distance = Geolocator.distanceBetween(
      distinationLatitude,
      cdistinationLongitude,
      station.lat,
      station.lng,
    );

    if (distance < minDistance) {
      minDistance = distance;
      nearest = station;
    }
  }
  return nearest;
}

Future<Station> findNearestToEnteredAddress(
    TextEditingController locationController,
    ) async {
  List<Location> locations = await locationFromAddress(
    "${locationController.text}+Cairo+Egypt",
  );
  if (locations.isNotEmpty) {
    final location = locations.first;
    return await findNearestStationFromDestination(
      location.latitude,
      location.longitude,
    );
  } else {
    Get.snackbar(
      'Error',
      'No location found for that address',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    exit(0);
  }
}
