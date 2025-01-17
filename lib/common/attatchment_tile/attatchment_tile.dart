import 'package:connectify/common/enlarged_image/enlarged_image_view.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttatchmentTile extends StatefulWidget {
  final String url;
  const AttatchmentTile({super.key, required this.url});

  @override
  State<AttatchmentTile> createState() => _AttatchmentTileState();
}

class _AttatchmentTileState extends State<AttatchmentTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        moveScreen(context, EnlargedImageView(imageUrl: widget.url));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(8).copyWith(top: 3, bottom: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                moveScreen(context, EnlargedImageView(imageUrl: widget.url));
              },
              icon: Icon(
                Icons.image,
                color: Colors.grey.shade800,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              'Attachment.png',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}
