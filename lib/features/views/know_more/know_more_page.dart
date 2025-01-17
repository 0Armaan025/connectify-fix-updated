import 'package:connectify/common/utils/normal_utils.dart';
import 'package:flutter/material.dart';

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
            children: [],
          ),
        ),
      ),
    );
  }
}
