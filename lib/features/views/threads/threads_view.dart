import 'package:connectify/common/forum_post/forum_post.dart';
import 'package:connectify/features/controllers/database/user_forum_database_controller.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThreadsView extends StatefulWidget {
  const ThreadsView({super.key});

  @override
  State<ThreadsView> createState() => _ThreadsViewState();
}

class _ThreadsViewState extends State<ThreadsView> {
  late Future<List<ForumModal>> forumPostsFuture;

  @override
  void initState() {
    super.initState();
    forumPostsFuture = UserForumDatabaseController().getAllForumPosts(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Title
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                "Discuss",
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 24),
              ),
            ),
            const SizedBox(height: 15),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search threads (private no./title)",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: (value) {
                  print("Search text: $value");
                },
              ),
            ),
            const SizedBox(height: 15),
            // Forum Posts List
            Expanded(
              child: FutureBuilder<List<ForumModal>>(
                future: forumPostsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No forum posts available.'));
                  } else {
                    final forumPosts = snapshot.data!;
                    return ListView.builder(
                      itemCount: forumPosts.length,
                      itemBuilder: (context, index) {
                        final post = forumPosts[index];
                        return ForumPost(
                          uuid: post.uuid,
                          
                          createdAt: post.createdAt,
                          forumContent: post.description,
                          forumID: post.forumID,
                          mediaUrl: post.mediaUrl,
                          upvotes: post.upvotes,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
