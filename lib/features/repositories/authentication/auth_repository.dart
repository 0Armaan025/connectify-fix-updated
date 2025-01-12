import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/constants/appwrite_constants.dart';
import 'package:connectify/constants/normal_constants.dart';
import 'package:connectify/features/views/authentication/sign-up/sign_up_page.dart';
import 'package:connectify/features/views/profile_set_up/profile_set_up_page.dart';
import 'package:connectify/features/views/user_blocked/user_blocked_page.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<User?> loginUser(BuildContext context, String email, String password,
      {bool isRegister = false}) async {
    Account account = Account(client);
    await account
        .createEmailPasswordSession(email: email, password: password)
        .then((value) async {
      final user = await account.get();
      globalUser = user;

      if (isRegister)
        moveScreen(context, ProfileSetUpPage(), isPushReplacement: true);
    });

    return null;
  }

  Future<void> registerUser(
      BuildContext context, String name, String email, String password) async {
    Account account = Account(client);

    try {
      await account
          .create(
              userId: ID.unique().toString(),
              email: email.trim(),
              password: password.trim(),
              name: name.trim())
          .onError((error, stackTrace) {
        throw Exception();
      }).then((_) async {
        await loginUser(context, email.trim(), password.trim(),
            isRegister: true);
      });
    } catch (e) {
      showSnackBar(context,
          "Some random error happened, you can report it to Armaan, error: ${e.toString()}");
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
      showSnackBar(context,
          "Some error ocurred, report it to Armaan kudasai (please) :D, error: ${error}");
    });
    final user = account.get().then((value) {
      moveScreen(context, ProfileSetUpPage(), isPushReplacement: true);
    });

    return user;
  }

  Future<User?> getCurrentUser(BuildContext context) async {
    Account account = Account(client);
    final user = account.get().catchError(
      (error) {
        if (error is AppwriteException) {
          if (error.code == 401 && error.message!.contains('blocked')) {
            moveScreen(context, UserBlockedPage(), isPushReplacement: true);
          } else {
            print(
                'An error occurred: (contact armaan pwease) ${error.message}');
          }
        } else if (error is AppwriteException) {
          if (error.message!.contains('not authorized')) {
            moveScreen(context, SignUpPage(), isPushReplacement: true);
          }
        }
      },
    );

    if (user != null) {
      return user;
    } else {
      showSnackBar(context, "No user exists, we are sorry");
    }
  }
}
