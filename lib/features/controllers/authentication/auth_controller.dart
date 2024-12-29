import 'package:appwrite/models.dart';
import 'package:connectify/constants/normal_constants.dart';
import 'package:connectify/features/repositories/authentication/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthController {
  final AuthRepository _authRepository = AuthRepository();

  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await _authRepository.loginUser(context, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
      BuildContext context, String name, String email, String password) async {
    try {
      await _authRepository.registerUser(context, name, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUpWithGoogle(BuildContext context) async {
    final user = await _authRepository.registerUserWithGoogle(context);
    return user;
  }

  Future<User?> getCurrentUser(BuildContext context) async {
    final user = await _authRepository.getCurrentUser(context);
    return user;
  }
}
