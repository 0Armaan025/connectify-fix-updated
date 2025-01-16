import 'package:appwrite/models.dart' as models;
import 'package:connectify/common/post_widget/post_widget.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/database/user_post_database_controller.dart';
import 'package:connectify/features/controllers/database/user_profile_database_controller.dart';
import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:connectify/features/views/authentication/sign-up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  late Future<void> _initializationFuture;
  final ScrollController _scrollController = ScrollController();
  List<PostModal> _posts = [];
  int _currentPage = 1;
  final int _limit = 10; // Number of posts per page
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  late Box<Map> _userCacheBox;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeHiveAndLoadPosts();

    // Add listener to load more posts when reaching the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMorePosts &&
          !_isLoadingMore) {
        _loadPosts(isLoadMore: true);
      }
    });
  }

  Future<void> _initializeHiveAndLoadPosts() async {
    await Hive.initFlutter();
    _userCacheBox = await Hive.openBox<Map>('user_cache');
    await _loadPosts();
  }

  Future<void> _loadPosts({bool isLoadMore = false}) async {
    if (_isLoadingMore || (!_hasMorePosts && isLoadMore)) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newPosts = await _postController.getAllPosts(context);

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        setState(() {
          _posts.addAll(newPosts);
          _currentPage++;
        });
      }
    } catch (error) {
      if (error.toString().contains("not authorized")) {
        moveScreen(context, SignUpPage(), isPushReplacement: true);
      } else {
        print('Error loading posts: $error');
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getCachedUserDetails(String uuid) async {
    if (_userCacheBox.containsKey(uuid)) {
      return Map<String, dynamic>.from(_userCacheBox.get(uuid)!);
    }

    try {
      final userDoc = await _userProfileController.getUserData(context, uuid);
      final userDetails = {
        'username': userDoc.data['username'] ?? 'Unknown User',
        'profileImageUrl': userDoc.data['profileImageUrl'] ?? '',
      };

      await _userCacheBox.put(uuid, userDetails);
      return userDetails;
    } catch (e) {
      print('Error fetching user details: $e');
      return {'username': 'Unknown User', 'profileImageUrl': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                  child: Text('An error occurred while loading the app'));
            }

            if (_posts.isEmpty) {
              return const Center(child: Text('No posts available'));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length + (_hasMorePosts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final post = _posts[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getCachedUserDetails(post.uuid),
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

  @override
  void dispose() {
    _scrollController.dispose();
    Hive.close();
    super.dispose();
  }
}
