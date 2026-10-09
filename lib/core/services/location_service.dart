import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Request GPS permission and fetch current device location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  /// Launch Google Maps navigation to hospital coordinates or address
  Future<void> openMap({double? latitude, double? longitude, String? address}) async {
    Uri url;
    if (latitude != null && longitude != null) {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    } else if (address != null && address.isNotEmpty) {
      final encoded = Uri.encodeComponent(address);
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    } else {
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch phone dialer for Doctor
  Future<void> makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
