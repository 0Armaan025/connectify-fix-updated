import 'package:connectify/common/utils/normal_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KnowMorePage extends StatefulWidget {
  const KnowMorePage({super.key});

  @override
  State<KnowMorePage> createState() => _KnowMorePageState();
}

class _KnowMorePageState extends State<KnowMorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, left: 8, right: 12),
                child: Text(
                  "This is commander Armaan speaking, the Eternal overlord of the great code realms!",
                  style:
                      GoogleFonts.poppins(color: Colors.purple, fontSize: 18),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "I was bored. So, I thought to create something fun.",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "My main motive was to create a full-fledged social media app with all the features.",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "The backend service I'm using (Appwrite) kinda sucks rn, and somehow while testing, I have used like 70% of it already, and I don't wanna use more , coz yk I gotta create more projects too!",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "So, there is a 99% possibility that it will be deactivated soon, though if there will be positive response, I'll use some other backend service like firebase by google or just create my own :) and add more features",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "For now, only forums(partially) and post feature work :((, and nothing else, everything else was the prototype thingy that I was trying to create, so that doesn't work",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "Well, there are a lot of bugs (errors) rn, pls do let me know on WA if you face any",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "Also, it took like 40~ hrs till now coz I was trying to have industry-level code this time, yk like this can be made in 5 hrs, but having each component, model or repo for each thing, that made it harder.",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "If you think this thing is hard or something? nah, this is not and anyone can make it fr!",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "only 10k+ lines :D, also I'd be really happy to get a feedback on WA!",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 12, top: 8),
                child: Text(
                  "If you are reading this, I thank you! :)",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://i.ibb.co/t88W1cr/New-Project-4.png",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
