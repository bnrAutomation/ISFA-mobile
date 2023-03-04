import 'package:flutter/material.dart';

class DynamicQuestionsView extends StatelessWidget {
  const DynamicQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => const ListTile(),
      ),
    );
  }
}
