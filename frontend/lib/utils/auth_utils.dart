// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';

class AuthUtils {
  /// Check if the JWT token is expired
  static bool isTokenExpired(String token) {
    try {
      print('AuthUtils.isTokenExpired: Checking token expiration...');
      final isExpired = JwtDecoder.isExpired(token);
      print('AuthUtils.isTokenExpired: Token expired: $isExpired');
      return isExpired;
    } catch (e) {
      print('AuthUtils.isTokenExpired: Error checking token expiration: $e');
      return true; // Consider invalid tokens as expired
    }
  }

  /// Get token expiration date
  static DateTime? getTokenExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print('Error getting token expiration date: $e');
      return null;
    }
  }

  /// Check token and logout if expired
  static Future<bool> checkTokenAndLogoutIfExpired(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        // No token found, user should be logged out
        await logout(context);
        return true; // Token was invalid/expired
      }

      if (isTokenExpired(token)) {
        print('Token is expired, logging out user');
        await logout(context);
        return true; // Token was expired
      }

      return false; // Token is valid
    } catch (e) {
      print('Error checking token: $e');
      await logout(context);
      return true; // Error occurred, logout for safety
    }
  }

  /// Check token before making API requests
  static Future<String?> getValidToken(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        print('AuthUtils.getValidToken: Token length: ${token.length}');
        print(
          'AuthUtils.getValidToken: Token is expired: ${isTokenExpired(token)}',
        );
      }

      if (token == null || token.isEmpty) {
        print('AuthUtils.getValidToken: No token found, logging out');
        await logout(context);
        return null;
      }

      if (isTokenExpired(token)) {
        print('AuthUtils.getValidToken: Token is expired, logging out user');
        await logout(context);
        return null;
      }

      print('AuthUtils.getValidToken: Returning valid token');
      return token;
    } catch (e) {
      print('AuthUtils.getValidToken: Error getting valid token: $e');
      await logout(context);
      return null;
    }
  }

  static Future<void> logout(context) async {
    print('logged out');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Remove user data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();

    // Optionally navigate to login screen or show a message
  }
}
