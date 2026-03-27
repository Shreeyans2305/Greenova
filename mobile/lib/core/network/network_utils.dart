import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for network connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider to check if device has internet connection
final hasInternetProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => results.any((r) =>
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet
    ),
    loading: () => true,
    error: (_, __) => true,
  );
});

/// Utility class for network operations
class NetworkUtils {
  /// Check if the device is connected to the internet
  static Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) =>
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet
    );
  }

  /// Get current connectivity type as a string
  static Future<String> getConnectionType() async {
    final results = await Connectivity().checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }
}
