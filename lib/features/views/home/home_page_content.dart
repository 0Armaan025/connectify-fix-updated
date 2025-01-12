import 'package:appwrite/models.dart' as models;
import 'package:connectify/common/post_widget/post_widget.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/database/user_post_database_controller.dart';
import 'package:connectify/features/controllers/database/user_profile_database_controller.dart';
import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:connectify/features/views/authentication/sign-up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final UserPostDatabaseController _postController =
      UserPostDatabaseController();
  final UserProfileDatabaseController _userProfileController =
      UserProfileDatabaseController();

  late Future<List<PostModal>> _postsFuture;
  final Map<String, Future<Map<String, dynamic>>> _userDetailsCache = {};

  @override
  void initState() {
    super.initState();
    getMyPosts();
    getFilesType(context);
  }

  getMyPosts() async {
    _postsFuture = _postController.getAllPosts(context).catchError((error) {
      // Log the error for debugging
      if (error.toString().contains("not authorized")) {
        moveScreen(context, SignUpPage(), isPushReplacement: true);
      }

      // Return an empty list as a fallback
      return <PostModal>[];
    });
  }

  getFilesType(BuildContext context) async {
    String type = await getFileType(
        "https://cloud.appwrite.io/v1/storage/buckets/posts-00d/files/677a8b457986ba598174/preview?project=connectify-00d");
    showSnackBar(context, type);
  }

  Future<String> getFileType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          if (contentType.startsWith('image/')) {
            return 'Image';
          } else if (contentType.startsWith('video/')) {
            return 'Video';
          } else {
            return 'Unknown';
          }
        }
      }
      return 'Unable to determine file type';
    } catch (e) {
      print('Error checking file type: $e');
      return 'Error';
    }
  }

  Future<Map<String, dynamic>> _getUserDetails(String uuid) {
    // Cache user details to prevent duplicate network requests
    if (!_userDetailsCache.containsKey(uuid)) {
      _userDetailsCache[uuid] =
          _userProfileController.getUserData(context, uuid).then((userDoc) {
        return {
          'username': userDoc.data['username'] ?? 'Unknown User',
          'profileImageUrl': userDoc.data['profileImageUrl'] ?? '',
        };
      }).catchError((e) {
        print('Error fetching user details: $e');
        return {'username': 'Unknown User', 'profileImageUrl': ''};
      });
    }
    return _userDetailsCache[uuid]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<PostModal>>(
          future: _postsFuture,
          builder: (context, postSnapshot) {
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (postSnapshot.hasError) {
              return const Center(
                  child: Text('An error occurred while loading posts'));
            }

            final posts = postSnapshot.data!;
            if (posts.isEmpty) {
              return const Center(child: Text('No posts available'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getUserDetails(post.uuid),
                  builder: (context, userDetailsSnapshot) {
                    if (userDetailsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(height: 200, color: Colors.grey[200]);
                    }

                    if (userDetailsSnapshot.hasError ||
                        !userDetailsSnapshot.hasData) {
                      return Container(height: 200, color: Colors.grey[200]);
                    }

                    final userDetails = userDetailsSnapshot.data!;
                    return PostWidget(
                      postID: post.postID,
                      text: post.caption,
                      comments: post.comments,
                      createdAt: post.createdAt,
                      likes: post.likes,
                      profileImageUrl: userDetails['profileImageUrl'] ?? '',
                      username: userDetails['username'] ?? 'Unknown User',
                      mediaUrl: post.mediaUrl != null ? post.mediaUrl : null,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
