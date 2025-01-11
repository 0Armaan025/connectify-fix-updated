import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../comment_tile/comment_tile.dart';
import '../enlarged_image/enlarged_image_view.dart';
import 'normal_utils.dart';

showMessageField(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return Column(
    children: [
      SizedBox(
        height: size.height * 0.36,
      ),
      Row(
        children: [
          const SizedBox(width: 8),

          // Expanded TextFormField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                maxLines: 1,
                minLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (value) {
                  print("Comment submitted: $value");
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // CircleAvatar with send icon
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                print("Send button clicked");
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      )
    ],
  );
}

showComments(BuildContext context) {
  final size = MediaQuery.of(context).size;
  showModalBottomSheet(
    isScrollControlled: true,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    ),
    context: context,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    ),
    builder: (context) {
      return SizedBox(
        height: size.height * 0.86,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.grey.shade700,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Comments",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const CommentTile(),
                const SizedBox(height: 10),
                showMessageField(context),
              ],
            ),
          ),
        ),
      );
    },
  );
}

openEnlargedImage(BuildContext context) {
  moveScreen(
    context,
    const EnlargedImageView(
        imageUrl:
            'https://images.unsplash.com/photo-1498278854500-7c206daa073b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bW91bnRhaW58ZW58MHwxfDB8fHww'),
  );
}

void showCustomReasonDialog(BuildContext context) {
  final TextEditingController reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Specify Reason",
          style: GoogleFonts.poppins(),
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter your reason",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                print("Reported with reason: $reason");
              }
              Navigator.pop(context); // Dismiss dialog
            },
            child: Text(
              "Submit",
              style: GoogleFonts.poppins(color: Colors.purple),
            ),
          ),
        ],
      );
    },
  );
}

void showLongPressedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.36,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(
                  CupertinoIcons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  "Delete",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Confirm Action",
                          style: GoogleFonts.poppins(),
                        ),
                        content: Text(
                          "Are you sure you want to delete this content?",
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Dismiss dialog
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Dismiss dialog
                            },
                            child: Text(
                              "Delete",
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.chart_bar,
                  color: Colors.purple,
                ),
                title: Text(
                  "View Insights",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.profile_circled,
                  color: Colors.purple,
                ),
                title: Text(
                  "User profile",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.minus_circle,
                  color: Colors.purple,
                ),
                title: Text(
                  "Block user",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.flag,
                  color: Colors.purple,
                ),
                title: Text(
                  "Report content",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  showReportDialog(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(14).copyWith(left: 2, right: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Report Content",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text("Harassment", style: GoogleFonts.poppins()),
                onTap: () {
                  // Handle report submission for Harassment
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                title: Text("Bullying", style: GoogleFonts.poppins()),
                onTap: () {
                  // Handle report submission for Bullying
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                title: Text("Spam", style: GoogleFonts.poppins()),
                onTap: () {
                  // Handle report submission for Spam
                  Navigator.pop(context);
                },
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey,
              ),
              ListTile(
                title: Text("Other", style: GoogleFonts.poppins()),
                onTap: () {
                  // Show a text input for custom reason
                  Navigator.pop(context);
                  showCustomReasonDialog(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

