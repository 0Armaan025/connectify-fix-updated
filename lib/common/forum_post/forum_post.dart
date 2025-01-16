import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:connectify/features/controllers/database/user_forum_database_controller.dart';
import 'package:connectify/features/controllers/database/user_profile_database_controller.dart';
import 'package:connectify/features/views/thread/thread_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class ForumPost extends StatefulWidget {
  final String uuid;

  final String createdAt;
  final String forumID;
  final String forumContent;
  final String mediaUrl;
  final List<String> upvotes;
  const ForumPost(
      {super.key,
      required this.uuid,
      required this.createdAt,
      required this.forumContent,
      required this.forumID,
      required this.mediaUrl,
      required this.upvotes});

  @override
  State<ForumPost> createState() => _ForumPostState();
}

class _ForumPostState extends State<ForumPost> {
  String _username = "";
  String _profileImageUrl = "";

  int? upvotesLength;

  bool _hasUpvoted = false;

  @override
  void initState() {
    super.initState();
    getData();
    upvotesLength = widget.upvotes.length;
    checkHasVoted();
  }

  checkHasVoted() async {
    await checkHereVoted();
  }

  Future<void> checkHereVoted() async {
    final user = await AuthController().getCurrentUser(context);
    if (user != null) {
      final userUUID = user.$id;
      if (widget.upvotes.contains(userUUID)) {
        _hasUpvoted = true;
      } else {
        _hasUpvoted = false;
      }

      setState(() {});
    } else {
      showSnackBar(context, 'some error is coming, pwease contact armaan :((');
    }
  }

  getData() async {
    await getUserData();
  }

  Future<void> upvoteHere() async {
    UserForumDatabaseController _controller = UserForumDatabaseController();
    final user = await AuthController().getCurrentUser(context);
    final status = await _controller.upvoteForum(context, widget.forumID);
    if (status == 'upvoted') {
      upvotesLength = widget.upvotes.length + 1;
      _hasUpvoted = true;
      setState(() {});
    } else if (status == 'removed') {
      upvotesLength = widget.upvotes.length - 1;
      _hasUpvoted = false;
      setState(() {});
    }
  }

  Future<void> getUserData() async {
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.report,
                      color: Colors.red,
                    ),
                    title: const Text('Report post'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text('Delete post'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  )
                ],
              ),
            );
          },
        );
      },
      onTap: () {
        moveScreen(
            context,
            ThreadView(
              createdAt: widget.createdAt,
              description: widget.forumContent,
              forumID: widget.forumID,
              mediaUrl: widget.mediaUrl,
              profileImageUrl: _profileImageUrl,
              upvotes: widget.upvotes,
              username: _username,
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: HexColor("#dedede"),
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Text(
                "FORUM ID: ${widget.forumID}",
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        '${_profileImageUrl}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${_username}",
                      style: GoogleFonts.poppins(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
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
                  child: Text(
                    _truncateText("${widget.forumContent}"),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
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
                          onTap: () async {
                            await upvoteHere();
                            setState(() {});
                          },
                          child: Icon(
                            _hasUpvoted
                                ? CupertinoIcons.hand_thumbsup_fill
                                : CupertinoIcons.hand_thumbsup,
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
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text) {
    const int maxWords = 70;
    List<String> words = text.split(' ');

    if (words.length > maxWords) {
      return '${words.sublist(0, maxWords).join(' ')}...';
    }
    return text;
  }
}
