import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:connectify/common/utils/utils.dart';
import 'package:connectify/constants/appwrite-constants.dart';
import 'package:connectify/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("connectify-00d");

  Future<User?> loginUser(String email, String password) async {
    Account account = Account(client);
    await account
        .createEmailPasswordSession(email: email, password: password)
        .then((value) async {
      final user = await account.get();
      globalUser = user;
    });

    return null;
  }

  Future<void> registerUser(String name, String email, String password) async {
    Account account = Account(client);
    print('$name $email $password');
    try {
      await account
          .create(
              userId: ID.unique().toString(),
              email: email.trim(),
              password: password.trim(),
              name: name.trim())
          .onError((error, stackTrace) {
        print('Error creating user: ${error.toString()}');
        throw Exception();
      }).then((_) async {
        await loginUser(email.trim(), password.trim());
      });
    } catch (e) {
      // debugPrint('Error creating user: ${e.toString()}');
      return;
    }
  }

  Future<User?> registerUserWithGoogle(BuildContext context) async {
    Account account = Account(client);
    account
        .createOAuth2Session(
          provider: OAuthProvider.google,
        )
        .then((_) {})
        .onError((error, stackTrace) {
      showSnackBar(context, error.toString() + stackTrace.toString());
    });
    final user = account.get();
    showSnackBar(context, "Success, user is $user");
    return user;
  }
}
