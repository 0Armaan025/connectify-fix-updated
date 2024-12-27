import 'package:appwrite/models.dart';
import 'package:connectify/constants/constants.dart';
import 'package:connectify/features/repositories/authentication/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthController {
  final AuthRepository _authRepository = AuthRepository();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _authRepository.loginUser(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      await _authRepository.registerUser(name, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUpWithGoogle(BuildContext context) async {
    final user = await _authRepository.registerUserWithGoogle(context);
    return user;
  }
}
