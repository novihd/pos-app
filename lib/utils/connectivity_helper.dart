import 'package:connectivity_plus/connectivity_plus.dart';
class ConnectivityHelper {
  static Future<bool> isOnline() async {
    final connections = await Connectivity().checkConnectivity();
    return connections.contains(ConnectivityResult.mobile) ||
         connections.contains(ConnectivityResult.wifi) ||
         connections.contains(ConnectivityResult.ethernet);  }
}
