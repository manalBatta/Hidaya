import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/UserProvider.dart';

class AuthUtils {
  static Future<void> logout(context) async {
    print('logged out');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    // Remove user data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();

    // Optionally navigate to login screen or show a message
  }
}
