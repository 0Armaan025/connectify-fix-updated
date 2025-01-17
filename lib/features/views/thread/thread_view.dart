import 'package:connectify/common/attatchment_tile/attatchment_tile.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:connectify/features/controllers/database/user_forum_database_controller.dart';
import 'package:connectify/features/modals/forum_comment/forum_comment_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/database/user_profile_database_controller.dart';

class ThreadView extends StatefulWidget {
  final String forumID;
  final String username;
  final String profileImageUrl;
  final List<String> upvotes;
  final String createdAt;
  final String description;
  final String mediaUrl;
  const ThreadView(
      {super.key,
      required this.forumID,
      required this.username,
      required this.profileImageUrl,
      required this.createdAt,
      required this.mediaUrl,
      required this.description,
      required this.upvotes});

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  bool isExpanded = false;

  String _getTrimmedContent() {
    final contentWords = widget.description.split(" ");
    if (contentWords.length > 15 && !isExpanded) {
      return "${contentWords.sublist(0, 15).join(" ")}...";
    }
    return widget.description;
  }

  bool isContentScrollable = false;
  List<ForumCommentModal> _comments = [];
  bool _hasUpvoted = false;
  String _username = "";
  String _profileImageUrl = "";
  bool isLoading = true; // Loading state for comments

  final TextEditingController _commentController = TextEditingController();

  Widget _buildPostUserSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                "FORUM ID: ${widget.forumID}",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        '${widget.profileImageUrl}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${widget.username}",
                      style: GoogleFonts.poppins(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    "${widget.createdAt}",
                    style: GoogleFonts.poppins(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTrimmedContent(),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.description.split(" ").length > 40)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(
                            isExpanded ? "Read Less" : "Read More",
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            CupertinoIcons.hand_thumbsup,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${widget.upvotes.length}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.mediaUrl.isNotEmpty
                      ? AttatchmentTile(
                          url: widget.mediaUrl,
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    if (_comments.isEmpty) {
      return const Center(child: Text("No comments available.")); // No comments
    }

    return Container(
      width: 200,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Prevents scrolling; let parent scroll
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];

              return GestureDetector(
                onLongPress: () {},
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              '${_profileImageUrl}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _username, // Use your model's properties
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment
                                      .commentContent, // Comment content from the model
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 20,
                                child: GestureDetector(
                                  onTap: () {}, // Implement like action
                                  child: const Icon(
                                    CupertinoIcons.hand_thumbsup,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${comment.upvotes.length ?? 0}", // Likes count
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Optional: Attachments Section
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _buildCommentInputSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Leave a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () async {
              await addForumComment(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getComments();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  Future<void> addForumComment(BuildContext context) async {
    UserForumDatabaseController _controller = UserForumDatabaseController();
    final modal = ForumCommentModal(
      uuid: '',
      forumCommentID: '',
      commentContent: _commentController.text.toString(),
      mediaUrl: '',
      upvotes: [],
      createdAt: '',
    );
    try {
      await _controller.addForumComment(context, modal, widget.forumID, null);
      getComments();
    } catch (e) {
      showSnackBar(context, 'caught issue here: ${e.toString()}');
    }
  }

  getComments() async {
    await getCommentsHere();
  }

  Future<void> getCommentsHere() async {
    await getUserDataToo();
    UserForumDatabaseController _controller = UserForumDatabaseController();
    final comments =
        await _controller.fetchForumComments(context, widget.forumID);

    setState(() {
      _comments = comments;
      isLoading = false;
    });
  }

  Future<void> getUserDataToo() async {
    final user = await AuthController().getCurrentUser(context);
    if (user != null) {
      final userUUID = user.$id;
      UserProfileDatabaseController _controller =
          UserProfileDatabaseController();
      final userModal = await _controller.getUserData(context, userUUID);
      _username = userModal.data['username'];
      _profileImageUrl = userModal.data['profileImageUrl'];

      _hasUpvoted = widget.upvotes.contains(userUUID);

      setState(() {});
    } else {
      showSnackBar(context, 'some error is coming, pwease contact armaan :((');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: isContentScrollable
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostUserSection(context),
                  _buildCommentsSection(),
                  _buildCommentInputSection(),
                ],
              ),
            )
          : Column(
              children: [
                _buildPostUserSection(context),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCommentsSection(),
                    ],
                  ),
                ),
                _buildCommentInputSection(),
              ],
            ),
    );
  }
}
